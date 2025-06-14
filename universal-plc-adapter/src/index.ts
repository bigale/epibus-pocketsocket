import { EventEmitter } from 'events';
// @ts-ignore - Will be available at runtime
import { PocketSocketPLC, IPLCConfig, ISignalDataPoint } from '@ai-kit/pocketsocket-plc';
// @ts-ignore - Will be available at runtime
import winston from 'winston';
// @ts-ignore - Will be available at runtime  
import _ from 'lodash';

/**
 * Universal Signal Configuration
 * Maps EpiBus DocType structure to AI-Kit universal patterns
 */
export interface IUniversalSignal {
  id: string;
  name: string;
  description?: string;
  deviceName: string;
  address: number;
  dataType: 'int16' | 'int32' | 'float32' | 'bool' | 'string';
  accessType: 'read' | 'write' | 'readwrite';
  scalingFactor?: number;
  offset?: number;
  unit?: string;
  alarmLimits?: {
    high?: number;
    low?: number;
    critical?: number;
  };
  tags: string[];
  category: 'process' | 'control' | 'status' | 'alarm' | 'diagnostic';
  characterAgent?: 'kyoko' | 'byakuya' | 'chihiro' | 'celestia' | 'sakura';
  isActive: boolean;
  pollInterval?: number; // ms
  lastValue?: number | boolean;
  lastTimestamp?: number;
  quality: 'good' | 'bad' | 'uncertain';
}

/**
 * Universal Action Configuration
 * Maps EpiBus Action DocType to AI-Kit character-driven actions
 */
export interface IUniversalAction {
  id: string;
  name: string;
  description: string;
  deviceName: string;
  actionType: 'write_register' | 'write_coil' | 'sequence' | 'conditional';
  targetSignals: string[]; // Signal IDs
  parameters: Record<string, any>;
  conditions?: {
    triggerSignals: string[];
    logic: string; // JavaScript expression
  };
  characterAgent: 'kyoko' | 'byakuya' | 'chihiro' | 'celestia' | 'sakura';
  priority: 'low' | 'medium' | 'high' | 'critical';
  isActive: boolean;
  lastExecuted?: number;
  executionCount: number;
}

/**
 * Universal Device Configuration
 * Extends PLC config with AI-Kit universal patterns
 */
export interface IUniversalDevice {
  id: string;
  name: string;
  description?: string;
  host: string;
  port?: number;
  unitId?: number;
  timeout?: number;
  retryAttempts?: number;
  retryDelay?: number;
  keepAlive?: boolean;
  type: 'modbus_tcp' | 'modbus_rtu' | 'ethernet_ip' | 'profinet' | 'opc_ua';
  characterAgent: 'kyoko' | 'byakuya' | 'chihiro' | 'celestia' | 'sakura';
  signals: IUniversalSignal[];
  actions: IUniversalAction[];
  tags: string[];
  location?: string;
  manufacturer?: string;
  model?: string;
  firmware?: string;
  isActive: boolean;
  lastSeen?: number;
  healthStatus: 'healthy' | 'warning' | 'error' | 'offline';
}

/**
 * Pattern Database Integration Interface
 */
export interface IPatternData {
  timestamp: number;
  deviceId: string;
  signalId: string;
  value: number | boolean;
  pattern: string;
  confidence: number;
  characterAgent: string;
  context: Record<string, any>;
}

/**
 * Revolutionary Universal PLC Adapter
 * 
 * This class provides a universal abstraction layer over industrial PLCs,
 * integrating with AI-Kit's pattern database and character-driven intelligence.
 * It transforms traditional PLC operations into character-enhanced, pattern-aware
 * industrial automation experiences.
 */
export class UniversalPLCAdapter extends EventEmitter {
  private _devices: Map<string, IUniversalDevice> = new Map();
  private _connections: Map<string, PocketSocketPLC> = new Map();
  private _signalPollers: Map<string, NodeJS.Timeout> = new Map();
  private _logger: winston.Logger;
  private _isRunning: boolean = false;
  private _patternBuffer: IPatternData[] = [];
  private _patternBufferSize: number = 1000;

  constructor() {
    super();
    
    this._logger = winston.createLogger({
      level: 'info',
      format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.json()
      ),
      defaultMeta: { service: 'universal-plc-adapter' },
      transports: [
        new winston.transports.Console(),
        new winston.transports.File({ filename: 'universal-plc-adapter.log' })
      ]
    });

    this._logger.info('Universal PLC Adapter initialized');
  }

  /**
   * Register a new universal device
   */
  async registerDevice(device: IUniversalDevice): Promise<void> {
    this._logger.info('Registering device', { deviceId: device.id, name: device.name });
    
    // Validate device configuration
    if (!device.id || !device.name || !device.host) {
      throw new Error('Invalid device configuration: missing required fields');
    }

    this._devices.set(device.id, device);
    
    // Create PLC connection
    const plcConfig: IPLCConfig = {
      host: device.host,
      port: device.port,
      unitId: device.unitId,
      timeout: device.timeout,
      retryAttempts: device.retryAttempts,
      retryDelay: device.retryDelay,
      keepAlive: device.keepAlive,
      name: device.name,
      description: device.description
    };

    const plcConnection = new PocketSocketPLC(plcConfig);
    
    // Setup event handlers
    plcConnection.on('connected', () => {
      device.healthStatus = 'healthy';
      device.lastSeen = Date.now();
      this._logger.info('Device connected', { deviceId: device.id });
      this.emit('device_connected', device);
    });

    plcConnection.on('disconnected', () => {
      device.healthStatus = 'offline';
      this._logger.warn('Device disconnected', { deviceId: device.id });
      this.emit('device_disconnected', device);
    });

    plcConnection.on('data', (dataPoint: ISignalDataPoint) => {
      this._handleSignalData(device.id, dataPoint);
    });

    this._connections.set(device.id, plcConnection);

    // Connect to device
    try {
      await plcConnection.connect();
      this._setupSignalPolling(device);
    } catch (error) {
      this._logger.error('Failed to connect to device', { 
        deviceId: device.id, 
        error: (error as Error).message 
      });
      device.healthStatus = 'error';
      throw error;
    }
  }

  /**
   * Setup signal polling for device
   */
  private _setupSignalPolling(device: IUniversalDevice): void {
    const connection = this._connections.get(device.id);
    if (!connection) return;

    // Group signals by poll interval
    const pollGroups = _.groupBy(
      device.signals.filter(s => s.isActive && s.accessType !== 'write'),
      'pollInterval'
    );

    Object.entries(pollGroups).forEach(([interval, signals]) => {
      const pollInterval = parseInt(interval) || 1000; // Default 1 second
      
      const pollerId = `${device.id}_${interval}`;
      const timer = setInterval(async () => {
        try {
          await this._pollSignalGroup(device.id, signals as IUniversalSignal[]);
        } catch (error) {
          this._logger.error('Signal polling error', {
            deviceId: device.id,
            interval,
            error: (error as Error).message
          });
        }
      }, pollInterval);

      this._signalPollers.set(pollerId, timer);
    });
  }

  /**
   * Poll a group of signals with same interval
   */
  private async _pollSignalGroup(deviceId: string, signals: IUniversalSignal[]): Promise<void> {
    const connection = this._connections.get(deviceId);
    if (!connection || !connection.isConnected) return;

    // Group by address ranges for efficient bulk reads
    const holdingRegisters = signals.filter(s => 
      s.dataType !== 'bool' && s.accessType !== 'write'
    );
    
    const coils = signals.filter(s => 
      s.dataType === 'bool' && s.accessType !== 'write'
    );

    // Read holding registers in bulk
    if (holdingRegisters.length > 0) {
      const ranges = this._optimizeAddressRanges(holdingRegisters);
      
      for (const range of ranges) {
        try {
          const values = await connection.readHoldingRegisters(
            range.startAddress, 
            range.quantity
          );
          
          range.signals.forEach((signal, index) => {
            const rawValue = values[index];
            const scaledValue = this._applyScaling(signal, rawValue);
            this._updateSignalValue(deviceId, signal, scaledValue);
          });
        } catch (error) {
          this._logger.error('Failed to read holding registers', {
            deviceId,
            range,
            error: (error as Error).message
          });
        }
      }
    }

    // Read coils in bulk
    if (coils.length > 0) {
      const ranges = this._optimizeAddressRanges(coils);
      
      for (const range of ranges) {
        try {
          const values = await connection.readCoils(
            range.startAddress,
            range.quantity
          );
          
          range.signals.forEach((signal, index) => {
            this._updateSignalValue(deviceId, signal, values[index]);
          });
        } catch (error) {
          this._logger.error('Failed to read coils', {
            deviceId,
            range,
            error: (error as Error).message
          });
        }
      }
    }
  }

  /**
   * Optimize address ranges for bulk reading
   */
  private _optimizeAddressRanges(signals: IUniversalSignal[]): Array<{
    startAddress: number;
    quantity: number;
    signals: IUniversalSignal[];
  }> {
    // Sort signals by address
    const sortedSignals = signals.sort((a, b) => a.address - b.address);
    const ranges: Array<{
      startAddress: number;
      quantity: number;
      signals: IUniversalSignal[];
    }> = [];

    let currentRange: {
      startAddress: number;
      quantity: number;
      signals: IUniversalSignal[];
    } | null = null;

    sortedSignals.forEach(signal => {
      if (!currentRange) {
        currentRange = {
          startAddress: signal.address,
          quantity: 1,
          signals: [signal]
        };
      } else if (signal.address <= currentRange.startAddress + currentRange.quantity + 5) {
        // Extend current range if addresses are close (within 5 registers)
        currentRange.quantity = signal.address - currentRange.startAddress + 1;
        currentRange.signals.push(signal);
      } else {
        // Start new range
        ranges.push(currentRange);
        currentRange = {
          startAddress: signal.address,
          quantity: 1,
          signals: [signal]
        };
      }
    });

    if (currentRange) {
      ranges.push(currentRange);
    }

    return ranges;
  }

  /**
   * Apply scaling and offset to raw signal value
   */
  private _applyScaling(signal: IUniversalSignal, rawValue: number): number {
    let scaledValue = rawValue;
    
    if (signal.scalingFactor) {
      scaledValue *= signal.scalingFactor;
    }
    
    if (signal.offset) {
      scaledValue += signal.offset;
    }
    
    return scaledValue;
  }

  /**
   * Update signal value and trigger pattern detection
   */
  private _updateSignalValue(deviceId: string, signal: IUniversalSignal, value: number | boolean): void {
    const previousValue = signal.lastValue;
    signal.lastValue = value;
    signal.lastTimestamp = Date.now();
    signal.quality = 'good';

    // Emit signal update event
    this.emit('signal_update', {
      deviceId,
      signal,
      value,
      previousValue,
      timestamp: signal.lastTimestamp
    });

    // Check alarm conditions
    if (typeof value === 'number' && signal.alarmLimits) {
      this._checkAlarmConditions(deviceId, signal, value);
    }

    // Add to pattern buffer for AI analysis
    this._addToPatternBuffer({
      timestamp: signal.lastTimestamp!,
      deviceId,
      signalId: signal.id,
      value,
      pattern: this._detectBasicPattern(signal, value),
      confidence: 0.8,
      characterAgent: signal.characterAgent || 'kyoko',
      context: {
        category: signal.category,
        tags: signal.tags,
        unit: signal.unit
      }
    });
  }

  /**
   * Basic pattern detection (will be enhanced with SUIL)
   */
  private _detectBasicPattern(signal: IUniversalSignal, value: number | boolean): string {
    if (typeof value === 'boolean') {
      return value ? 'on' : 'off';
    }

    if (signal.alarmLimits) {
      if (signal.alarmLimits.critical && value > signal.alarmLimits.critical) {
        return 'critical_high';
      }
      if (signal.alarmLimits.high && value > signal.alarmLimits.high) {
        return 'alarm_high';
      }
      if (signal.alarmLimits.low && value < signal.alarmLimits.low) {
        return 'alarm_low';
      }
    }

    return 'normal';
  }

  /**
   * Check alarm conditions and emit alerts
   */
  private _checkAlarmConditions(deviceId: string, signal: IUniversalSignal, value: number): void {
    if (!signal.alarmLimits) return;

    const alarms: string[] = [];

    if (signal.alarmLimits.critical && value > signal.alarmLimits.critical) {
      alarms.push('critical_high');
    }
    if (signal.alarmLimits.high && value > signal.alarmLimits.high) {
      alarms.push('high');
    }
    if (signal.alarmLimits.low && value < signal.alarmLimits.low) {
      alarms.push('low');
    }

    if (alarms.length > 0) {
      this.emit('alarm', {
        deviceId,
        signalId: signal.id,
        signalName: signal.name,
        value,
        alarms,
        timestamp: Date.now(),
        characterAgent: signal.characterAgent
      });
    }
  }

  /**
   * Add data to pattern buffer for AI analysis
   */
  private _addToPatternBuffer(data: IPatternData): void {
    this._patternBuffer.push(data);
    
    // Keep buffer size manageable
    if (this._patternBuffer.length > this._patternBufferSize) {
      this._patternBuffer = this._patternBuffer.slice(-this._patternBufferSize);
    }

    // Emit pattern data for SUIL processing
    this.emit('pattern_data', data);
  }

  /**
   * Execute universal action
   */
  async executeAction(deviceId: string, actionId: string, parameters?: Record<string, any>): Promise<void> {
    const device = this._devices.get(deviceId);
    const connection = this._connections.get(deviceId);
    
    if (!device || !connection) {
      throw new Error(`Device ${deviceId} not found or not connected`);
    }

    const action = device.actions.find(a => a.id === actionId);
    if (!action) {
      throw new Error(`Action ${actionId} not found on device ${deviceId}`);
    }

    if (!action.isActive) {
      throw new Error(`Action ${actionId} is not active`);
    }

    this._logger.info('Executing action', { deviceId, actionId, parameters });

    try {
      switch (action.actionType) {
        case 'write_register':
          await this._executeWriteRegister(device, action, connection, parameters);
          break;
        case 'write_coil':
          await this._executeWriteCoil(device, action, connection, parameters);
          break;
        case 'sequence':
          await this._executeSequence(device, action, connection, parameters);
          break;
        case 'conditional':
          await this._executeConditional(device, action, connection, parameters);
          break;
        default:
          throw new Error(`Unsupported action type: ${action.actionType}`);
      }

      action.lastExecuted = Date.now();
      action.executionCount++;

      this.emit('action_executed', {
        deviceId,
        action,
        parameters,
        timestamp: action.lastExecuted
      });

    } catch (error) {
      this._logger.error('Action execution failed', {
        deviceId,
        actionId,
        error: (error as Error).message
      });
      
      this.emit('action_failed', {
        deviceId,
        action,
        error: (error as Error).message,
        timestamp: Date.now()
      });
      
      throw error;
    }
  }

  /**
   * Execute write register action
   */
  private async _executeWriteRegister(
    device: IUniversalDevice,
    action: IUniversalAction,
    connection: PocketSocketPLC,
    parameters?: Record<string, any>
  ): Promise<void> {
    const targetSignal = device.signals.find(s => s.id === action.targetSignals[0]);
    if (!targetSignal) {
      throw new Error(`Target signal ${action.targetSignals[0]} not found`);
    }

    const value = parameters?.value ?? action.parameters.value;
    if (value === undefined) {
      throw new Error('No value specified for write register action');
    }

    await connection.writeSingleRegister(targetSignal.address, value);
  }

  /**
   * Execute write coil action
   */
  private async _executeWriteCoil(
    device: IUniversalDevice,
    action: IUniversalAction,
    connection: PocketSocketPLC,
    parameters?: Record<string, any>
  ): Promise<void> {
    // Implementation for coil writing would go here
    // For now, using register write as placeholder
    await this._executeWriteRegister(device, action, connection, parameters);
  }

  /**
   * Execute sequence action
   */
  private async _executeSequence(
    device: IUniversalDevice,
    action: IUniversalAction,
    connection: PocketSocketPLC,
    parameters?: Record<string, any>
  ): Promise<void> {
    const sequence = action.parameters.sequence as Array<{
      signalId: string;
      value: number | boolean;
      delay?: number;
    }>;

    for (const step of sequence) {
      const signal = device.signals.find(s => s.id === step.signalId);
      if (!signal) {
        this._logger.warn(`Signal ${step.signalId} not found in sequence`);
        continue;
      }

      if (signal.dataType === 'bool') {
        // Write coil - implementation needed
      } else {
        await connection.writeSingleRegister(signal.address, step.value as number);
      }

      if (step.delay) {
        await this._delay(step.delay);
      }
    }
  }

  /**
   * Execute conditional action
   */
  private async _executeConditional(
    device: IUniversalDevice,
    action: IUniversalAction,
    connection: PocketSocketPLC,
    parameters?: Record<string, any>
  ): Promise<void> {
    if (!action.conditions) {
      throw new Error('Conditional action missing conditions');
    }

    // Evaluate condition logic
    const triggerValues: Record<string, any> = {};
    for (const signalId of action.conditions.triggerSignals) {
      const signal = device.signals.find(s => s.id === signalId);
      if (signal) {
        triggerValues[signalId] = signal.lastValue;
      }
    }

    // Simple logic evaluation (in production, use a proper expression evaluator)
    const conditionMet = eval(action.conditions.logic.replace(
      /\$(\w+)/g, 
      (_, signalId) => triggerValues[signalId] ?? 'undefined'
    ));

    if (conditionMet) {
      // Execute the main action
      const mainAction = action.parameters.action;
      await this.executeAction(device.id, mainAction.actionId, mainAction.parameters);
    }
  }

  /**
   * Get all pattern data for SUIL analysis
   */
  getPatternData(): IPatternData[] {
    return [...this._patternBuffer];
  }

  /**
   * Clear pattern buffer
   */
  clearPatternData(): void {
    this._patternBuffer = [];
  }

  /**
   * Get device by ID
   */
  getDevice(deviceId: string): IUniversalDevice | undefined {
    return this._devices.get(deviceId);
  }

  /**
   * Get all devices
   */
  getAllDevices(): IUniversalDevice[] {
    return Array.from(this._devices.values());
  }

  /**
   * Get device connection status
   */
  getConnectionStatus(deviceId: string): boolean {
    const connection = this._connections.get(deviceId);
    return connection?.isConnected ?? false;
  }

  /**
   * Handle incoming signal data from PocketSocket
   */
  private _handleSignalData(deviceId: string, dataPoint: ISignalDataPoint): void {
    const device = this._devices.get(deviceId);
    if (!device) return;

    const signal = device.signals.find(s => s.address === dataPoint.address);
    if (signal) {
      this._updateSignalValue(deviceId, signal, dataPoint.value);
    }
  }

  /**
   * Utility delay function
   */
  private _delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  /**
   * Start the universal adapter
   */
  async start(): Promise<void> {
    if (this._isRunning) return;

    this._isRunning = true;
    this._logger.info('Universal PLC Adapter started');
    this.emit('adapter_started');
  }

  /**
   * Stop the universal adapter
   */
  async stop(): Promise<void> {
    if (!this._isRunning) return;

    this._isRunning = false;

    // Stop all signal pollers
    this._signalPollers.forEach(timer => clearInterval(timer));
    this._signalPollers.clear();

    // Disconnect all devices
    for (const [deviceId, connection] of this._connections) {
      try {
        await connection.disconnect();
      } catch (error) {
        this._logger.error(`Failed to disconnect device ${deviceId}`, {
          error: (error as Error).message
        });
      }
    }

    this._connections.clear();
    this._logger.info('Universal PLC Adapter stopped');
    this.emit('adapter_stopped');
  }
}

export default UniversalPLCAdapter;
