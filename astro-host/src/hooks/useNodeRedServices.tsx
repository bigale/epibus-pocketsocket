// React hook for dynamic Node-RED service monitoring
import { useState, useEffect, useCallback } from 'react';
import type { ServiceDiscoveryResult, NodeRedService } from '../utils/nodeRedServiceDiscovery';

interface UseNodeRedServicesOptions {
  refreshInterval?: number;
  autoRefresh?: boolean;
}

interface UseNodeRedServicesReturn {
  services: NodeRedService[];
  summary: ServiceDiscoveryResult['summary'] | null;
  isLoading: boolean;
  error: string | null;
  lastUpdated: Date | null;
  refresh: () => Promise<void>;
  getDashboardUrl: (character: string) => string | null;
  getEditorUrl: (character: string) => string | null;
}

export function useNodeRedServices(options: UseNodeRedServicesOptions = {}): UseNodeRedServicesReturn {
  const { refreshInterval = 30000, autoRefresh = true } = options;
  
  const [services, setServices] = useState<NodeRedService[]>([]);
  const [summary, setSummary] = useState<ServiceDiscoveryResult['summary'] | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [lastUpdated, setLastUpdated] = useState<Date | null>(null);

  const fetchServices = useCallback(async () => {
    try {
      setError(null);
      const response = await fetch('/api/node-red-status?refresh=true');
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      const result: ServiceDiscoveryResult = await response.json();
      
      setServices(result.services);
      setSummary(result.summary);
      setLastUpdated(result.lastUpdated ? new Date(result.lastUpdated) : new Date());
      
      console.log('🔄 Service discovery updated:', {
        total: result.summary.total,
        online: result.summary.online,
        offline: result.summary.offline
      });
      
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to fetch services';
      setError(errorMessage);
      console.error('❌ Service discovery failed:', err);
    } finally {
      setIsLoading(false);
    }
  }, []);

  // Initial fetch
  useEffect(() => {
    fetchServices();
  }, [fetchServices]);

  // Auto-refresh interval
  useEffect(() => {
    if (!autoRefresh) return;
    
    const interval = setInterval(fetchServices, refreshInterval);
    return () => clearInterval(interval);
  }, [fetchServices, refreshInterval, autoRefresh]);

  const getDashboardUrl = useCallback((character: string): string | null => {
    const service = services.find(s => s.character === character);
    if (!service || service.status !== 'online' || !service.dashboardPath) {
      return null;
    }
    
    return `http://localhost:${service.port}${service.dashboardPath}`;
  }, [services]);

  const getEditorUrl = useCallback((character: string): string | null => {
    const service = services.find(s => s.character === character);
    if (!service || service.status !== 'online') {
      return null;
    }
    
    return `http://localhost:${service.port}`;
  }, [services]);

  const refresh = useCallback(async () => {
    setIsLoading(true);
    await fetchServices();
  }, [fetchServices]);

  return {
    services,
    summary,
    isLoading,
    error,
    lastUpdated,
    refresh,
    getDashboardUrl,
    getEditorUrl
  };
}

// Component for displaying service status
export function NodeRedServiceStatus() {
  const { services, summary, isLoading, error, lastUpdated, refresh } = useNodeRedServices();

  if (isLoading && services.length === 0) {
    return (
      <div className="flex items-center space-x-2 text-gray-400">
        <div className="animate-pulse w-3 h-3 bg-gray-500 rounded-full"></div>
        <span className="text-sm">Checking services...</span>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex items-center space-x-2 text-red-400">
        <div className="w-3 h-3 bg-red-500 rounded-full"></div>
        <span className="text-sm">Service check failed</span>
        <button 
          onClick={refresh}
          className="text-xs bg-red-600 hover:bg-red-700 px-2 py-1 rounded text-white"
        >
          Retry
        </button>
      </div>
    );
  }

  const onlineCount = summary?.online || 0;
  const totalCount = summary?.total || 0;
  const statusColor = onlineCount === totalCount ? 'green' : onlineCount > 0 ? 'yellow' : 'red';

  return (
    <div className="flex items-center space-x-2">
      <div className={`w-3 h-3 rounded-full ${
        statusColor === 'green' ? 'bg-green-500' : 
        statusColor === 'yellow' ? 'bg-yellow-500' : 'bg-red-500'
      }`}></div>
      <span className="text-sm text-gray-300">
        {onlineCount}/{totalCount} Services Online
      </span>
      {lastUpdated && (
        <span className="text-xs text-gray-500">
          Updated {lastUpdated.toLocaleTimeString()}
        </span>
      )}
      <button 
        onClick={refresh}
        className="text-xs bg-gray-600 hover:bg-gray-700 px-2 py-1 rounded text-white"
        disabled={isLoading}
      >
        {isLoading ? '...' : '↻'}
      </button>
    </div>
  );
}
