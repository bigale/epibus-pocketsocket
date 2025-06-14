import React from 'react';
import { Brain, TrendingUp, AlertTriangle, CheckCircle } from 'lucide-react';

interface AnalysisResult {
  id: string;
  title: string;
  status: 'good' | 'warning' | 'critical';
  confidence: number;
  description: string;
  recommendation: string;
}

const mockAnalysisResults: AnalysisResult[] = [
  {
    id: 'temp_analysis',
    title: 'Temperature Trend Analysis',
    status: 'good',
    confidence: 94,
    description: 'Temperature patterns are within normal operating range',
    recommendation: 'Continue monitoring - system operating optimally'
  },
  {
    id: 'efficiency_analysis',
    title: 'Process Efficiency',
    status: 'warning',
    confidence: 87,
    description: 'Efficiency has decreased by 3% over the last hour',
    recommendation: 'Check valve positions and flow rates'
  },
  {
    id: 'predictive_maintenance',
    title: 'Predictive Maintenance',
    status: 'warning',
    confidence: 76,
    description: 'Vibration patterns suggest bearing wear',
    recommendation: 'Schedule maintenance within 72 hours'
  }
];

const AnalysisPanel: React.FC = () => {
  const getStatusColor = (status: string) => {
    switch (status) {
      case 'good': return 'text-green-600 bg-green-100 border-green-200';
      case 'warning': return 'text-yellow-600 bg-yellow-100 border-yellow-200';
      case 'critical': return 'text-red-600 bg-red-100 border-red-200';
      default: return 'text-gray-600 bg-gray-100 border-gray-200';
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'good': return <CheckCircle className="w-5 h-5" />;
      case 'warning': return <AlertTriangle className="w-5 h-5" />;
      case 'critical': return <AlertTriangle className="w-5 h-5" />;
      default: return <Brain className="w-5 h-5" />;
    }
  };

  return (
    <div className="bg-white rounded-lg shadow-lg p-6">
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-xl font-bold text-gray-900 flex items-center">
          <Brain className="w-6 h-6 mr-2 text-purple-600" />
          AI Analysis Panel
        </h2>
        <div className="flex items-center space-x-2">
          <TrendingUp className="w-4 h-4 text-blue-500" />
          <span className="text-sm text-gray-500">SUIL Engine Active</span>
        </div>
      </div>

      <div className="space-y-4">
        {mockAnalysisResults.map((analysis) => (
          <div key={analysis.id} className={`p-4 border rounded-lg ${getStatusColor(analysis.status)}`}>
            <div className="flex items-start justify-between mb-2">
              <div className="flex items-center space-x-2">
                {getStatusIcon(analysis.status)}
                <h3 className="font-semibold">{analysis.title}</h3>
              </div>
              <span className="text-sm font-medium">
                {analysis.confidence}% confidence
              </span>
            </div>
            
            <p className="text-sm mb-2">{analysis.description}</p>
            
            <div className="bg-white bg-opacity-50 p-3 rounded border-l-4 border-blue-500">
              <p className="text-sm font-medium text-blue-800">Recommendation:</p>
              <p className="text-sm text-blue-700">{analysis.recommendation}</p>
            </div>
          </div>
        ))}
      </div>

      <div className="mt-6 pt-4 border-t border-gray-200">
        <div className="text-sm text-gray-500 text-center">
          <span>AI Analysis powered by SUIL Intelligence Engine • Last updated: {new Date().toLocaleTimeString()}</span>
        </div>
      </div>
    </div>
  );
};

export default AnalysisPanel;
