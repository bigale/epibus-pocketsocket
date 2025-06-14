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
import { useIndustrialStore } from '../store/industrialStore';

interface Props {}

const IndustrialDashboard: React.FC<Props> = () => {
  const [activeTab, setActiveTab] = useState('overview');
  const [isConnected, setIsConnected] = useState(false);
  const [selectedCharacter, setSelectedCharacter] = useState('kyoko');
  
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
  }, []);

  const initializeWebSocket = () => {
    try {
      const ws = new WebSocket('ws://localhost:8080');
      
      ws.onopen = () => {
        setIsConnected(true);
        console.log('Connected to PLC real-time data stream');
      };
      
      ws.onmessage = (event) => {
        const data = JSON.parse(event.data);
        
        switch (data.type) {
          case 'signal_data':
            updateSignal(data.data);
            break;
          case 'connection_status':
            setIsConnected(data.connected);
            break;
          case 'analysis_complete':
            // Handle analysis updates
            break;
        }
      };
      
      ws.onclose = () => {
        setIsConnected(false);
        console.log('Disconnected from PLC stream');
      };
      
      ws.onerror = (error) => {
        console.error('WebSocket error:', error);
        setIsConnected(false);
      };
    } catch (error) {
      console.error('Failed to initialize WebSocket:', error);
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

  const handleSystemToggle = () => {
    if (isSystemRunning) {
      stopSystem();
    } else {
      startSystem();
    }
  };

  const tabs = [
    { id: 'overview', label: 'Overview', icon: Activity },
    { id: 'devices', label: 'Devices', icon: Cpu },
    { id: 'signals', label: 'Signals', icon: Zap },
    { id: 'analyses', label: 'AI Analysis', icon: TrendingUp },
    { id: 'alarms', label: 'Alarms', icon: AlertTriangle },
    { id: 'characters', label: 'Characters', icon: Users },
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
        return <PLCDashboard devices={devices} />;
      case 'devices':
        return <PLCDashboard devices={devices} />;
      case 'signals':
        return <SignalMonitor devices={devices} />;
      case 'analyses':
        return <AnalysisPanel analyses={analyses} />;
      case 'alarms':
        return <AlarmPanel alarms={alarms} />;
      case 'characters':
        return <CharacterSelector 
          selectedCharacter={selectedCharacter}
          onSelectCharacter={setSelectedCharacter}
        />;
      default:
        return <PLCDashboard devices={devices} />;
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
              
              {/* System Status */}
              <div className="flex items-center space-x-2 ml-8">
                <div className={`w-3 h-3 rounded-full ${getStatusColor()}`} />
                <span className="text-sm text-gray-300">
                  {isConnected ? 'Connected' : 'Disconnected'}
                </span>
              </div>
            </div>

            <div className="flex items-center space-x-4">
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
