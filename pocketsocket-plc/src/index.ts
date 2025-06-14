import { EventEmitter } from 'events';
import * as net from 'net';
// @ts-ignore - WebSocket will be available at runtime
import WebSocket from 'ws';
// @ts-ignore - Joi will be available at runtime  
import Joi from 'joi';
// @ts-ignore - Winston will be available at runtime
import winston from 'winston';

/**
 * PocketSocket PLC Configuration Schema
 */
const PLCConfigSchema = Joi.object({
  host: Joi.string().ip().required(),
  port: Joi.number().port().default(502),
  unitId: Joi.number().min(1).max(255).default(1),
  timeout: Joi.number().min(1000).default(5000),
  retryAttempts: Joi.number().min(0).default(3),
  retryDelay: Joi.number().min(100).default(1000),
  keepAlive: Joi.boolean().default(true),
  name: Joi.string().required(),
  description: Joi.string().optional()
});

/**
 * MODBUS Function Codes
 */
export enum ModbusFunctionCode {
  READ_COILS = 0x01,
  READ_DISCRETE_INPUTS = 0x02, 
  READ_HOLDING_REGISTERS = 0x03,
  READ_INPUT_REGISTERS = 0x04,
  WRITE_SINGLE_COIL = 0x05,
  WRITE_SINGLE_REGISTER = 0x06,
  WRITE_MULTIPLE_COILS = 0x0F,
  WRITE_MULTIPLE_REGISTERS = 0x10
}

/**
 * PLC Connection Configuration Interface
 */
export interface IPLCConfig {
  host: string;
  port?: number;
  unitId?: number;
  timeout?: number;
  retryAttempts?: number;
  retryDelay?: number;
  keepAlive?: boolean;
  name: string;
  description?: string;
}

/**
 * MODBUS Register/Coil Read Request
 */
export interface IModbusReadRequest {
  functionCode: ModbusFunctionCode;
  startAddress: number;
  quantity: number;
  unitId?: number;
}

/**
 * MODBUS Register/Coil Write Request
 */
export interface IModbusWriteRequest {
  functionCode: ModbusFunctionCode;
  startAddress: number;
  values: number[] | boolean[];
  unitId?: number;
}

/**
 * Real-time Signal Data Point
 */
export interface ISignalDataPoint {
  timestamp: number;
  address: number;
  value: number | boolean;
  quality: 'good' | 'bad' | 'uncertain';
  deviceName: string;
  signalName?: string;
}

/**
 * Revolutionary PocketSocket PLC Connection Manager
 * 
 * This class provides real-time MODBUS/TCP communication with industrial PLCs,
 * leveraging the PocketSocket architecture for blazing-fast, character-driven
 * industrial automation.
 */
export class PocketSocketPLC extends EventEmitter {
  private _config: IPLCConfig;
  private _socket: net.Socket | null = null;
  private _isConnected: boolean = false;
  private _isConnecting: boolean = false;
  private _transactionId: number = 1;
  private _pendingRequests: Map<number, any> = new Map();
  private _reconnectTimer: NodeJS.Timeout | null = null;
  private _keepAliveTimer: NodeJS.Timeout | null = null;
  private _logger: winston.Logger;
  private _wsServer: WebSocket.Server | null = null;
  private _connectedClients: Set<WebSocket> = new Set();

  constructor(config: IPLCConfig, wsPort?: number) {
    super();
    
    // Validate configuration
    const { error, value } = PLCConfigSchema.validate(config);
    if (error) {
      throw new Error(`Invalid PLC configuration: ${error.message}`);
    }
    this._config = value;

    // Initialize logger
    this._logger = winston.createLogger({
      level: 'info',
      format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.json()
      ),
      defaultMeta: { service: 'pocketsocket-plc', device: this._config.name },
      transports: [
        new winston.transports.Console(),
        new winston.transports.File({ filename: `plc-${this._config.name}.log` })
      ]
    });

    // Initialize WebSocket server for real-time data broadcasting
    if (wsPort) {
      this._initWebSocketServer(wsPort);
    }

    this._logger.info('PocketSocket PLC initialized', { config: this._config });
  }

  /**
   * Initialize WebSocket server for real-time data streaming
   */
  private _initWebSocketServer(port: number): void {
    this._wsServer = new WebSocket.Server({ port });
    
    this._wsServer.on('connection', (ws: WebSocket) => {
      this._connectedClients.add(ws);
      this._logger.info('Client connected to real-time data stream');
      
      ws.on('close', () => {
        this._connectedClients.delete(ws);
        this._logger.info('Client disconnected from real-time data stream');
      });

      // Send connection status
      ws.send(JSON.stringify({
        type: 'connection_status',
        connected: this._isConnected,
        device: this._config.name,
        timestamp: Date.now()
      }));
    });

    this._logger.info(`WebSocket server started on port ${port}`);
  }

  /**
   * Broadcast real-time data to all connected WebSocket clients
   */
  private _broadcastData(dataPoint: ISignalDataPoint): void {
    if (this._connectedClients.size === 0) return;

    const message = JSON.stringify({
      type: 'signal_data',
      data: dataPoint
    });

    this._connectedClients.forEach(client => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(message);
      }
    });
  }

  /**
   * Connect to PLC with automatic retry logic
   */
  async connect(): Promise<void> {
    if (this._isConnected || this._isConnecting) {
      return;
    }

    this._isConnecting = true;
    let attempts = 0;

    while (attempts <= this._config.retryAttempts! && !this._isConnected) {
      try {
        await this._attemptConnection();
        this._isConnecting = false;
        return;
      } catch (error) {
        attempts++;
        this._logger.warn(`Connection attempt ${attempts} failed`, { error: (error as Error).message });
        
        if (attempts <= this._config.retryAttempts!) {
          await this._delay(this._config.retryDelay!);
        }
      }
    }

    this._isConnecting = false;
    throw new Error(`Failed to connect to PLC after ${this._config.retryAttempts} attempts`);
  }

  /**
   * Attempt single connection to PLC
   */
  private _attemptConnection(): Promise<void> {
    return new Promise((resolve, reject) => {
      this._socket = new net.Socket();
      
      const timeout = setTimeout(() => {
        this._socket?.destroy();
        reject(new Error('Connection timeout'));
      }, this._config.timeout);

      this._socket.on('connect', () => {
        clearTimeout(timeout);
        this._isConnected = true;
        this._logger.info('Connected to PLC', { 
          host: this._config.host, 
          port: this._config.port 
        });
        
        this._setupKeepAlive();
        this.emit('connected', this._config);
        
        // Broadcast connection status
        this._broadcastConnectionStatus(true);
        
        resolve();
      });

      this._socket.on('error', (error) => {
        clearTimeout(timeout);
        this._logger.error('Socket error', { error: error.message });
        reject(error);
      });

      this._socket.on('close', () => {
        this._handleDisconnection();
      });

      this._socket.on('data', (data) => {
        this._handleIncomingData(data);
      });

      this._socket.connect(this._config.port!, this._config.host);
    });
  }

  /**
   * Handle PLC disconnection with auto-reconnect
   */
  private _handleDisconnection(): void {
    if (!this._isConnected) return;

    this._isConnected = false;
    this._logger.warn('Disconnected from PLC');
    this.emit('disconnected', this._config);
    
    // Broadcast disconnection status
    this._broadcastConnectionStatus(false);

    // Clear keep-alive timer
    if (this._keepAliveTimer) {
      clearInterval(this._keepAliveTimer);
      this._keepAliveTimer = null;
    }

    // Auto-reconnect after delay
    this._reconnectTimer = setTimeout(() => {
      this._logger.info('Attempting to reconnect...');
      this.connect().catch(error => {
        this._logger.error('Auto-reconnect failed', { error: error.message });
      });
    }, this._config.retryDelay);
  }

  /**
   * Broadcast connection status to WebSocket clients
   */
  private _broadcastConnectionStatus(connected: boolean): void {
    if (this._connectedClients.size === 0) return;

    const message = JSON.stringify({
      type: 'connection_status',
      connected,
      device: this._config.name,
      timestamp: Date.now()
    });

    this._connectedClients.forEach(client => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(message);
      }
    });
  }

  /**
   * Setup keep-alive mechanism
   */
  private _setupKeepAlive(): void {
    if (!this._config.keepAlive) return;

    this._keepAliveTimer = setInterval(() => {
      // Send a simple read request to keep connection alive
      this.readHoldingRegisters(0, 1).catch(error => {
        this._logger.warn('Keep-alive failed', { error: error.message });
      });
    }, 30000); // Every 30 seconds
  }

  /**
   * Read holding registers from PLC
   */
  async readHoldingRegisters(startAddress: number, quantity: number, unitId?: number): Promise<number[]> {
    const request: IModbusReadRequest = {
      functionCode: ModbusFunctionCode.READ_HOLDING_REGISTERS,
      startAddress,
      quantity,
      unitId: unitId || this._config.unitId!
    };

    const response = await this._sendModbusRequest(request);
    
    // Broadcast real-time data
    for (let i = 0; i < response.length; i++) {
      const dataPoint: ISignalDataPoint = {
        timestamp: Date.now(),
        address: startAddress + i,
        value: response[i],
        quality: 'good',
        deviceName: this._config.name,
        signalName: `HR${startAddress + i}`
      };
      
      this._broadcastData(dataPoint);
      this.emit('data', dataPoint);
    }

    return response;
  }

  /**
   * Read input registers from PLC
   */
  async readInputRegisters(startAddress: number, quantity: number, unitId?: number): Promise<number[]> {
    const request: IModbusReadRequest = {
      functionCode: ModbusFunctionCode.READ_INPUT_REGISTERS,
      startAddress,
      quantity,
      unitId: unitId || this._config.unitId!
    };

    return await this._sendModbusRequest(request);
  }

  /**
   * Read coils from PLC
   */
  async readCoils(startAddress: number, quantity: number, unitId?: number): Promise<boolean[]> {
    const request: IModbusReadRequest = {
      functionCode: ModbusFunctionCode.READ_COILS,
      startAddress,
      quantity,
      unitId: unitId || this._config.unitId!
    };

    return await this._sendModbusRequest(request);
  }

  /**
   * Write single holding register
   */
  async writeSingleRegister(address: number, value: number, unitId?: number): Promise<void> {
    const request: IModbusWriteRequest = {
      functionCode: ModbusFunctionCode.WRITE_SINGLE_REGISTER,
      startAddress: address,
      values: [value],
      unitId: unitId || this._config.unitId!
    };

    await this._sendModbusRequest(request);
    
    // Broadcast write confirmation
    const dataPoint: ISignalDataPoint = {
      timestamp: Date.now(),
      address,
      value,
      quality: 'good',
      deviceName: this._config.name,
      signalName: `HR${address}`
    };
    
    this._broadcastData(dataPoint);
    this.emit('write', dataPoint);
  }

  /**
   * Write multiple holding registers
   */
  async writeMultipleRegisters(startAddress: number, values: number[], unitId?: number): Promise<void> {
    const request: IModbusWriteRequest = {
      functionCode: ModbusFunctionCode.WRITE_MULTIPLE_REGISTERS,
      startAddress,
      values,
      unitId: unitId || this._config.unitId!
    };

    await this._sendModbusRequest(request);
  }

  /**
   * Send MODBUS request and wait for response
   */
  private async _sendModbusRequest(request: IModbusReadRequest | IModbusWriteRequest): Promise<any> {
    if (!this._isConnected || !this._socket) {
      throw new Error('Not connected to PLC');
    }

    const transactionId = this._transactionId++;
    const modbusFrame = this._buildModbusFrame(transactionId, request);

    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => {
        this._pendingRequests.delete(transactionId);
        reject(new Error('Request timeout'));
      }, this._config.timeout);

      this._pendingRequests.set(transactionId, {
        resolve,
        reject,
        timeout,
        request
      });

      this._socket!.write(modbusFrame);
    });
  }

  /**
   * Build MODBUS TCP frame
   */
  private _buildModbusFrame(transactionId: number, request: IModbusReadRequest | IModbusWriteRequest): Buffer {
    // This is a simplified MODBUS TCP frame builder
    // In production, you'd want to use a proper MODBUS library like modbus-stream
    const buffer = Buffer.alloc(12); // Basic frame size
    
    // MBAP Header
    buffer.writeUInt16BE(transactionId, 0);  // Transaction ID
    buffer.writeUInt16BE(0, 2);              // Protocol ID (0 for MODBUS)
    buffer.writeUInt16BE(6, 4);              // Length (PDU + Unit ID)
    buffer.writeUInt8(request.unitId!, 6);   // Unit ID
    
    // PDU
    buffer.writeUInt8(request.functionCode, 7);
    
    if ('quantity' in request) {
      // Read request
      buffer.writeUInt16BE(request.startAddress, 8);
      buffer.writeUInt16BE(request.quantity, 10);
    } else {
      // Write request - simplified
      buffer.writeUInt16BE(request.startAddress, 8);
      if (request.values.length === 1) {
        buffer.writeUInt16BE(request.values[0] as number, 10);
      }
    }

    return buffer;
  }

  /**
   * Handle incoming MODBUS response data
   */
  private _handleIncomingData(data: Buffer): void {
    // Parse MODBUS TCP response
    if (data.length < 8) return;

    const transactionId = data.readUInt16BE(0);
    const pendingRequest = this._pendingRequests.get(transactionId);
    
    if (!pendingRequest) return;

    this._pendingRequests.delete(transactionId);
    clearTimeout(pendingRequest.timeout);

    try {
      const response = this._parseModbusResponse(data, pendingRequest.request);
      pendingRequest.resolve(response);
    } catch (error) {
      pendingRequest.reject(error);
    }
  }

  /**
   * Parse MODBUS response frame
   */
  private _parseModbusResponse(data: Buffer, request: IModbusReadRequest | IModbusWriteRequest): any {
    // Simplified response parser
    const functionCode = data.readUInt8(7);
    
    if (functionCode & 0x80) {
      // Exception response
      const exceptionCode = data.readUInt8(8);
      throw new Error(`MODBUS Exception: ${exceptionCode}`);
    }

    if ('quantity' in request) {
      // Read response
      const byteCount = data.readUInt8(8);
      const values: (number | boolean)[] = [];
      
      if (request.functionCode === ModbusFunctionCode.READ_HOLDING_REGISTERS ||
          request.functionCode === ModbusFunctionCode.READ_INPUT_REGISTERS) {
        for (let i = 0; i < byteCount; i += 2) {
          values.push(data.readUInt16BE(9 + i));
        }
      } else if (request.functionCode === ModbusFunctionCode.READ_COILS ||
                 request.functionCode === ModbusFunctionCode.READ_DISCRETE_INPUTS) {
        // Parse coils/discrete inputs as booleans
        for (let i = 0; i < request.quantity; i++) {
          const byteIndex = Math.floor(i / 8);
          const bitIndex = i % 8;
          const byte = data.readUInt8(9 + byteIndex);
          values.push(Boolean(byte & (1 << bitIndex)));
        }
      }
      
      return values;
    } else {
      // Write response - just confirm success
      return true;
    }
  }

  /**
   * Utility delay function
   */
  private _delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  /**
   * Disconnect from PLC
   */
  async disconnect(): Promise<void> {
    if (this._reconnectTimer) {
      clearTimeout(this._reconnectTimer);
      this._reconnectTimer = null;
    }

    if (this._keepAliveTimer) {
      clearInterval(this._keepAliveTimer);
      this._keepAliveTimer = null;
    }

    if (this._socket) {
      this._socket.destroy();
      this._socket = null;
    }

    this._isConnected = false;
    this._logger.info('Disconnected from PLC');
    this.emit('disconnected', this._config);
  }

  /**
   * Get connection status
   */
  get isConnected(): boolean {
    return this._isConnected;
  }

  /**
   * Get PLC configuration
   */
  get config(): IPLCConfig {
    return { ...this._config };
  }

  /**
   * Close WebSocket server
   */
  async close(): Promise<void> {
    await this.disconnect();
    
    if (this._wsServer) {
      this._wsServer.close();
      this._wsServer = null;
    }

    this._connectedClients.clear();
    this._logger.info('PocketSocket PLC closed');
  }
}

export default PocketSocketPLC;
