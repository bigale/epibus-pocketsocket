// Flow Action Buttons Component - Dynamic Node-RED Service Integration
import React from 'react';
import { useNodeRedServices } from '../hooks/useNodeRedServices';

interface FlowActionButtonsProps {
  character: string;
  characterColor: string;
}

export function FlowActionButtons({ character, characterColor }: FlowActionButtonsProps) {
  const { services, isLoading, getDashboardUrl, getEditorUrl } = useNodeRedServices();
  
  const service = services.find(s => s.character === character);
  const dashboardUrl = getDashboardUrl(character);
  const editorUrl = getEditorUrl(character);
  
  const handleOpenDashboard = () => {
    if (dashboardUrl) {
      window.open(dashboardUrl, '_blank');
    } else {
      alert(`❌ ${character} dashboard is not available. Please check if the service is running.`);
    }
  };
  
  const handleOpenEditor = () => {
    if (editorUrl) {
      window.open(editorUrl, '_blank');
    } else {
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
  
  return (
    <div className="flex gap-4">
      <button
        onClick={handleOpenDashboard}
        disabled={!dashboardUrl}
        className={`${
          isOnline 
            ? `bg-${characterColor}-600 hover:bg-${characterColor}-700` 
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
