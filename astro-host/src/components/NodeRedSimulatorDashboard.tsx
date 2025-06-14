import React, { useState, useEffect } from 'react';
import { Server, Play, Square, RotateCcw, Activity, Users, Cpu } from 'lucide-react';

interface SimulatorStatus {
  character: string;
  port: number;
  modbusPort: number;
  status: 'running' | 'stopped' | 'error' | 'starting';
  theme: string;
  specialization: string;
  uptime: number;
  cpuUsage: number;
  memoryUsage: number;
  activeConnections: number;
}

const mockSimulators: SimulatorStatus[] = [
  {
    character: 'Kyoko Kirigiri',
    port: 1881,
    modbusPort: 5020,
    status: 'running',
    theme: '🕵️ Detective Purple',
    specialization: 'Anomaly Detection & Investigation',
    uptime: 24.5,
    cpuUsage: 35.2,
    memoryUsage: 42.1,
    activeConnections: 8
  },
  {
    character: 'Byakuya Togami',
    port: 1882,
    modbusPort: 5021,
    status: 'running',
    theme: '💼 Efficiency Blue',
    specialization: 'Performance Optimization',
    uptime: 18.3,
    cpuUsage: 28.7,
    memoryUsage: 38.9,
    activeConnections: 12
  },
  {
    character: 'Chihiro Fujisaki',
    port: 1883,
    modbusPort: 5022,
    status: 'stopped',
    theme: '💻 Tech Green',
    specialization: 'System Integration',
    uptime: 0,
    cpuUsage: 0,
    memoryUsage: 0,
    activeConnections: 0
  },
  {
    character: 'Celestia Ludenberg',
    port: 1884,
    modbusPort: 5023,
    status: 'running',
    theme: '🎨 Elegant Red',
    specialization: 'UI/UX Design',
    uptime: 36.2,
    cpuUsage: 22.4,
    memoryUsage: 31.5,
    activeConnections: 5
  },
  {
    character: 'Sakura Ogami',
    port: 1885,
    modbusPort: 5024,
    status: 'running',
    theme: '💪 Strength Orange',
    specialization: 'Reliability Testing',
    uptime: 72.1,
    cpuUsage: 65.8,
    memoryUsage: 78.3,
    activeConnections: 15
  }
];

const NodeRedSimulatorDashboard: React.FC = () => {
  const [simulators, setSimulators] = useState<SimulatorStatus[]>(mockSimulators);
  const [selectedCharacter, setSelectedCharacter] = useState<string | null>(null);

  useEffect(() => {
    // Simulate real-time updates
    const interval = setInterval(() => {
      setSimulators(prev => prev.map(sim => ({
        ...sim,
        cpuUsage: sim.status === 'running' ? Math.max(0, sim.cpuUsage + (Math.random() - 0.5) * 10) : 0,
        memoryUsage: sim.status === 'running' ? Math.max(0, sim.memoryUsage + (Math.random() - 0.5) * 5) : 0,
        activeConnections: sim.status === 'running' ? Math.max(0, sim.activeConnections + Math.floor((Math.random() - 0.5) * 4)) : 0,
        uptime: sim.status === 'running' ? sim.uptime + 0.1 : 0
      })));
    }, 5000);

    return () => clearInterval(interval);
  }, []);

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'running': return 'text-green-500 bg-green-100';
      case 'stopped': return 'text-gray-500 bg-gray-100';
      case 'error': return 'text-red-500 bg-red-100';
      case 'starting': return 'text-yellow-500 bg-yellow-100';
      default: return 'text-gray-500 bg-gray-100';
    }
  };

  const getCharacterEmoji = (character: string) => {
    switch (character) {
      case 'Kyoko Kirigiri': return '🕵️';
      case 'Byakuya Togami': return '💼';
      case 'Chihiro Fujisaki': return '💻';
      case 'Celestia Ludenberg': return '🎨';
      case 'Sakura Ogami': return '💪';
      default: return '🤖';
    }
  };

  const handleSimulatorAction = (character: string, action: 'start' | 'stop' | 'restart') => {
    setSimulators(prev => prev.map(sim => {
      if (sim.character === character) {
        let newStatus: SimulatorStatus['status'];
        switch (action) {
          case 'start':
            newStatus = sim.status === 'stopped' ? 'starting' : sim.status;
            break;
          case 'stop':
            newStatus = 'stopped';
            break;
          case 'restart':
            newStatus = 'starting';
            break;
          default:
            newStatus = sim.status;
        }
        
        // Simulate starting delay
        if (newStatus === 'starting') {
          setTimeout(() => {
            setSimulators(current => current.map(s => 
              s.character === character ? { ...s, status: 'running' } : s
            ));
          }, 2000);
        }

        return { 
          ...sim, 
          status: newStatus,
          uptime: newStatus === 'stopped' ? 0 : sim.uptime,
          cpuUsage: newStatus === 'stopped' ? 0 : sim.cpuUsage,
          memoryUsage: newStatus === 'stopped' ? 0 : sim.memoryUsage,
          activeConnections: newStatus === 'stopped' ? 0 : sim.activeConnections
        };
      }
      return sim;
    }));
  };

  const runningCount = simulators.filter(sim => sim.status === 'running').length;
  const totalConnections = simulators.reduce((sum, sim) => sum + sim.activeConnections, 0);
  const avgCpuUsage = simulators.filter(sim => sim.status === 'running').reduce((sum, sim) => sum + sim.cpuUsage, 0) / runningCount || 0;

  return (
    <div className="space-y-6">
      {/* Overview Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-white rounded-lg shadow-md p-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Active Simulators</p>
              <p className="text-2xl font-bold text-gray-900">{runningCount}/5</p>
            </div>
            <Server className="h-8 w-8 text-blue-500" />
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-md p-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Total Connections</p>
              <p className="text-2xl font-bold text-gray-900">{totalConnections}</p>
            </div>
            <Users className="h-8 w-8 text-green-500" />
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-md p-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Avg CPU Usage</p>
              <p className="text-2xl font-bold text-gray-900">{avgCpuUsage.toFixed(1)}%</p>
            </div>
            <Cpu className="h-8 w-8 text-yellow-500" />
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-md p-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">System Health</p>
              <p className="text-2xl font-bold text-green-600">Excellent</p>
            </div>
            <Activity className="h-8 w-8 text-green-500" />
          </div>
        </div>
      </div>

      {/* Simulator Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-6">
        {simulators.map((simulator) => (
          <div 
            key={simulator.character}
            className={`bg-white rounded-lg shadow-md p-6 border-l-4 ${
              simulator.status === 'running' ? 'border-green-500' : 
              simulator.status === 'error' ? 'border-red-500' : 
              simulator.status === 'starting' ? 'border-yellow-500' : 'border-gray-300'
            }`}
          >
            {/* Character Header */}
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center space-x-3">
                <span className="text-2xl">{getCharacterEmoji(simulator.character)}</span>
                <div>
                  <h3 className="font-semibold text-gray-900">{simulator.character}</h3>
                  <p className="text-sm text-gray-600">{simulator.specialization}</p>
                </div>
              </div>
              <span className={`px-2 py-1 text-xs font-medium rounded-full ${getStatusColor(simulator.status)}`}>
                {simulator.status.toUpperCase()}
              </span>
            </div>

            {/* Connection Info */}
            <div className="space-y-2 mb-4">
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">Node-RED Port:</span>
                <span className="font-medium">{simulator.port}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">MODBUS Port:</span>
                <span className="font-medium">{simulator.modbusPort}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">Theme:</span>
                <span className="font-medium">{simulator.theme}</span>
              </div>
            </div>

            {/* Metrics */}
            {simulator.status === 'running' && (
              <div className="space-y-2 mb-4">
                <div className="flex justify-between text-sm">
                  <span className="text-gray-600">Uptime:</span>
                  <span className="font-medium">{simulator.uptime.toFixed(1)}h</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-gray-600">CPU Usage:</span>
                  <span className="font-medium">{simulator.cpuUsage.toFixed(1)}%</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-gray-600">Memory:</span>
                  <span className="font-medium">{simulator.memoryUsage.toFixed(1)}%</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-gray-600">Connections:</span>
                  <span className="font-medium">{simulator.activeConnections}</span>
                </div>
              </div>
            )}

            {/* Action Buttons */}
            <div className="flex space-x-2">
              {simulator.status === 'stopped' ? (
                <button
                  onClick={() => handleSimulatorAction(simulator.character, 'start')}
                  className="flex-1 flex items-center justify-center px-3 py-2 bg-green-600 text-white text-sm font-medium rounded-md hover:bg-green-700 transition-colors"
                >
                  <Play className="h-4 w-4 mr-2" />
                  Start
                </button>
              ) : (
                <>
                  <button
                    onClick={() => handleSimulatorAction(simulator.character, 'stop')}
                    className="flex-1 flex items-center justify-center px-3 py-2 bg-red-600 text-white text-sm font-medium rounded-md hover:bg-red-700 transition-colors"
                  >
                    <Square className="h-4 w-4 mr-2" />
                    Stop
                  </button>
                  <button
                    onClick={() => handleSimulatorAction(simulator.character, 'restart')}
                    className="flex-1 flex items-center justify-center px-3 py-2 bg-yellow-600 text-white text-sm font-medium rounded-md hover:bg-yellow-700 transition-colors"
                  >
                    <RotateCcw className="h-4 w-4 mr-2" />
                    Restart
                  </button>
                </>
              )}
            </div>

            {/* Quick Access Links */}
            {simulator.status === 'running' && (
              <div className="flex space-x-2 mt-3">
                <a
                  href={`http://localhost:${simulator.port}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex-1 text-center px-3 py-1 bg-blue-100 text-blue-700 text-xs font-medium rounded hover:bg-blue-200 transition-colors"
                >
                  Node-RED UI
                </a>
                <a
                  href={`http://localhost:${simulator.port}/ui`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex-1 text-center px-3 py-1 bg-purple-100 text-purple-700 text-xs font-medium rounded hover:bg-purple-200 transition-colors"
                >
                  Dashboard
                </a>
              </div>
            )}
          </div>
        ))}
      </div>

      {/* Collaborative Scenarios Section */}
      <div className="bg-white rounded-lg shadow-md p-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">🤝 Collaborative Scenarios</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="border rounded-lg p-4">
            <h4 className="font-medium text-gray-900 mb-2">🕵️💼 Investigation + Efficiency</h4>
            <p className="text-sm text-gray-600 mb-3">
              Kyoko's anomaly detection combined with Byakuya's optimization analysis
            </p>
            <button className="w-full px-4 py-2 bg-indigo-600 text-white text-sm font-medium rounded-md hover:bg-indigo-700 transition-colors">
              Launch Scenario
            </button>
          </div>
          
          <div className="border rounded-lg p-4">
            <h4 className="font-medium text-gray-900 mb-2">💻🎨 Tech + Design</h4>
            <p className="text-sm text-gray-600 mb-3">
              Chihiro's integration skills with Celestia's elegant interfaces
            </p>
            <button className="w-full px-4 py-2 bg-indigo-600 text-white text-sm font-medium rounded-md hover:bg-indigo-700 transition-colors">
              Launch Scenario
            </button>
          </div>
          
          <div className="border rounded-lg p-4">
            <h4 className="font-medium text-gray-900 mb-2">💪🔧 Stress Testing Suite</h4>
            <p className="text-sm text-gray-600 mb-3">
              Sakura's reliability testing across all character systems
            </p>
            <button className="w-full px-4 py-2 bg-indigo-600 text-white text-sm font-medium rounded-md hover:bg-indigo-700 transition-colors">
              Launch Scenario
            </button>
          </div>
          
          <div className="border rounded-lg p-4">
            <h4 className="font-medium text-gray-900 mb-2">👑🌟 Full Royal Suite</h4>
            <p className="text-sm text-gray-600 mb-3">
              All characters working together in a comprehensive industrial scenario
            </p>
            <button className="w-full px-4 py-2 bg-indigo-600 text-white text-sm font-medium rounded-md hover:bg-indigo-700 transition-colors">
              Launch Scenario
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default NodeRedSimulatorDashboard;
