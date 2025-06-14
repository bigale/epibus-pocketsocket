import React from 'react';

interface Device {
  id: string;
  name: string;
  type: string;
  healthStatus: string;
  signals: Array<{
    id: string;
    name: string;
    lastValue?: number | boolean;
    unit?: string;
    quality: string;
  }>;
}

interface Props {
  devices: Device[];
}

const PLCDashboard: React.FC<Props> = ({ devices }) => {
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold text-white">PLC Devices Overview</h2>
        <div className="text-sm text-gray-400">
          {devices.length} device{devices.length !== 1 ? 's' : ''} connected
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {devices.map((device) => (
          <div key={device.id} className="bg-gray-800 rounded-lg p-6 border border-gray-700">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold text-white">{device.name}</h3>
              <div className={`w-3 h-3 rounded-full ${
                device.healthStatus === 'healthy' ? 'bg-green-500' :
                device.healthStatus === 'warning' ? 'bg-yellow-500' : 'bg-red-500'
              }`} />
            </div>
            
            <div className="space-y-3">
              <div className="text-sm text-gray-400">
                Type: <span className="text-white">{device.type}</span>
              </div>
              
              <div className="space-y-2">
                <div className="text-sm font-medium text-gray-300">Recent Signals:</div>
                {device.signals.slice(0, 3).map((signal) => (
                  <div key={signal.id} className="flex justify-between text-sm">
                    <span className="text-gray-400">{signal.name}:</span>
                    <span className="text-white">
                      {signal.lastValue !== undefined ? 
                        `${signal.lastValue}${signal.unit ? ` ${signal.unit}` : ''}` : 
                        'No data'
                      }
                    </span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        ))}
      </div>

      {devices.length === 0 && (
        <div className="text-center py-12">
          <div className="text-gray-400 text-lg">No PLC devices connected</div>
          <div className="text-gray-500 text-sm mt-2">Add devices to start monitoring</div>
        </div>
      )}
    </div>
  );
};

export default PLCDashboard;
