import * as RED from 'node-red';
import express from 'express';
import { createServer, Server } from 'http';
import cors from 'cors';
import { WebSocketServer } from 'ws';
import { EventEmitter } from 'events';
import winston from 'winston';
import path from 'path';
import fs from 'fs';

/**
 * Character-Driven Node-RED PLC Simulator
 * 
 * This class creates and manages individual Node-RED instances for each character,
 * providing unique simulation environments with personality-driven features.
 */

interface CharacterConfig {
  id: string;
  name: string;
  personality: string;
  expertise: string;
  port: number;
  modbusPort: number;
  theme: string;
  specialNodes: string[];
}

interface SimulationScenario {
  id: string;
  name: string;
  description: string;
  flows: any[];
  modbusConfig: any;
  dashboardConfig: any;
}

export class CharacterSimulator extends EventEmitter {
  private character: CharacterConfig;
  private nodeRedApp: any;
  private expressApp!: express.Application;
  private httpServer!: Server;
  private wsServer!: WebSocketServer;
  private logger!: winston.Logger;
  private isRunning: boolean = false;

  constructor(characterId: string) {
    super();
    
    this.character = this.getCharacterConfig(characterId);
    this.setupLogger();
    this.setupExpress();
    this.setupWebSocket();
    this.setupNodeRed();
  }

  /**
   * Get character-specific configuration
   */
  private getCharacterConfig(characterId: string): CharacterConfig {
    const configs: Record<string, CharacterConfig> = {
      kyoko: {
        id: 'kyoko',
        name: 'Kyoko Kirigiri',
        personality: 'Analytical detective with keen investigation skills',
        expertise: 'Anomaly detection, root cause analysis, mystery solving',
        port: 1881,
        modbusPort: 5020,
        theme: 'detective-purple',
        specialNodes: [
          'anomaly-detector',
          'evidence-collector',
          'investigation-flow',
          'mystery-generator'
        ]
      },
      byakuya: {
        id: 'byakuya',
        name: 'Byakuya Togami',
        personality: 'Efficiency-focused perfectionist with strategic mind',
        expertise: 'Process optimization, performance analysis, cost reduction',
        port: 1882,
        modbusPort: 5021,
        theme: 'efficiency-blue',
        specialNodes: [
          'performance-optimizer',
          'kpi-monitor',
          'cost-analyzer',
          'lean-processor'
        ]
      },
      chihiro: {
        id: 'chihiro',
        name: 'Chihiro Fujisaki',
        personality: 'Technical genius with innovative programming skills',
        expertise: 'Advanced protocols, system integration, algorithm development',
        port: 1883,
        modbusPort: 5022,
        theme: 'tech-green',
        specialNodes: [
          'protocol-bridge',
          'system-integrator',
          'algorithm-tester',
          'innovation-lab'
        ]
      },
      celestia: {
        id: 'celestia',
        name: 'Celestia Ludenberg',
        personality: 'Elegant perfectionist with dramatic flair',
        expertise: 'UI/UX design, visualization, aesthetic optimization',
        port: 1884,
        modbusPort: 5023,
        theme: 'elegant-red',
        specialNodes: [
          'beauty-enhancer',
          'visualization-master',
          'aesthetic-optimizer',
          'dramatic-effects'
        ]
      },
      sakura: {
        id: 'sakura',
        name: 'Sakura Ogami',
        personality: 'Strong and reliable with focus on endurance',
        expertise: 'Performance testing, load simulation, reliability analysis',
        port: 1885,
        modbusPort: 5024,
        theme: 'strength-orange',
        specialNodes: [
          'stress-tester',
          'endurance-monitor',
          'load-generator',
          'reliability-analyzer'
        ]
      }
    };

    const config = configs[characterId];
    if (!config) {
      throw new Error(`Unknown character: ${characterId}`);
    }

    return config;
  }

  /**
   * Setup Winston logger with character-specific configuration
   */
  private setupLogger(): void {
    this.logger = winston.createLogger({
      level: 'info',
      format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.colorize(),
        winston.format.printf(({ timestamp, level, message }) => {
          return `[${timestamp}] [${this.character.name}] ${level}: ${message}`;
        })
      ),
      transports: [
        new winston.transports.Console(),
        new winston.transports.File({ 
          filename: `logs/${this.character.id}-simulator.log` 
        })
      ]
    });
  }

  /**
   * Setup Express server for REST API
   */
  private setupExpress(): void {
    this.expressApp = express();
    this.httpServer = createServer(this.expressApp);
    this.expressApp.use(cors());
    this.expressApp.use(express.json());

    // Character info endpoint
    this.expressApp.get('/api/character', (req, res) => {
      res.json({
        ...this.character,
        status: this.isRunning ? 'running' : 'stopped',
        uptime: this.isRunning ? process.uptime() : 0
      });
    });

    // Simulation control endpoints
    this.expressApp.post('/api/scenario/:scenarioId', (req, res) => {
      this.loadScenario(req.params.scenarioId)
        .then(() => res.json({ success: true }))
        .catch(err => res.status(500).json({ error: err.message }));
    });

    // Character-specific actions
    this.expressApp.post('/api/character-action', (req, res) => {
      this.executeCharacterAction(req.body)
        .then(result => res.json(result))
        .catch(err => res.status(500).json({ error: err.message }));
    });

    // Debug logging endpoint for Node-RED flows
    this.expressApp.post('/api/debug-log', (req, res) => {
      const { nodeId, message, data, level = 'info' } = req.body;
      
      // Log with character context
      const logData = {
        character: this.character.id,
        nodeId,
        data,
        timestamp: new Date().toISOString()
      };

      // Use proper logger methods
      switch (level) {
        case 'error':
          this.logger.error(`[${nodeId}] ${message}`, logData);
          break;
        case 'warn':
          this.logger.warn(`[${nodeId}] ${message}`, logData);
          break;
        case 'debug':
          this.logger.debug(`[${nodeId}] ${message}`, logData);
          break;
        default:
          this.logger.info(`[${nodeId}] ${message}`, logData);
      }

      // Also emit via WebSocket for real-time monitoring
      this.emit('debug-log', {
        character: this.character.id,
        nodeId,
        message,
        data,
        level,
        timestamp: new Date().toISOString()
      });

      res.json({ success: true });
    });
  }

  /**
   * Setup WebSocket server for real-time communication
   * This integrates with Node-RED's WebSocket handling
   */
  private setupWebSocket(): void {
    // Note: Node-RED will handle its own WebSocket connections at /comms
    // We'll set up character-specific WebSocket after Node-RED starts
    // For now, this is a placeholder - WebSocket setup happens in start()
  }

  /**
   * Setup Node-RED instance with character-specific configuration
   */
  private setupNodeRed(): void {
    const settings = {
      httpAdminRoot: '/',
      httpNodeRoot: '/api',
      userDir: path.join(__dirname, '..', 'data', this.character.id),
      flowFile: `${this.character.id}-flows.json`,
      credentialSecret: `${this.character.id}-secret-key`,
      uiPort: this.character.port,
      uiHost: 'localhost',
      functionGlobalContext: {
        character: this.character,
        logger: this.logger
      },
      editorTheme: {
        page: {
          title: `${this.character.name}'s PLC Simulator`,
          favicon: `/themes/${this.character.theme}/favicon.ico`
        },
        header: {
          title: `🎭 ${this.character.name}'s Industrial Simulator`,
          image: `/themes/${this.character.theme}/logo.png`
        },
        deployButton: {
          type: 'simple',
          label: `Deploy ${this.character.name}'s Flow`
        },
        menu: {
          'menu-item-keyboard-shortcuts': false,
          'menu-item-help': {
            label: `${this.character.name}'s Help`,
            url: `/help/${this.character.id}`
          }
        },
        palette: {
          categories: [
            'character-specific',
            'modbus',
            'dashboard',
            'industrial',
            'analysis'
          ]
        },
        projects: {
          enabled: true,
          workflow: {
            mode: 'auto'
          }
        }
      },
      nodesDir: [
        path.join(__dirname, '..', 'nodes', 'common'),
        path.join(__dirname, '..', 'nodes', this.character.id)
      ]
    };

    // Initialize Node-RED with our HTTP server
    this.nodeRedApp = RED;
    this.nodeRedApp.init(this.httpServer, settings);
    
    // Mount Node-RED admin interface and flows
    this.expressApp.use(settings.httpAdminRoot, RED.httpAdmin);
    this.expressApp.use(settings.httpNodeRoot, RED.httpNode);
    
    // Add our custom API endpoints to our Express app
    this.expressApp.get('/api/character', (req: any, res: any) => {
      res.json({
        ...this.character,
        status: this.isRunning ? 'running' : 'stopped',
        uptime: this.isRunning ? process.uptime() : 0
      });
    });

    this.expressApp.post('/api/scenario/:scenarioId', (req: any, res: any) => {
      this.loadScenario(req.params.scenarioId)
        .then(() => res.json({ success: true }))
        .catch(err => res.status(500).json({ error: err.message }));
    });

    this.expressApp.post('/api/character-action', (req: any, res: any) => {
      this.executeCharacterAction(req.body)
        .then(result => res.json(result))
        .catch(err => res.status(500).json({ error: err.message }));
    });
  }

  /**
   * Start the character simulator
   */
  async start(): Promise<void> {
    try {
      this.logger.info(`Starting ${this.character.name}'s PLC simulator...`);

      // Ensure data directory exists
      await this.ensureDataDirectory();

      // Install character-specific nodes
      await this.installCharacterNodes();

      // Load default scenario
      await this.loadDefaultScenario();

      // Start Node-RED
      await this.nodeRedApp.start();

      // Start our HTTP server (which Node-RED is now attached to)
      this.httpServer.listen(this.character.port, () => {
        this.logger.info(`${this.character.name}'s simulator running on port ${this.character.port}`);
        this.logger.info(`Dashboard: http://localhost:${this.character.port}`);
        this.logger.info(`MODBUS Server: localhost:${this.character.modbusPort}`);
      });

      this.isRunning = true;
      this.emit('started', this.character);

      // Setup graceful shutdown
      process.on('SIGINT', () => this.stop());
      process.on('SIGTERM', () => this.stop());

    } catch (error) {
      this.logger.error(`Failed to start ${this.character.name}'s simulator: ${error}`);
      throw error;
    }
  }

  /**
   * Stop the character simulator
   */
  async stop(): Promise<void> {
    try {
      this.logger.info(`Stopping ${this.character.name}'s PLC simulator...`);
      
      await this.nodeRedApp.stop();
      if (this.wsServer) {
        this.wsServer.close();
      }
      this.httpServer.close();
      this.isRunning = false;
      
      this.emit('stopped', this.character);
      this.logger.info(`${this.character.name}'s simulator stopped successfully`);
      
    } catch (error) {
      this.logger.error(`Error stopping ${this.character.name}'s simulator: ${error}`);
      throw error;
    }
  }

  /**
   * Load a simulation scenario
   */
  private async loadScenario(scenarioId: string): Promise<void> {
    try {
      const scenarioPath = path.join(__dirname, '..', 'scenarios', this.character.id, `${scenarioId}.json`);
      
      if (!fs.existsSync(scenarioPath)) {
        throw new Error(`Scenario ${scenarioId} not found for ${this.character.name}`);
      }

      const scenario: SimulationScenario = JSON.parse(fs.readFileSync(scenarioPath, 'utf8'));
      
      this.logger.info(`Loading scenario: ${scenario.name} for ${this.character.name}`);
      
      // Deploy flows to Node-RED
      await this.nodeRedApp.nodes.setFlows(scenario.flows);
      
      // Configure MODBUS servers
      await this.setupModbusServers(scenario.modbusConfig);
      
      // Update dashboard configuration
      await this.updateDashboard(scenario.dashboardConfig);
      
      this.emit('scenario-loaded', { character: this.character, scenario });
      
    } catch (error) {
      this.logger.error(`Failed to load scenario ${scenarioId}: ${error}`);
      throw error;
    }
  }

  /**
   * Execute character-specific action
   */
  private async executeCharacterAction(action: any): Promise<any> {
    this.logger.info(`Executing character action: ${action.type} for ${this.character.name}`);
    
    switch (this.character.id) {
      case 'kyoko':
        return this.executeKyokoAction(action);
      case 'byakuya':
        return this.executeByakuyaAction(action);
      case 'chihiro':
        return this.executeChihiroAction(action);
      case 'celestia':
        return this.executeCelestiaAction(action);
      case 'sakura':
        return this.executeSakuraAction(action);
      default:
        throw new Error(`Unknown character action for ${this.character.id}`);
    }
  }

  /**
   * Character-specific action implementations
   */
  private async executeKyokoAction(action: any): Promise<any> {
    switch (action.type) {
      case 'inject_anomaly':
        return this.injectAnomaly(action.params);
      case 'start_investigation':
        return this.startInvestigation(action.params);
      case 'analyze_evidence':
        return this.analyzeEvidence(action.params);
      default:
        throw new Error(`Unknown Kyoko action: ${action.type}`);
    }
  }

  private async executeByakuyaAction(action: any): Promise<any> {
    switch (action.type) {
      case 'optimize_performance':
        return this.optimizePerformance(action.params);
      case 'analyze_efficiency':
        return this.analyzeEfficiency(action.params);
      case 'reduce_costs':
        return this.reduceCosts(action.params);
      default:
        throw new Error(`Unknown Byakuya action: ${action.type}`);
    }
  }

  private async executeChihiroAction(action: any): Promise<any> {
    switch (action.type) {
      case 'integrate_system':
        return this.integrateSystem(action.params);
      case 'test_algorithm':
        return this.testAlgorithm(action.params);
      case 'innovate_solution':
        return this.innovateSolution(action.params);
      default:
        throw new Error(`Unknown Chihiro action: ${action.type}`);
    }
  }

  private async executeCelestiaAction(action: any): Promise<any> {
    switch (action.type) {
      case 'enhance_beauty':
        return this.enhanceBeauty(action.params);
      case 'optimize_aesthetics':
        return this.optimizeAesthetics(action.params);
      case 'create_drama':
        return this.createDrama(action.params);
      default:
        throw new Error(`Unknown Celestia action: ${action.type}`);
    }
  }

  private async executeSakuraAction(action: any): Promise<any> {
    switch (action.type) {
      case 'stress_test':
        return this.stressTest(action.params);
      case 'endurance_test':
        return this.enduranceTest(action.params);
      case 'analyze_reliability':
        return this.analyzeReliability(action.params);
      default:
        throw new Error(`Unknown Sakura action: ${action.type}`);
    }
  }

  // Utility methods
  private async ensureDataDirectory(): Promise<void> {
    const dataDir = path.join(__dirname, '..', 'data', this.character.id);
    if (!fs.existsSync(dataDir)) {
      fs.mkdirSync(dataDir, { recursive: true });
    }
  }

  private async installCharacterNodes(): Promise<void> {
    // Install character-specific Node-RED nodes
    for (const nodeType of this.character.specialNodes) {
      this.logger.info(`Installing ${nodeType} node for ${this.character.name}`);
      // Implementation for dynamic node installation
    }
  }

  private async loadDefaultScenario(): Promise<void> {
    const defaultScenario = `${this.character.id}_default`;
    try {
      await this.loadScenario(defaultScenario);
    } catch (error) {
      this.logger.warn(`No default scenario found for ${this.character.name}, using empty flows`);
    }
  }

  private async setupModbusServers(config: any): Promise<void> {
    // Configure MODBUS/TCP servers for the character
    this.logger.info(`Setting up MODBUS servers on port ${this.character.modbusPort} for ${this.character.name}`);
  }

  private async updateDashboard(config: any): Promise<void> {
    // Update Node-RED dashboard with character-specific configuration
    this.logger.info(`Updating dashboard configuration for ${this.character.name}`);
  }

  private handleWebSocketMessage(ws: any, message: any): void {
    // Handle real-time WebSocket messages
    this.logger.debug(`WebSocket message received: ${message.type}`);
  }

  // Character-specific action implementations (placeholders)
  private async injectAnomaly(params: any): Promise<any> {
    this.logger.info(`Kyoko injecting anomaly: ${JSON.stringify(params)}`);
    return { success: true, message: 'Anomaly injected for investigation' };
  }

  private async startInvestigation(params: any): Promise<any> {
    this.logger.info(`Kyoko starting investigation: ${JSON.stringify(params)}`);
    return { success: true, investigation_id: `inv_${Date.now()}` };
  }

  private async analyzeEvidence(params: any): Promise<any> {
    this.logger.info(`Kyoko analyzing evidence: ${JSON.stringify(params)}`);
    return { success: true, evidence_analysis: 'Suspicious patterns detected' };
  }

  private async optimizePerformance(params: any): Promise<any> {
    this.logger.info(`Byakuya optimizing performance: ${JSON.stringify(params)}`);
    return { success: true, optimization_result: '15% efficiency improvement' };
  }

  private async analyzeEfficiency(params: any): Promise<any> {
    this.logger.info(`Byakuya analyzing efficiency: ${JSON.stringify(params)}`);
    return { success: true, efficiency_score: 0.87 };
  }

  private async reduceCosts(params: any): Promise<any> {
    this.logger.info(`Byakuya reducing costs: ${JSON.stringify(params)}`);
    return { success: true, cost_savings: '$12,500 per month' };
  }

  private async integrateSystem(params: any): Promise<any> {
    this.logger.info(`Chihiro integrating system: ${JSON.stringify(params)}`);
    return { success: true, integration_status: 'Systems successfully integrated' };
  }

  private async testAlgorithm(params: any): Promise<any> {
    this.logger.info(`Chihiro testing algorithm: ${JSON.stringify(params)}`);
    return { success: true, test_results: 'Algorithm performance: 99.2% accuracy' };
  }

  private async innovateSolution(params: any): Promise<any> {
    this.logger.info(`Chihiro innovating solution: ${JSON.stringify(params)}`);
    return { success: true, innovation: 'Revolutionary new approach discovered' };
  }

  private async enhanceBeauty(params: any): Promise<any> {
    this.logger.info(`Celestia enhancing beauty: ${JSON.stringify(params)}`);
    return { success: true, beauty_score: 9.8 };
  }

  private async optimizeAesthetics(params: any): Promise<any> {
    this.logger.info(`Celestia optimizing aesthetics: ${JSON.stringify(params)}`);
    return { success: true, aesthetic_improvement: 'Elegance increased by 40%' };
  }

  private async createDrama(params: any): Promise<any> {
    this.logger.info(`Celestia creating drama: ${JSON.stringify(params)}`);
    return { success: true, dramatic_effect: 'Stunning visual transformation' };
  }

  private async stressTest(params: any): Promise<any> {
    this.logger.info(`Sakura stress testing: ${JSON.stringify(params)}`);
    return { success: true, stress_result: 'System withstood 150% load' };
  }

  private async enduranceTest(params: any): Promise<any> {
    this.logger.info(`Sakura endurance testing: ${JSON.stringify(params)}`);
    return { success: true, endurance_result: '72 hours continuous operation' };
  }

  private async analyzeReliability(params: any): Promise<any> {
    this.logger.info(`Sakura analyzing reliability: ${JSON.stringify(params)}`);
    return { success: true, reliability_score: 99.95 };
  }
}

// CLI interface for running character simulators
if (require.main === module) {
  const characterId = process.env.CHARACTER || 'kyoko';
  
  const simulator = new CharacterSimulator(characterId);
  
  simulator.start().catch(error => {
    console.error(`Failed to start ${characterId} simulator:`, error);
    process.exit(1);
  });
}
