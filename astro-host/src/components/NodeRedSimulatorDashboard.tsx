import React, { useState, useEffect } from 'react';
import { Server, Play, Square, RotateCcw, Activity, Users, Cpu } from 'lucide-react';
import { useNodeRedServices } from '../hooks/useNodeRedServices';
import type { NodeRedService } from '../utils/nodeRedServiceDiscovery';

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
  const [selectedCharacter, setSelectedCharacter] = useState<string | null>(null);
  const [showPopupGuide, setShowPopupGuide] = useState(false);
  const { services, isLoading, error, refresh, getDashboardUrl, getEditorUrl } = useNodeRedServices();

  const handleOpenDashboard = (character: string) => {
    const dashboardUrl = getDashboardUrl(character);
    if (dashboardUrl) {
      console.log(`Opening ${character} dashboard:`, dashboardUrl);
      window.open(dashboardUrl, `${character}-dashboard`, 'width=1200,height=800,scrollbars=yes,resizable=yes');
    } else {
      alert(`Dashboard not available for ${character}. Please check if the simulator is running.`);
    }
  };

  const handleOpenEditor = (character: string) => {
    const editorUrl = getEditorUrl(character);
    if (editorUrl) {
      console.log(`Opening ${character} editor:`, editorUrl);
      window.open(editorUrl, `${character}-editor`, 'width=1400,height=900,scrollbars=yes,resizable=yes');
    } else {
      alert(`Editor not available for ${character}. Please check if the simulator is running.`);
    }
  };

  const openMultipleDashboards = (dashboards: Array<{character: string, url: string}>, scenarioName: string) => {
    // Try to open all dashboards with staggered timing
    const results: Array<{character: string, success: boolean}> = [];
    
    dashboards.forEach((dashboard, index) => {
      setTimeout(() => {
        const newWindow = window.open(
          dashboard.url, 
          `${dashboard.character}-${scenarioName}`, 
          'width=800,height=600,left=' + (100 + index * 50) + ',top=' + (100 + index * 50)
        );
        
        results.push({
          character: dashboard.character,
          success: newWindow !== null
        });
        
        // After all attempts, show results
        if (index === dashboards.length - 1) {
          setTimeout(() => {
            const successful = results.filter(r => r.success);
            const failed = results.filter(r => !r.success);
            
            if (successful.length === dashboards.length) {
              alert(`✅ ${scenarioName} launched successfully!\nAll ${dashboards.length} dashboards are now open.`);
            } else if (successful.length > 0) {
              setShowPopupGuide(true); // Show popup guide
              alert(`⚠️ ${scenarioName} partially launched.\n\n` +
                   `✅ Opened: ${successful.map(s => s.character).join(', ')}\n` +
                   `❌ Blocked: ${failed.map(f => f.character).join(', ')}\n\n` +
                   `Please check the popup permission guide that just appeared at the top of the page.`);
            } else {
              setShowPopupGuide(true); // Show popup guide
              alert(`❌ All popups were blocked.\n\nPlease check the popup permission guide at the top of the page, then try again.\n\nManual URLs:\n` +
                   dashboards.map(d => `${d.character}: ${d.url}`).join('\n'));
            }
          }, 300);
        }
      }, index * 400); // Stagger by 400ms
    });
  };

  const handleCollaborativeScenario = (scenarioType: string) => {
    switch (scenarioType) {
      case 'investigation-efficiency':
        // Open Kyoko and Byakuya dashboards
        const kyokoDashboard = getDashboardUrl('kyoko');
        const byakuyaDashboard = getDashboardUrl('byakuya');
        
        console.log('Kyoko Dashboard URL:', kyokoDashboard);
        console.log('Byakuya Dashboard URL:', byakuyaDashboard);
        
        if (kyokoDashboard && byakuyaDashboard) {
          openMultipleDashboards([
            {character: 'kyoko', url: kyokoDashboard},
            {character: 'byakuya', url: byakuyaDashboard}
          ], 'investigation-efficiency');
        } else {
          alert('Please ensure both Kyoko and Byakuya simulators are running before launching this scenario.');
        }
        break;
        
      case 'tech-design':
        // Open Chihiro and Celestia dashboards
        const chihiroDashboard = getDashboardUrl('chihiro');
        const celestiaDashboard = getDashboardUrl('celestia');
        
        console.log('Chihiro Dashboard URL:', chihiroDashboard);
        console.log('Celestia Dashboard URL:', celestiaDashboard);
        
        if (chihiroDashboard && celestiaDashboard) {
          openMultipleDashboards([
            {character: 'chihiro', url: chihiroDashboard},
            {character: 'celestia', url: celestiaDashboard}
          ], 'tech-design');
        } else {
          alert('Please ensure both Chihiro and Celestia simulators are running before launching this scenario.');
        }
        break;
        
      case 'stress-testing':
        // Open Sakura dashboard (she handles stress testing for all)
        const sakuraDashboard = getDashboardUrl('sakura');
        
        console.log('Sakura Dashboard URL:', sakuraDashboard);
        
        if (sakuraDashboard) {
          const sakuraWindow = window.open(sakuraDashboard, 'sakura-stress-test', 'width=1200,height=800');
          if (sakuraWindow) {
            alert('💪🔧 Stress Testing Suite launched!\n\nSakura will conduct comprehensive reliability testing across all character systems. Monitor her dashboard for system stress metrics.');
          } else {
            alert('Please enable popups for this site or manually open: ' + sakuraDashboard);
          }
        } else {
          alert('Please ensure Sakura simulator is running before launching stress testing.');
        }
        break;
        
      case 'full-royal-suite':
        // Open all available dashboards
        const availableServices = services.filter(s => s.status === 'online');
        
        console.log('Available services for Royal Suite:', availableServices.map(s => s.character));
        
        if (availableServices.length >= 4) {
          let leftOffset = 50;
          let topOffset = 50;
          const openedWindows: Window[] = [];
          const dashboardUrls: string[] = [];
          
          availableServices.forEach((service, index) => {
            const dashboardUrl = getDashboardUrl(service.character);
            if (dashboardUrl) {
              dashboardUrls.push(`${service.character}: ${dashboardUrl}`);
              
              setTimeout(() => {
                const newWindow = window.open(
                  dashboardUrl, 
                  `${service.character}-royal-suite`, 
                  `width=600,height=500,left=${leftOffset},top=${topOffset}`
                );
                
                if (newWindow) {
                  openedWindows.push(newWindow);
                }
                
                // If this is the last window to open, show the success message
                if (index === availableServices.length - 1) {
                  setTimeout(() => {
                    if (openedWindows.length === availableServices.length) {
                      alert('👑🌟 Full Royal Suite launched!\n\nAll available characters are now collaborating in a comprehensive industrial scenario. Each dashboard shows their specialized contributions to the overall system.');
                    } else {
                      alert('Some windows may have been blocked by popup blocker. You may need to manually open:\n\n' + dashboardUrls.join('\n'));
                    }
                  }, 200);
                }
              }, index * 300); // Stagger the window opens
              
              leftOffset += 650;
              if (index === 2) {
                leftOffset = 50;
                topOffset += 550;
              }
            }
          });
        } else {
          alert(`Full Royal Suite requires at least 4 active simulators. Currently ${availableServices.length}/5 are online. Please start more simulators before launching.`);
        }
        break;
        
      default:
        alert('Scenario not implemented yet. Coming soon!');
    }
  };

  if (isLoading && services.length === 0) {
    return (
      <div className="p-6">
        <div className="text-center">
          <div className="animate-spin h-8 w-8 border-4 border-blue-500 border-t-transparent rounded-full mx-auto mb-4"></div>
          <p className="text-gray-400">Discovering Node-RED services...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="p-6">
        <div className="bg-red-900/50 border border-red-500 rounded-lg p-4">
          <h3 className="text-red-400 font-medium mb-2">Service Discovery Failed</h3>
          <p className="text-gray-300 text-sm mb-3">{error}</p>
          <button 
            onClick={refresh}
            className="bg-red-600 hover:bg-red-700 px-3 py-1 rounded text-white text-sm"
          >
            Retry Discovery
          </button>
        </div>
      </div>
    );
  }

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
      case 'kyoko': return '🕵️';
      case 'byakuya': return '💼';
      case 'chihiro': return '💻';
      case 'celestia': return '🎨';
      case 'sakura': return '💪';
      default: return '🤖';
    }
  };

  const getCharacterName = (character: string) => {
    switch (character) {
      case 'kyoko': return 'Kyoko Kirigiri';
      case 'byakuya': return 'Byakuya Togami';
      case 'chihiro': return 'Chihiro Fujisaki';
      case 'celestia': return 'Celestia Ludenberg';
      case 'sakura': return 'Sakura Ogami';
      default: return character;
    }
  };

  const getCharacterSpecialization = (character: string) => {
    switch (character) {
      case 'kyoko': return 'Anomaly Detection & Investigation';
      case 'byakuya': return 'Efficiency & Performance Optimization';
      case 'chihiro': return 'Technical Integration & Innovation';
      case 'celestia': return 'UI/UX & Aesthetic Design';
      case 'sakura': return 'Stress Testing & Reliability';
      default: return 'General Purpose';
    }
  };

  const runningCount = services.filter(service => service.status === 'online').length;
  const totalCount = services.length;

  return (
    <div className="space-y-6">
      {/* Popup Permission Guide */}
      {showPopupGuide && (
        <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
          <div className="flex items-start justify-between">
            <div className="flex">
              <div className="flex-shrink-0">
                <svg className="h-5 w-5 text-yellow-400" viewBox="0 0 20 20" fill="currentColor">
                  <path fillRule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
                </svg>
              </div>
              <div className="ml-3">
                <h3 className="text-sm font-medium text-yellow-800">
                  Enable Popups for Multiple Dashboards
                </h3>
                <div className="mt-2 text-sm text-yellow-700">
                  <p className="mb-2">To use collaborative scenarios that open multiple dashboards, please enable popups:</p>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-3 text-xs">
                    <div>
                      <strong>Chrome/Edge:</strong> Click the popup icon in the address bar → "Always allow popups from localhost"
                    </div>
                    <div>
                      <strong>Firefox:</strong> Click the shield icon → "Disable Blocking for This Site"
                    </div>
                    <div>
                      <strong>Safari:</strong> Safari menu → Preferences → Websites → Pop-up Windows → Allow
                    </div>
                    <div>
                      <strong>Alternative:</strong> Manual URLs are provided in the popup message
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div className="flex-shrink-0">
              <button
                onClick={() => setShowPopupGuide(false)}
                className="bg-yellow-100 rounded-md p-1.5 text-yellow-500 hover:bg-yellow-200 focus:outline-none focus:ring-2 focus:ring-yellow-600"
              >
                <span className="sr-only">Dismiss</span>
                <svg className="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
                  <path fillRule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clipRule="evenodd" />
                </svg>
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Overview Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-white rounded-lg shadow-md p-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Active Simulators</p>
              <p className="text-2xl font-bold text-gray-900">{runningCount}/{totalCount}</p>
            </div>
            <Server className="h-8 w-8 text-blue-500" />
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-md p-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Service Discovery</p>
              <p className="text-2xl font-bold text-gray-900">
                {isLoading ? '...' : 'Live'}
              </p>
            </div>
            <Users className="h-8 w-8 text-green-500" />
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-md p-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Dynamic URLs</p>
              <p className="text-2xl font-bold text-gray-900">Active</p>
            </div>
            <Cpu className="h-8 w-8 text-yellow-500" />
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-md p-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">System Health</p>
              <p className={`text-2xl font-bold ${runningCount === totalCount ? 'text-green-600' : 'text-yellow-600'}`}>
                {runningCount === totalCount ? 'Excellent' : 'Partial'}
              </p>
            </div>
            <Activity className="h-8 w-8 text-green-500" />
          </div>
        </div>
      </div>

      {/* Simulator Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-6">
        {services.map((service) => (
          <div 
            key={service.character}
            className={`bg-white rounded-lg shadow-md p-6 border-l-4 ${
              service.status === 'online' ? 'border-green-500' : 
              service.status === 'starting' ? 'border-yellow-500' : 'border-red-500'
            }`}
          >
            {/* Character Header */}
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center space-x-3">
                <span className="text-2xl">{getCharacterEmoji(service.character)}</span>
                <div>
                  <h3 className="font-semibold text-gray-900">{getCharacterName(service.character)}</h3>
                  <p className="text-sm text-gray-600">{getCharacterSpecialization(service.character)}</p>
                </div>
              </div>
              <span className={`px-2 py-1 text-xs font-medium rounded-full ${
                service.status === 'online' ? 'bg-green-100 text-green-800' : 
                service.status === 'starting' ? 'bg-yellow-100 text-yellow-800' : 'bg-red-100 text-red-800'
              }`}>
                {service.status.toUpperCase()}
              </span>
            </div>

            {/* Connection Info */}
            <div className="space-y-2 mb-4">
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">Node-RED Port:</span>
                <span className="font-medium text-gray-900">{service.port}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">MODBUS Port:</span>
                <span className="font-medium text-gray-900">{service.modbus_port}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">Dashboard Path:</span>
                <span className="font-medium text-gray-900 text-xs">
                  {service.dashboardPath || 'Detecting...'}
                </span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">Theme:</span>
                <span className="font-medium text-gray-900">{service.theme}</span>
              </div>
            </div>

            {/* Service Health */}
            {service.status === 'online' && (
              <div className="space-y-2 mb-4">
                <div className="flex justify-between text-sm">
                  <span className="text-gray-600">Last Checked:</span>
                  <span className="font-medium text-gray-900">
                    {new Date(service.lastChecked).toLocaleTimeString()}
                  </span>
                </div>
                {service.responseTime && (
                  <div className="flex justify-between text-sm">
                    <span className="text-gray-600">Response Time:</span>
                    <span className="font-medium text-gray-900">{service.responseTime}ms</span>
                  </div>
                )}
                <div className="flex justify-between text-sm">
                  <span className="text-gray-600">Auto-Discovery:</span>
                  <span className="font-medium text-green-600">Active</span>
                </div>
              </div>
            )}

            {/* Quick Access Links */}
            {service.status === 'online' && (
              <div className="flex space-x-2 mt-3">
                <button
                  onClick={() => handleOpenEditor(service.character)}
                  className="flex-1 text-center px-3 py-1 bg-blue-100 text-blue-700 text-xs font-medium rounded hover:bg-blue-200 transition-colors"
                >
                  Node-RED Editor
                </button>
                <button
                  onClick={() => handleOpenDashboard(service.character)}
                  className="flex-1 text-center px-3 py-1 bg-purple-100 text-purple-700 text-xs font-medium rounded hover:bg-purple-200 transition-colors"
                >
                  Dashboard {service.dashboardPath ? '✓' : '?'}
                </button>
              </div>
            )}
          </div>
        ))}
      </div>

      {/* Collaborative Scenarios Section */}
      <div className="bg-white rounded-lg shadow-md p-6">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-semibold text-gray-900">🤝 Collaborative Scenarios</h3>
          <button
            onClick={() => {
              const testWindow = window.open('about:blank', 'popup-test', 'width=300,height=200');
              if (testWindow) {
                testWindow.document.write('<h2>✅ Popups are enabled!</h2><p>You can now use collaborative scenarios.</p>');
                setTimeout(() => testWindow.close(), 2000);
                alert('✅ Popup test successful! Collaborative scenarios will work properly.');
              } else {
                setShowPopupGuide(true);
                alert('❌ Popups are blocked. Please enable them using the guide above.');
              }
            }}
            className="px-3 py-1 bg-gray-100 hover:bg-gray-200 text-gray-700 text-xs font-medium rounded-md transition-colors"
          >
            Test Popups
          </button>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="border rounded-lg p-4">
            <h4 className="font-medium text-gray-900 mb-2">🕵️💼 Investigation + Efficiency</h4>
            <p className="text-sm text-gray-600 mb-3">
              Kyoko's anomaly detection combined with Byakuya's optimization analysis
            </p>
            <button 
              onClick={() => handleCollaborativeScenario('investigation-efficiency')}
              className="w-full px-4 py-2 bg-indigo-600 text-white text-sm font-medium rounded-md hover:bg-indigo-700 transition-colors"
            >
              Launch Scenario
            </button>
          </div>
          
          <div className="border rounded-lg p-4">
            <h4 className="font-medium text-gray-900 mb-2">💻🎨 Tech + Design</h4>
            <p className="text-sm text-gray-600 mb-3">
              Chihiro's integration skills with Celestia's elegant interfaces
            </p>
            <button 
              onClick={() => handleCollaborativeScenario('tech-design')}
              className="w-full px-4 py-2 bg-indigo-600 text-white text-sm font-medium rounded-md hover:bg-indigo-700 transition-colors"
            >
              Launch Scenario
            </button>
          </div>
          
          <div className="border rounded-lg p-4">
            <h4 className="font-medium text-gray-900 mb-2">💪🔧 Stress Testing Suite</h4>
            <p className="text-sm text-gray-600 mb-3">
              Sakura's reliability testing across all character systems
            </p>
            <button 
              onClick={() => handleCollaborativeScenario('stress-testing')}
              className="w-full px-4 py-2 bg-indigo-600 text-white text-sm font-medium rounded-md hover:bg-indigo-700 transition-colors"
            >
              Launch Scenario
            </button>
          </div>
          
          <div className="border rounded-lg p-4">
            <h4 className="font-medium text-gray-900 mb-2">👑🌟 Full Royal Suite</h4>
            <p className="text-sm text-gray-600 mb-3">
              All characters working together in a comprehensive industrial scenario
            </p>
            <button 
              onClick={() => handleCollaborativeScenario('full-royal-suite')}
              className="w-full px-4 py-2 bg-indigo-600 text-white text-sm font-medium rounded-md hover:bg-indigo-700 transition-colors"
            >
              Launch Scenario
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default NodeRedSimulatorDashboard;
