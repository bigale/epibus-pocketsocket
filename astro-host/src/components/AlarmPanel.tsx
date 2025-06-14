import React from 'react';
import { AlertTriangle, AlertCircle, Bell, X } from 'lucide-react';

interface Alarm {
  id: string;
  title: string;
  severity: 'low' | 'medium' | 'high' | 'critical';
  timestamp: string;
  description: string;
  acknowledged: boolean;
  source: string;
}

const mockAlarms: Alarm[] = [
  {
    id: 'alarm_001',
    title: 'High Temperature Alert',
    severity: 'medium',
    timestamp: '14:15:32',
    description: 'Temperature sensor 1 reading 85°C, exceeding threshold of 80°C',
    acknowledged: false,
    source: 'Temperature Sensor 1'
  },
  {
    id: 'alarm_002',
    title: 'Pressure Drop Detected',
    severity: 'high',
    timestamp: '14:12:15',
    description: 'System pressure dropped below 3.5 bar, check for leaks',
    acknowledged: false,
    source: 'Pressure Sensor 1'
  },
  {
    id: 'alarm_003',
    title: 'Vibration Anomaly',
    severity: 'low',
    timestamp: '14:05:22',
    description: 'Unusual vibration pattern detected on Motor 2',
    acknowledged: true,
    source: 'Vibration Monitor'
  }
];

const AlarmPanel: React.FC = () => {
  const getSeverityColor = (severity: string, acknowledged: boolean) => {
    if (acknowledged) return 'text-gray-600 bg-gray-100 border-gray-200';
    
    switch (severity) {
      case 'low': return 'text-blue-600 bg-blue-100 border-blue-200';
      case 'medium': return 'text-yellow-600 bg-yellow-100 border-yellow-200';
      case 'high': return 'text-orange-600 bg-orange-100 border-orange-200';
      case 'critical': return 'text-red-600 bg-red-100 border-red-200';
      default: return 'text-gray-600 bg-gray-100 border-gray-200';
    }
  };

  const getSeverityIcon = (severity: string, acknowledged: boolean) => {
    if (acknowledged) return <X className="w-5 h-5" />;
    
    switch (severity) {
      case 'critical':
      case 'high':
        return <AlertTriangle className="w-5 h-5" />;
      case 'medium':
      case 'low':
        return <AlertCircle className="w-5 h-5" />;
      default:
        return <Bell className="w-5 h-5" />;
    }
  };

  const activeAlarms = mockAlarms.filter(alarm => !alarm.acknowledged);
  const acknowledgedAlarms = mockAlarms.filter(alarm => alarm.acknowledged);

  return (
    <div className="bg-white rounded-lg shadow-lg p-6">
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-xl font-bold text-gray-900 flex items-center">
          <Bell className="w-6 h-6 mr-2 text-red-600" />
          Alarm Panel
        </h2>
        <div className="flex items-center space-x-4">
          {activeAlarms.length > 0 && (
            <div className="flex items-center space-x-2">
              <div className="w-2 h-2 bg-red-500 rounded-full animate-pulse"></div>
              <span className="text-sm text-red-600 font-medium">
                {activeAlarms.length} Active Alarm{activeAlarms.length !== 1 ? 's' : ''}
              </span>
            </div>
          )}
        </div>
      </div>

      {/* Active Alarms */}
      <div className="mb-6">
        <h3 className="text-lg font-semibold text-red-700 mb-3">Active Alarms</h3>
        {activeAlarms.length === 0 ? (
          <div className="text-center py-8 text-gray-500">
            <Bell className="w-12 h-12 mx-auto mb-2 text-gray-300" />
            <p>No active alarms</p>
          </div>
        ) : (
          <div className="space-y-3">
            {activeAlarms.map((alarm) => (
              <div key={alarm.id} className={`p-4 border rounded-lg ${getSeverityColor(alarm.severity, alarm.acknowledged)}`}>
                <div className="flex items-start justify-between mb-2">
                  <div className="flex items-center space-x-2">
                    {getSeverityIcon(alarm.severity, alarm.acknowledged)}
                    <h4 className="font-semibold">{alarm.title}</h4>
                  </div>
                  <div className="flex items-center space-x-2">
                    <span className="text-sm font-medium">{alarm.severity.toUpperCase()}</span>
                    <span className="text-sm text-gray-500">{alarm.timestamp}</span>
                  </div>
                </div>
                
                <p className="text-sm mb-2">{alarm.description}</p>
                
                <div className="flex items-center justify-between">
                  <span className="text-xs text-gray-500">Source: {alarm.source}</span>
                  <button className="px-3 py-1 bg-blue-600 text-white text-sm rounded hover:bg-blue-700 transition-colors">
                    Acknowledge
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Acknowledged Alarms */}
      {acknowledgedAlarms.length > 0 && (
        <div>
          <h3 className="text-lg font-semibold text-gray-700 mb-3">Recent Acknowledged</h3>
          <div className="space-y-2">
            {acknowledgedAlarms.map((alarm) => (
              <div key={alarm.id} className={`p-3 border rounded ${getSeverityColor(alarm.severity, alarm.acknowledged)}`}>
                <div className="flex items-center justify-between">
                  <div className="flex items-center space-x-2">
                    {getSeverityIcon(alarm.severity, alarm.acknowledged)}
                    <span className="font-medium line-through">{alarm.title}</span>
                  </div>
                  <span className="text-sm text-gray-500">{alarm.timestamp}</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export default AlarmPanel;
