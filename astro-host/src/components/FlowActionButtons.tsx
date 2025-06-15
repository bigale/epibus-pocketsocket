// Flow Action Buttons Component - Dynamic Node-RED Service Integration
import React from 'react';
import { useNodeRedServices } from '../hooks/useNodeRedServices';

interface FlowActionButtonsProps {
  character: string;
  characterColor: string;
}

export function FlowActionButtons({ character, characterColor }: FlowActionButtonsProps) {
  const { services, isLoading, getDashboardUrl, getEditorUrl } = useNodeRedServices();
  
  // Define color classes explicitly to ensure they're included in Tailwind build
  const getColorClasses = (color: string) => {
    switch (color) {
      case 'purple': return 'bg-purple-600 hover:bg-purple-700';
      case 'yellow': return 'bg-yellow-600 hover:bg-yellow-700';
      case 'green': return 'bg-green-600 hover:bg-green-700';
      case 'red': return 'bg-red-600 hover:bg-red-700';
      case 'pink': return 'bg-pink-600 hover:bg-pink-700';
      default: return 'bg-blue-600 hover:bg-blue-700';
    }
  };
  
  const service = services.find(s => s.character === character);
  const dashboardUrl = getDashboardUrl(character);
  const editorUrl = getEditorUrl(character);
  
  // Debug logging
  console.log(`🎭 FlowActionButtons render for ${character}:`, {
    servicesCount: services.length,
    serviceFound: !!service,
    serviceStatus: service?.status,
    dashboardUrl,
    editorUrl,
    isLoading
  });
  
  const handleOpenDashboard = () => {
    console.log(`🔗 Dashboard button clicked for ${character}`);
    console.log(`   Service found:`, service);
    console.log(`   Dashboard URL:`, dashboardUrl);
    console.log(`   Service status:`, service?.status);
    console.log(`   Dashboard path:`, service?.dashboardPath);
    
    if (dashboardUrl) {
      console.log(`   ✅ Opening dashboard: ${dashboardUrl}`);
      window.open(dashboardUrl, '_blank');
    } else {
      console.log(`   ❌ Dashboard URL is null/undefined`);
      alert(`❌ ${character} dashboard is not available. Please check if the service is running.`);
    }
  };
  
  const handleOpenEditor = () => {
    console.log(`⚙️ Editor button clicked for ${character}`);
    console.log(`   Service found:`, service);
    console.log(`   Editor URL:`, editorUrl);
    console.log(`   Service status:`, service?.status);
    
    if (editorUrl) {
      console.log(`   ✅ Opening editor: ${editorUrl}`);
      window.open(editorUrl, '_blank');
    } else {
      console.log(`   ❌ Editor URL is null/undefined`);
      alert(`❌ ${character} Node-RED editor is not available. Please check if the service is running.`);
    }
  };
  
  if (isLoading) {
    return (
      <div className="flex gap-4">
        <div className="bg-gray-600 text-white px-6 py-3 rounded-lg opacity-50">
          <span className="inline-flex items-center gap-2">
            <span className="animate-spin">⟳</span>
            Loading Dashboard...
          </span>
        </div>
        <div className="bg-gray-600 text-white px-6 py-3 rounded-lg opacity-50">
          <span className="inline-flex items-center gap-2">
            <span className="animate-spin">⟳</span>
            Loading Editor...
          </span>
        </div>
      </div>
    );
  }
  
  const isOnline = service?.status === 'online';
  const dashboardStatus = service?.dashboardPath ? '✓' : (isOnline ? '?' : '❌');
  const editorStatus = isOnline ? '✓' : '❌';
  
  const colorClasses = getColorClasses(characterColor);
  
  return (
    <div className="flex gap-4">
      <button
        onClick={handleOpenDashboard}
        disabled={!dashboardUrl}
        className={`${
          isOnline 
            ? colorClasses
            : 'bg-gray-500'
        } text-white px-6 py-3 rounded-lg transition-colors inline-flex items-center gap-2 ${
          !dashboardUrl ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer'
        }`}
        title={isOnline ? `Open ${character} dashboard` : `${character} service is offline`}
      >
        🔗 Open {character} Dashboard {dashboardStatus}
      </button>
      
      <button
        onClick={handleOpenEditor}
        disabled={!editorUrl}
        className={`${
          isOnline 
            ? 'bg-gray-600 hover:bg-gray-700' 
            : 'bg-gray-500'
        } text-white px-6 py-3 rounded-lg transition-colors inline-flex items-center gap-2 ${
          !editorUrl ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer'
        }`}
        title={isOnline ? `Open ${character} Node-RED editor` : `${character} service is offline`}
      >
        ⚙️ Node-RED Editor {editorStatus}
      </button>
    </div>
  );
}
