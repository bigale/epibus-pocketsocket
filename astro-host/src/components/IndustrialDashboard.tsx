import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Activity, 
  Zap, 
  Settings, 
  AlertTriangle, 
  TrendingUp, 
  Users,
  Cpu,
  Thermometer,
  Gauge,
  Play,
  Pause,
  RotateCcw
} from 'lucide-react';

import PLCDashboard from './PLCDashboard';
import CharacterSelector from './CharacterSelector';
import SignalMonitor from './SignalMonitor';
import AnalysisPanel from './AnalysisPanel';
import AlarmPanel from './AlarmPanel';
import NodeRedSimulatorDashboard from './NodeRedSimulatorDashboard';
import { useIndustrialStore } from '../store/industrialStore';
import { useNodeRedServices, NodeRedServiceStatus } from '../hooks/useNodeRedServices';

interface Props {}

const IndustrialDashboard: React.FC<Props> = () => {
  const [activeTab, setActiveTab] = useState('overview');
  const [isConnected, setIsConnected] = useState(false);
  const [selectedCharacter, setSelectedCharacter] = useState('kyoko');
  
  // Use dynamic service discovery
  const { services, getDashboardUrl, getEditorUrl } = useNodeRedServices();
  
  // Character switching functionality with dynamic URLs
  const handleCharacterChange = (characterId: string) => {
    console.log('IndustrialDashboard: handleCharacterChange called with:', characterId);
    setSelectedCharacter(characterId);
    
    // Get dynamic URLs from service discovery
    const dashboardUrl = getDashboardUrl(characterId);
    const editorUrl = getEditorUrl(characterId);
    
    if (dashboardUrl) {
      // Open the character's live dashboard with dynamically discovered path
      window.open(dashboardUrl, `${characterId}-dashboard`, 'width=1200,height=800');
      console.log(`Character ${characterId} switched. Dashboard: ${dashboardUrl}, Editor: ${editorUrl}`);
    } else {
      console.warn(`No dashboard URL available for character: ${characterId}`);
      alert(`${characterId} character service is not available. Please check if the simulator is running.`);
    }
  };
  
  const {
    devices,
    analyses,
    alarms,
    isSystemRunning,
    startSystem,
    stopSystem,
    addDevice,
    updateSignal
  } = useIndustrialStore();

  useEffect(() => {
    // Initialize WebSocket connection for real-time updates
    initializeWebSocket();
    
    // Start with demo data
    initializeDemoData();
    
    // Check simulator status periodically
    checkSimulatorStatus();
    const statusInterval = setInterval(checkSimulatorStatus, 30000); // Every 30 seconds
    
    return () => clearInterval(statusInterval);
  }, []);

  const initializeWebSocket = () => {
    // Note: For now, we'll use API-based status checking instead of WebSocket
    // The Node-RED simulators run on ports 1981-1985 for WebSocket connections
    // This could be enhanced later to connect to specific character WebSocket endpoints
    console.log('WebSocket initialization skipped - using API-based status monitoring');
  };

  const checkSimulatorStatus = async () => {
    try {
      const response = await fetch('/api/simulators/status');
      if (response.ok) {
        const status = await response.json();
        console.log('Simulator status:', status);
        
        // Update connection status based on running simulators
        const hasRunningSimulators = status.isRunning && status.runningCount > 0;
        setIsConnected(hasRunningSimulators);
        
        // Update system running state to match actual simulator status
        if (hasRunningSimulators && !isSystemRunning) {
          startSystem();
        } else if (!hasRunningSimulators && isSystemRunning) {
          stopSystem();
        }
      }
    } catch (error) {
      console.error('Failed to check simulator status:', error);
      setIsConnected(false);
    }
  };

  const initializeDemoData = () => {
    // Add demo PLC devices
    const demoDevices = [
      {
        id: 'plc-001',
        name: 'Production Line A',
        type: 'modbus_tcp' as const,
        host: '192.168.1.100',
        characterAgent: 'kyoko' as const,
        signals: [
          {
            id: 'temp-001',
            name: 'Reactor Temperature',
            address: 100,
            dataType: 'int16' as const,
            accessType: 'read' as const,
            unit: '°C',
            category: 'process' as const,
            isActive: true,
            quality: 'good' as const,
            tags: ['temperature', 'reactor'],
            alarmLimits: { high: 80, critical: 90 }
          },
          {
            id: 'pressure-001',
            name: 'System Pressure',
            address: 101,
            dataType: 'int16' as const,
            accessType: 'read' as const,
            unit: 'PSI',
            category: 'process' as const,
            isActive: true,
            quality: 'good' as const,
            tags: ['pressure', 'system']
          },
          {
            id: 'flow-001',
            name: 'Flow Rate',
            address: 102,
            dataType: 'int16' as const,
            accessType: 'read' as const,
            unit: 'L/min',
            category: 'process' as const,
            isActive: true,
            quality: 'good' as const,
            tags: ['flow', 'rate']
          }
        ],
        actions: [],
        tags: ['production', 'line-a'],
        isActive: true,
        healthStatus: 'healthy' as const
      },
      {
        id: 'plc-002',
        name: 'Quality Control Station',
        type: 'modbus_tcp' as const,
        host: '192.168.1.101',
        characterAgent: 'byakuya' as const,
        signals: [
          {
            id: 'quality-001',
            name: 'Product Quality Index',
            address: 200,
            dataType: 'int16' as const,
            accessType: 'read' as const,
            unit: '%',
            category: 'quality' as const,
            isActive: true,
            quality: 'good' as const,
            tags: ['quality', 'index']
          }
        ],
        actions: [],
        tags: ['quality', 'control'],
        isActive: true,
        healthStatus: 'healthy' as const
      }
    ];

    demoDevices.forEach(device => addDevice(device));
  };

  const handleSystemToggle = async () => {
    console.log('System toggle clicked. Current state:', isSystemRunning);
    
    try {
      if (isSystemRunning) {
        console.log('Stopping Node-RED simulators...');
        
        // Call the actual stop script
        const response = await fetch('/api/simulators/stop', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' }
        });
        
        if (response.ok) {
          const result = await response.json();
          console.log('Stop API response:', result);
          
          stopSystem();
          console.log('✅ Node-RED simulators stopped successfully');
          
          // Check status after a delay
          setTimeout(checkSimulatorStatus, 2000);
        } else {
          // Fallback: try direct script execution
          console.log('API call failed, trying direct script execution...');
          
          // For development, we'll use a simulated approach
          // In production, this would call the actual management scripts
          setTimeout(() => {
            stopSystem();
            alert('Simulators stopped! (This is a simulated action - in production this would call the actual Node-RED stop scripts)');
          }, 1000);
        }
      } else {
        console.log('Starting Node-RED simulators...');
        
        // Call the actual start script
        const response = await fetch('/api/simulators/start', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' }
        });
        
        if (response.ok) {
          const result = await response.json();
          console.log('Start API response:', result);
          
          startSystem();
          console.log('✅ Node-RED simulators started successfully');
          
          // Check status after a delay
          setTimeout(checkSimulatorStatus, 3000);
        } else {
          // Fallback: try direct approach
          console.log('API call failed, trying direct script execution...');
          
          // For development, we'll provide manual instructions
          setTimeout(() => {
            startSystem();
            const scriptPath = '/home/bigale/repos/icpxmldb/ai-kit/industrial-iot/node-red-plc-simulator/scripts/manage.sh';
            alert(`Simulators started! (Simulated)\n\nTo actually start simulators, run:\n${scriptPath} start\n\nTo stop them, run:\n${scriptPath} stop`);
          }, 1000);
        }
      }
    } catch (error) {
      console.error('Error toggling system:', error);
      
      // Provide manual instructions as fallback
      const action = isSystemRunning ? 'stop' : 'start';
      const scriptPath = '/home/bigale/repos/icpxmldb/ai-kit/industrial-iot/node-red-plc-simulator/scripts/manage.sh';
      
      alert(`System toggle error. To manually ${action} simulators:\n\nRun: ${scriptPath} ${action}\n\nOr open a terminal and navigate to the simulator directory.`);
    }
  };

  const tabs = [
    { id: 'overview', label: 'Overview', icon: Activity },
    { id: 'devices', label: 'Devices', icon: Cpu },
    { id: 'signals', label: 'Signals', icon: Zap },
    { id: 'analyses', label: 'AI Analysis', icon: TrendingUp },
    { id: 'alarms', label: 'Alarms', icon: AlertTriangle },
    { id: 'characters', label: 'Characters', icon: Users },
    { id: 'simulators', label: 'Node-RED Simulators', icon: Settings },
  ];

  const getStatusColor = () => {
    if (!isConnected) return 'bg-red-500';
    if (alarms.filter(a => a.severity === 'critical').length > 0) return 'bg-red-500';
    if (alarms.filter(a => a.severity === 'warning').length > 0) return 'bg-yellow-500';
    return 'bg-green-500';
  };

  const renderTabContent = () => {
    switch (activeTab) {
      case 'overview':
        return (
          <div key="overview-content" className="space-y-6">
            {/* System Overview Stats */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              <div className="bg-gray-800 rounded-lg p-4 border border-gray-700">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm text-gray-400">Connected Devices</p>
                    <p className="text-2xl font-bold text-white">{devices.length}</p>
                  </div>
                  <Cpu className="h-8 w-8 text-blue-500" />
                </div>
              </div>
              <div className="bg-gray-800 rounded-lg p-4 border border-gray-700">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm text-gray-400">Active Signals</p>
                    <p className="text-2xl font-bold text-white">
                      {devices.reduce((sum, device) => sum + device.signals.length, 0)}
                    </p>
                  </div>
                  <Zap className="h-8 w-8 text-yellow-500" />
                </div>
              </div>
              <div className="bg-gray-800 rounded-lg p-4 border border-gray-700">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm text-gray-400">System Status</p>
                    <p className="text-2xl font-bold text-green-400">Healthy</p>
                  </div>
                  <Activity className="h-8 w-8 text-green-500" />
                </div>
              </div>
              <div className="bg-gray-800 rounded-lg p-4 border border-gray-700">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm text-gray-400">Active Alarms</p>
                    <p className="text-2xl font-bold text-white">{alarms.length}</p>
                  </div>
                  <AlertTriangle className="h-8 w-8 text-red-500" />
                </div>
              </div>
            </div>
            
            {/* Quick Device Summary */}
            <div className="bg-gray-800 rounded-lg p-6 border border-gray-700">
              <h3 className="text-lg font-semibold text-white mb-4">Quick Device Summary</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {devices.slice(0, 4).map((device) => (
                  <div key={`overview-${device.id}`} className="flex items-center justify-between p-3 bg-gray-700 rounded">
                    <div>
                      <p className="text-white font-medium">{device.name}</p>
                      <p className="text-sm text-gray-400">{device.type}</p>
                    </div>
                    <div className={`w-3 h-3 rounded-full ${
                      device.healthStatus === 'healthy' ? 'bg-green-500' :
                      device.healthStatus === 'warning' ? 'bg-yellow-500' : 'bg-red-500'
                    }`} />
                  </div>
                ))}
              </div>
            </div>
          </div>
        );
      case 'devices':
        return (
          <div key="devices-content">
            <PLCDashboard devices={devices} />
          </div>
        );
      case 'signals':
        return <SignalMonitor devices={devices} />;
      case 'analyses':
        return <AnalysisPanel analyses={analyses} />;
      case 'alarms':
        return <AlarmPanel alarms={alarms} />;
      case 'characters':
        console.log('IndustrialDashboard: Rendering CharacterSelector with props:', {
          currentCharacter: selectedCharacter,
          onCharacterChange: typeof handleCharacterChange
        });
        return <CharacterSelector 
          currentCharacter={selectedCharacter}
          onCharacterChange={handleCharacterChange}
        />;
      case 'simulators':
        return <NodeRedSimulatorDashboard />;
      default:
        return (
          <div key="default-content">
            <PLCDashboard devices={devices} />
          </div>
        );
    }
  };

  return (
    <div className="min-h-screen bg-gray-900 text-white">
      {/* Header */}
      <header className="bg-gray-800 border-b border-gray-700">
        <div className="px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2">
                <Activity className="w-8 h-8 text-blue-400" />
                <h1 className="text-2xl font-bold bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">
                  AI-Kit Industrial IoT
                </h1>
              </div>
              
              {/* System Status - Now using dynamic service discovery */}
              <div className="flex items-center space-x-4 ml-8">
                <NodeRedServiceStatus />
              </div>
            </div>

            <div className="flex items-center space-x-4">
              {/* Content Collections Link */}
              <a
                href="/content-showcase"
                className="flex items-center space-x-2 px-3 py-2 rounded-md bg-purple-600 hover:bg-purple-700 transition-colors text-sm"
                title="View Content Collections"
              >
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
                <span>Content</span>
              </a>
              
              {/* System Control */}
              <button
                onClick={handleSystemToggle}
                className={`flex items-center space-x-2 px-4 py-2 rounded-md ${
                  isSystemRunning 
                    ? 'bg-red-600 hover:bg-red-700' 
                    : 'bg-green-600 hover:bg-green-700'
                } transition-colors`}
              >
                {isSystemRunning ? (
                  <>
                    <Pause className="w-4 h-4" />
                    <span>Stop System</span>
                  </>
                ) : (
                  <>
                    <Play className="w-4 h-4" />
                    <span>Start System</span>
                  </>
                )}
              </button>

              {/* Quick Stats */}
              <div className="flex items-center space-x-6 text-sm">
                <div className="flex items-center space-x-2">
                  <Cpu className="w-4 h-4 text-blue-400" />
                  <span>{devices.length} Devices</span>
                </div>
                <div className="flex items-center space-x-2">
                  <AlertTriangle className="w-4 h-4 text-yellow-400" />
                  <span>{alarms.length} Alarms</span>
                </div>
                <div className="flex items-center space-x-2">
                  <TrendingUp className="w-4 h-4 text-green-400" />
                  <span>{analyses.length} Analyses</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </header>

      <div className="flex h-screen">
        {/* Sidebar Navigation */}
        <nav className="w-64 bg-gray-800 border-r border-gray-700">
          <div className="p-4">
            <div className="space-y-2">
              {tabs.map((tab) => {
                const Icon = tab.icon;
                return (
                  <button
                    key={tab.id}
                    onClick={() => setActiveTab(tab.id)}
                    className={`w-full flex items-center space-x-3 px-4 py-3 rounded-md transition-colors ${
                      activeTab === tab.id
                        ? 'bg-blue-600 text-white'
                        : 'text-gray-300 hover:bg-gray-700 hover:text-white'
                    }`}
                  >
                    <Icon className="w-5 h-5" />
                    <span>{tab.label}</span>
                  </button>
                );
              })}
            </div>
          </div>

          {/* Character Status */}
          <div className="p-4 border-t border-gray-700">
            <h3 className="text-sm font-medium text-gray-400 mb-3">Active Character</h3>
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-gradient-to-r from-purple-400 to-pink-400 rounded-full flex items-center justify-center">
                <span className="text-sm font-bold text-white">
                  {selectedCharacter.charAt(0).toUpperCase()}
                </span>
              </div>
              <div>
                <div className="text-sm font-medium capitalize">{selectedCharacter}</div>
                <div className="text-xs text-gray-400">
                  {selectedCharacter === 'kyoko' && 'Detective Analysis'}
                  {selectedCharacter === 'byakuya' && 'Performance Optimization'}
                  {selectedCharacter === 'chihiro' && 'System Monitoring'}
                  {selectedCharacter === 'celestia' && 'Predictive Analytics'}
                  {selectedCharacter === 'sakura' && 'Safety & Maintenance'}
                </div>
              </div>
            </div>
          </div>
        </nav>

        {/* Main Content */}
        <main className="flex-1 overflow-auto">
          <AnimatePresence mode="wait">
            <motion.div
              key={activeTab}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              transition={{ duration: 0.2 }}
              className="p-6"
            >
              {renderTabContent()}
            </motion.div>
          </AnimatePresence>
        </main>
      </div>
    </div>
  );
};

export default IndustrialDashboard;
