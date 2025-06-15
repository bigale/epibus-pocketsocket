// Flow Action Buttons - Same Tab Navigation (No Popups)
import React from 'react';

interface SameTabFlowActionButtonsProps {
  character: string;
  characterColor: string;
}

export function SameTabFlowActionButtons({ character, characterColor }: SameTabFlowActionButtonsProps) {
  
  const characterPorts = {
    kyoko: 1881,
    byakuya: 1882,
    chihiro: 1883,
    celestia: 1884,
    sakura: 1885
  };
  
  const port = characterPorts[character as keyof typeof characterPorts];
  
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
  
  const handleOpenDashboard = () => {
    const dashboardUrl = `http://localhost:${port}/api/ui/`;
    console.log(`🔗 SameTabFlowActionButtons: Navigating to ${character} dashboard: ${dashboardUrl}`);
    window.location.href = dashboardUrl;
  };
  
  const handleOpenEditor = () => {
    const editorUrl = `http://localhost:${port}/`;
    console.log(`⚙️ SameTabFlowActionButtons: Navigating to ${character} editor: ${editorUrl}`);
    window.location.href = editorUrl;
  };
  
  const colorClasses = getColorClasses(characterColor);
  
  if (!port) {
    return (
      <div className="flex gap-4">
        <div className="bg-red-600 text-white px-6 py-3 rounded-lg">
          ❌ Error: No port mapping for "{character}"
        </div>
      </div>
    );
  }
  
  return (
    <div className="flex gap-4">
      <button
        onClick={handleOpenDashboard}
        className={`${colorClasses} text-white px-6 py-3 rounded-lg transition-colors inline-flex items-center gap-2 cursor-pointer`}
        title={`Open ${character} dashboard (port ${port}) - Same tab navigation`}
      >
        🔗 Open {character} Dashboard ✓
      </button>
      
      <button
        onClick={handleOpenEditor}
        className="bg-gray-600 hover:bg-gray-700 text-white px-6 py-3 rounded-lg transition-colors inline-flex items-center gap-2 cursor-pointer"
        title={`Open ${character} Node-RED editor (port ${port}) - Same tab navigation`}
      >
        ⚙️ Node-RED Editor ✓
      </button>
    </div>
  );
}
