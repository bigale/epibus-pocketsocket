import { CharacterSimulator } from './character-simulator';
import { EventEmitter } from 'events';
import winston from 'winston';

/**
 * Multi-Character Simulator Manager
 * 
 * Manages multiple Node-RED instances for different characters,
 * providing orchestration and coordination between simulators.
 */

interface SimulatorInstance {
  character: string;
  simulator: CharacterSimulator;
  status: 'running' | 'stopped' | 'error';
  startTime?: Date;
  port: number;
}

interface HealthStatus {
  status: 'healthy' | 'unhealthy' | 'error';
  uptime?: string;
  port?: number;
  error?: string;
}

interface HealthCheck {
  timestamp: string;
  overall: 'healthy' | 'degraded' | 'critical';
  simulators: Record<string, HealthStatus>;
}

export class SimulatorManager extends EventEmitter {
  private simulators: Map<string, SimulatorInstance> = new Map();
  private logger!: winston.Logger;

  constructor() {
    super();
    this.setupLogger();
  }

  private setupLogger(): void {
    this.logger = winston.createLogger({
      level: 'info',
      format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.colorize(),
        winston.format.printf(({ timestamp, level, message }) => {
          return `[${timestamp}] [SimulatorManager] ${level}: ${message}`;
        })
      ),
      transports: [
        new winston.transports.Console(),
        new winston.transports.File({ filename: 'logs/simulator-manager.log' })
      ]
    });
  }

  /**
   * Start a character simulator
   */
  async startCharacter(characterId: string): Promise<void> {
    try {
      if (this.simulators.has(characterId)) {
        throw new Error(`${characterId} simulator is already running`);
      }

      this.logger.info(`Starting ${characterId} simulator...`);

      const simulator = new CharacterSimulator(characterId);
      const instance: SimulatorInstance = {
        character: characterId,
        simulator,
        status: 'stopped',
        port: this.getCharacterPort(characterId)
      };

      // Setup event listeners
      simulator.on('started', (character) => {
        instance.status = 'running';
        instance.startTime = new Date();
        this.logger.info(`${character.name} simulator started successfully`);
        this.emit('character-started', character);
      });

      simulator.on('stopped', (character) => {
        instance.status = 'stopped';
        this.logger.info(`${character.name} simulator stopped`);
        this.emit('character-stopped', character);
      });

      simulator.on('error', (error) => {
        instance.status = 'error';
        this.logger.error(`${characterId} simulator error: ${error}`);
        this.emit('character-error', { character: characterId, error });
      });

      this.simulators.set(characterId, instance);
      await simulator.start();

    } catch (error) {
      this.logger.error(`Failed to start ${characterId} simulator: ${error}`);
      throw error;
    }
  }

  /**
   * Stop a character simulator
   */
  async stopCharacter(characterId: string): Promise<void> {
    const instance = this.simulators.get(characterId);
    if (!instance) {
      throw new Error(`${characterId} simulator is not running`);
    }

    try {
      await instance.simulator.stop();
      this.simulators.delete(characterId);
    } catch (error) {
      this.logger.error(`Failed to stop ${characterId} simulator: ${error}`);
      throw error;
    }
  }

  /**
   * Start all available character simulators
   */
  async startAll(): Promise<void> {
    const characters = ['kyoko', 'byakuya', 'chihiro', 'celestia', 'sakura'];
    
    this.logger.info('Starting all character simulators...');
    
    for (const character of characters) {
      try {
        await this.startCharacter(character);
        // Add small delay between starts to avoid port conflicts
        await new Promise(resolve => setTimeout(resolve, 2000));
      } catch (error) {
        this.logger.error(`Failed to start ${character}: ${error}`);
      }
    }
  }

  /**
   * Stop all running simulators
   */
  async stopAll(): Promise<void> {
    this.logger.info('Stopping all simulators...');
    
    const stopPromises = Array.from(this.simulators.keys()).map(characterId => 
      this.stopCharacter(characterId).catch(error => 
        this.logger.error(`Error stopping ${characterId}: ${error}`)
      )
    );
    
    await Promise.all(stopPromises);
  }

  /**
   * Get status of all simulators
   */
  getStatus(): any {
    const status = {
      total: this.simulators.size,
      running: 0,
      stopped: 0,
      error: 0,
      simulators: Array.from(this.simulators.values()).map(instance => ({
        character: instance.character,
        status: instance.status,
        port: instance.port,
        uptime: instance.startTime ? Date.now() - instance.startTime.getTime() : 0,
        url: `http://localhost:${instance.port}`,
        dashboardUrl: `http://localhost:${instance.port}/ui`,
        apiUrl: `http://localhost:${instance.port}/api`
      }))
    };

    status.simulators.forEach(sim => {
      switch (sim.status) {
        case 'running':
          status.running++;
          break;
        case 'stopped':
          status.stopped++;
          break;
        case 'error':
          status.error++;
          break;
      }
    });

    return status;
  }

  /**
   * Execute action across multiple characters
   */
  async broadcastAction(action: any): Promise<Array<{character: string; result?: any; error?: string}>> {
    const results: Array<{character: string; result?: any; error?: string}> = [];
    
    for (const [characterId, instance] of this.simulators) {
      if (instance.status === 'running') {
        try {
          // Send action to character's API
          const response = await fetch(`http://localhost:${instance.port}/api/character-action`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(action)
          });
          
          const result = await response.json();
          results.push({ character: characterId, result });
          
        } catch (error: any) {
          results.push({ character: characterId, error: error.message });
        }
      }
    }
    
    return results;
  }

  /**
   * Get character-specific port mapping
   */
  private getCharacterPort(characterId: string): number {
    const portMap: Record<string, number> = {
      kyoko: 1881,
      byakuya: 1882,
      chihiro: 1883,
      celestia: 1884,
      sakura: 1885
    };
    
    return portMap[characterId] || 1880;
  }

  /**
   * Create a collaborative scenario across multiple characters
   */
  async createCollaborativeScenario(scenarioConfig: any): Promise<void> {
    this.logger.info(`Creating collaborative scenario: ${scenarioConfig.name}`);
    
    for (const characterConfig of scenarioConfig.characters) {
      const instance = this.simulators.get(characterConfig.characterId);
      if (instance && instance.status === 'running') {
        try {
          const response = await fetch(`http://localhost:${instance.port}/api/scenario/${characterConfig.scenario}`, {
            method: 'POST'
          });
          
          if (!response.ok) {
            throw new Error(`Failed to load scenario for ${characterConfig.characterId}`);
          }
          
        } catch (error) {
          this.logger.error(`Error setting up scenario for ${characterConfig.characterId}: ${error}`);
        }
      }
    }
  }

  /**
   * Monitor system health across all simulators
   */
  async healthCheck(): Promise<HealthCheck> {
    const health: HealthCheck = {
      timestamp: new Date().toISOString(),
      overall: 'healthy',
      simulators: {}
    };

    for (const [characterId, instance] of this.simulators) {
      try {
        const response = await fetch(`http://localhost:${instance.port}/api/character`);
        
        if (response.ok) {
          const data = await response.json();
          health.simulators[characterId] = {
            status: 'healthy',
            uptime: data.uptime,
            port: instance.port
          };
        } else {
          health.simulators[characterId] = {
            status: 'unhealthy',
            error: `HTTP ${response.status}`
          };
          health.overall = 'degraded';
        }
        
      } catch (error: any) {
        health.simulators[characterId] = {
          status: 'error',
          error: error.message
        };
        health.overall = 'degraded';
      }
    }

    return health;
  }
}

// CLI interface
if (require.main === module) {
  const manager = new SimulatorManager();
  
  const command = process.argv[2];
  const character = process.argv[3];
  
  async function handleCommand() {
    try {
      switch (command) {
        case 'start':
          if (character) {
            await manager.startCharacter(character);
          } else {
            await manager.startAll();
          }
          break;
          
        case 'stop':
          if (character) {
            await manager.stopCharacter(character);
          } else {
            await manager.stopAll();
          }
          break;
          
        case 'status':
          const status = manager.getStatus();
          console.log(JSON.stringify(status, null, 2));
          break;
          
        case 'health':
          const health = await manager.healthCheck();
          console.log(JSON.stringify(health, null, 2));
          break;
          
        default:
          console.log(`
Usage: npm run simulator [command] [character]

Commands:
  start [character]  - Start simulator(s)
  stop [character]   - Stop simulator(s)
  status            - Show status of all simulators
  health            - Check health of all simulators

Characters: kyoko, byakuya, chihiro, celestia, sakura
          `);
          break;
      }
    } catch (error) {
      console.error('Command failed:', (error as Error).message);
      process.exit(1);
    }
  }
  
  handleCommand();
}
