// Debug component to show service data
import React from 'react';
import { useNodeRedServices } from '../hooks/useNodeRedServices';

interface DebugServiceInfoProps {
  character: string;
}

export function DebugServiceInfo({ character }: DebugServiceInfoProps) {
  const { services, isLoading, getDashboardUrl, getEditorUrl } = useNodeRedServices();
  
  const service = services.find(s => s.character === character);
  const dashboardUrl = getDashboardUrl(character);
  const editorUrl = getEditorUrl(character);
  
  if (isLoading) {
    return <div className="text-yellow-400">Loading {character}...</div>;
  }
  
  return (
    <div className="bg-gray-700 p-4 rounded">
      <h4 className="font-bold text-white mb-2">{character} Debug Info</h4>
      <div className="text-sm space-y-1">
        <p><span className="text-gray-400">Services loaded:</span> {services.length}</p>
        <p><span className="text-gray-400">Service found:</span> {service ? '✅ Yes' : '❌ No'}</p>
        {service && (
          <>
            <p><span className="text-gray-400">Status:</span> {service.status}</p>
            <p><span className="text-gray-400">Port:</span> {service.port}</p>
            <p><span className="text-gray-400">Dashboard path:</span> {service.dashboardPath}</p>
          </>
        )}
        <p><span className="text-gray-400">Dashboard URL:</span> {dashboardUrl || '❌ null'}</p>
        <p><span className="text-gray-400">Editor URL:</span> {editorUrl || '❌ null'}</p>
      </div>
    </div>
  );
}
