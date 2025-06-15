// Simple Flow Action Buttons - Static Version for Testing
import React from 'react';

interface SimpleFlowActionButtonsProps {
  character: string;
  characterColor: string;
}

export function SimpleFlowActionButtons({ character, characterColor }: SimpleFlowActionButtonsProps) {
  
  const characterPorts = {
    kyoko: 1881,
    byakuya: 1882,
    chihiro: 1883,
    celestia: 1884,
    sakura: 1885
  };
  
  const port = characterPorts[character as keyof typeof characterPorts];
  
  // Debug logging
  console.log(`🎭 SimpleFlowActionButtons initialized for character: "${character}", port: ${port}, color: "${characterColor}"`);
  
  if (!port) {
    console.error(`❌ No port mapping found for character: "${character}"`);
  }
  
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
    console.log(`🔗 SimpleFlowActionButtons: Opening dashboard for ${character}: ${dashboardUrl}`);
    try {
      window.open(dashboardUrl, '_blank');
      console.log(`✅ Window.open called successfully for ${character} dashboard`);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      console.error(`❌ Error opening ${character} dashboard:`, error);
      alert(`Error opening ${character} dashboard: ${errorMessage}`);
    }
  };
  
  const handleOpenEditor = () => {
    const editorUrl = `http://localhost:${port}/`;
    console.log(`⚙️ SimpleFlowActionButtons: Opening editor for ${character}: ${editorUrl}`);
    try {
      window.open(editorUrl, '_blank');
      console.log(`✅ Window.open called successfully for ${character} editor`);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      console.error(`❌ Error opening ${character} editor:`, error);
      alert(`Error opening ${character} editor: ${errorMessage}`);
    }
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
        title={`Open ${character} dashboard (port ${port})`}
      >
        🔗 Open {character} Dashboard ✓
      </button>
      
      <button
        onClick={handleOpenEditor}
        className="bg-gray-600 hover:bg-gray-700 text-white px-6 py-3 rounded-lg transition-colors inline-flex items-center gap-2 cursor-pointer"
        title={`Open ${character} Node-RED editor (port ${port})`}
      >
        ⚙️ Node-RED Editor ✓
      </button>
    </div>
  );
}
