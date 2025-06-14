import React from 'react';
import { Activity, Signal, Zap, TrendingUp } from 'lucide-react';

interface SignalData {
  id: string;
  name: string;
  value: number;
  unit: string;
  status: 'normal' | 'warning' | 'critical';
  trend: 'up' | 'down' | 'stable';
}

const mockSignals: SignalData[] = [
  {
    id: 'temp_1',
    name: 'Temperature 1',
    value: 72.5,
    unit: '°C',
    status: 'normal',
    trend: 'stable'
  },
  {
    id: 'pressure_1',
    name: 'Pressure 1',
    value: 4.2,
    unit: 'bar',
    status: 'warning',
    trend: 'up'
  },
  {
    id: 'flow_rate',
    name: 'Flow Rate',
    value: 125.8,
    unit: 'L/min',
    status: 'normal',
    trend: 'down'
  },
  {
    id: 'voltage',
    name: 'Line Voltage',
    value: 415.2,
    unit: 'V',
    status: 'critical',
    trend: 'down'
  }
];

const SignalMonitor: React.FC = () => {
  const getStatusColor = (status: string) => {
    switch (status) {
      case 'normal': return 'text-green-600 bg-green-100';
      case 'warning': return 'text-yellow-600 bg-yellow-100';
      case 'critical': return 'text-red-600 bg-red-100';
      default: return 'text-gray-600 bg-gray-100';
    }
  };

  const getTrendIcon = (trend: string) => {
    switch (trend) {
      case 'up': return <TrendingUp className="w-4 h-4 text-green-500" />;
      case 'down': return <TrendingUp className="w-4 h-4 text-red-500 rotate-180" />;
      case 'stable': return <Activity className="w-4 h-4 text-blue-500" />;
      default: return <Signal className="w-4 h-4 text-gray-500" />;
    }
  };

  return (
    <div className="bg-white rounded-lg shadow-lg p-6">
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-xl font-bold text-gray-900 flex items-center">
          <Signal className="w-6 h-6 mr-2 text-blue-600" />
          Signal Monitor
        </h2>
        <div className="flex items-center space-x-2">
          <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
          <span className="text-sm text-gray-500">Live</span>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {mockSignals.map((signal) => (
          <div key={signal.id} className="p-4 border rounded-lg hover:shadow-md transition-shadow">
            <div className="flex items-center justify-between mb-2">
              <span className="font-medium text-gray-900">{signal.name}</span>
              {getTrendIcon(signal.trend)}
            </div>
            
            <div className="flex items-center justify-between">
              <div className="text-2xl font-bold text-gray-900">
                {signal.value}
                <span className="text-sm font-normal text-gray-500 ml-1">
                  {signal.unit}
                </span>
              </div>
              
              <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(signal.status)}`}>
                {signal.status.toUpperCase()}
              </span>
            </div>
          </div>
        ))}
      </div>

      <div className="mt-6 pt-4 border-t border-gray-200">
        <div className="flex items-center justify-between text-sm text-gray-500">
          <span>Last Update: {new Date().toLocaleTimeString()}</span>
          <div className="flex items-center">
            <Zap className="w-4 h-4 mr-1" />
            <span>Real-time monitoring active</span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SignalMonitor;
