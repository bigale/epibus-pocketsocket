// Dynamic Node-RED Service Discovery and Health Check
// This utility automatically detects and monitors Node-RED dashboard paths

export interface NodeRedService {
  character: string;
  port: number;
  modbus_port: number;
  theme: string;
  status: 'online' | 'offline' | 'starting';
  dashboardPath?: string;
  lastChecked: Date;
  responseTime?: number;
}

export interface ServiceDiscoveryResult {
  services: NodeRedService[];
  summary: {
    total: number;
    online: number;
    offline: number;
  };
  lastUpdated: Date;
}

export class NodeRedServiceDiscovery {
  private readonly CHARACTERS = [
    { name: 'kyoko', port: 1881, modbus: 5020, theme: 'detective-purple' },
    { name: 'byakuya', port: 1882, modbus: 5021, theme: 'efficiency-blue' },
    { name: 'chihiro', port: 1883, modbus: 5022, theme: 'tech-green' },
    { name: 'celestia', port: 1884, modbus: 5023, theme: 'elegant-red' },
    { name: 'sakura', port: 1885, modbus: 5024, theme: 'strength-orange' }
  ];

  private readonly POSSIBLE_DASHBOARD_PATHS = [
    '/api/ui/',
    '/api/ui',
    '/ui/',
    '/ui',
    '/dashboard/',
    '/dashboard'
  ];

  /**
   * Discovers all Node-RED services and their correct dashboard paths
   */
  async discoverServices(): Promise<ServiceDiscoveryResult> {
    console.log('🔍 Discovering Node-RED services...');
    
    const services: NodeRedService[] = [];
    
    for (const char of this.CHARACTERS) {
      const service = await this.checkService(char);
      services.push(service);
    }

    const summary = {
      total: services.length,
      online: services.filter(s => s.status === 'online').length,
      offline: services.filter(s => s.status === 'offline').length
    };

    return {
      services,
      summary,
      lastUpdated: new Date()
    };
  }

  /**
   * Checks a single Node-RED service and discovers its dashboard path
   */
  private async checkService(character: { name: string; port: number; modbus: number; theme: string }): Promise<NodeRedService> {
    const startTime = Date.now();
    
    try {
      // First check if the main Node-RED instance is running
      const baseUrl = `http://localhost:${character.port}`;
      const mainResponse = await this.fetchWithTimeout(baseUrl, 3000);
      
      if (!mainResponse.ok) {
        return {
          character: character.name,
          port: character.port,
          modbus_port: character.modbus,
          theme: character.theme,
          status: 'offline',
          lastChecked: new Date()
        };
      }

      // Now discover the correct dashboard path
      const dashboardPath = await this.discoverDashboardPath(character.port);
      
      return {
        character: character.name,
        port: character.port,
        modbus_port: character.modbus,
        theme: character.theme,
        status: 'online',
        dashboardPath,
        lastChecked: new Date(),
        responseTime: Date.now() - startTime
      };
      
    } catch (error) {
      console.warn(`❌ Service ${character.name} (${character.port}): ${error}`);
      return {
        character: character.name,
        port: character.port,
        modbus_port: character.modbus,
        theme: character.theme,
        status: 'offline',
        lastChecked: new Date(),
        responseTime: Date.now() - startTime
      };
    }
  }

  /**
   * Discovers the correct dashboard path for a Node-RED instance
   */
  private async discoverDashboardPath(port: number): Promise<string | undefined> {
    const baseUrl = `http://localhost:${port}`;
    
    for (const path of this.POSSIBLE_DASHBOARD_PATHS) {
      try {
        const response = await this.fetchWithTimeout(`${baseUrl}${path}`, 2000);
        if (response.ok) {
          const text = await response.text();
          // Check if it looks like a Node-RED dashboard
          if (text.includes('node-red-dashboard') || text.includes('ui-dashboard') || text.includes('Dashboard')) {
            console.log(`✅ Found dashboard for port ${port} at: ${path}`);
            return path;
          }
        }
      } catch (error) {
        // Continue checking other paths
        continue;
      }
    }
    
    console.warn(`⚠️ No dashboard path found for port ${port}`);
    return undefined;
  }

  /**
   * Fetch with timeout to avoid hanging requests
   */
  private async fetchWithTimeout(url: string, timeout: number): Promise<Response> {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);
    
    try {
      const response = await fetch(url, {
        signal: controller.signal,
        method: 'GET',
        headers: {
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
        }
      });
      clearTimeout(timeoutId);
      return response;
    } catch (error) {
      clearTimeout(timeoutId);
      throw error;
    }
  }

  /**
   * Gets the dashboard URL for a specific character
   */
  getDashboardUrl(character: string, services: NodeRedService[]): string | null {
    const service = services.find(s => s.character === character);
    if (!service || service.status !== 'online' || !service.dashboardPath) {
      return null;
    }
    
    return `http://localhost:${service.port}${service.dashboardPath}`;
  }

  /**
   * Gets the editor URL for a specific character
   */
  getEditorUrl(character: string, services: NodeRedService[]): string | null {
    const service = services.find(s => s.character === character);
    if (!service || service.status !== 'online') {
      return null;
    }
    
    return `http://localhost:${service.port}`;
  }
}

// Singleton instance for use across the application
export const serviceDiscovery = new NodeRedServiceDiscovery();
