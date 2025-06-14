import { create } from 'zustand';

// Define interfaces for our store
export interface ISignalData {
  id: string;
  name: string;
  address: number;
  dataType: 'int16' | 'int32' | 'float32' | 'bool' | 'string';
  accessType: 'read' | 'write' | 'readwrite';
  unit?: string;
  category: 'process' | 'control' | 'status' | 'alarm' | 'diagnostic' | 'quality';
  isActive: boolean;
  quality: 'good' | 'bad' | 'uncertain';
  tags: string[];
  alarmLimits?: {
    high?: number;
    low?: number;
    critical?: number;
  };
  lastValue?: number | boolean;
  lastTimestamp?: number;
}

export interface IDeviceData {
  id: string;
  name: string;
  type: 'modbus_tcp' | 'modbus_rtu' | 'ethernet_ip' | 'profinet' | 'opc_ua';
  host: string;
  port?: number;
  characterAgent: 'kyoko' | 'byakuya' | 'chihiro' | 'celestia' | 'sakura';
  signals: ISignalData[];
  actions: any[];
  tags: string[];
  isActive: boolean;
  healthStatus: 'healthy' | 'warning' | 'error' | 'offline';
  lastSeen?: number;
}

export interface IAnalysisData {
  id: string;
  timestamp: number;
  deviceId: string;
  characterAgent: string;
  type: 'anomaly' | 'trend' | 'correlation' | 'prediction' | 'optimization';
  title: string;
  description: string;
  severity: 'info' | 'warning' | 'critical';
  confidence: number;
  recommendations: string[];
}

export interface IAlarmData {
  id: string;
  timestamp: number;
  deviceId: string;
  signalId: string;
  signalName: string;
  severity: 'info' | 'warning' | 'critical';
  message: string;
  value: number | boolean;
  acknowledged: boolean;
}

interface IndustrialStore {
  // State
  devices: IDeviceData[];
  analyses: IAnalysisData[];
  alarms: IAlarmData[];
  isSystemRunning: boolean;
  connectionStatus: 'connected' | 'disconnected' | 'connecting';
  
  // Actions
  addDevice: (device: IDeviceData) => void;
  updateDevice: (deviceId: string, updates: Partial<IDeviceData>) => void;
  removeDevice: (deviceId: string) => void;
  
  updateSignal: (signalData: any) => void;
  
  addAnalysis: (analysis: IAnalysisData) => void;
  
  addAlarm: (alarm: IAlarmData) => void;
  acknowledgeAlarm: (alarmId: string) => void;
  clearAlarms: () => void;
  
  startSystem: () => void;
  stopSystem: () => void;
  setConnectionStatus: (status: 'connected' | 'disconnected' | 'connecting') => void;
  
  // Getters
  getDeviceById: (deviceId: string) => IDeviceData | undefined;
  getSignalsByDevice: (deviceId: string) => ISignalData[];
  getActiveAlarms: () => IAlarmData[];
  getCriticalAlarms: () => IAlarmData[];
}

export const useIndustrialStore = create<IndustrialStore>((set, get) => ({
  // Initial state
  devices: [],
  analyses: [],
  alarms: [],
  isSystemRunning: false,
  connectionStatus: 'disconnected',

  // Device actions
  addDevice: (device) => set((state) => ({
    devices: [...state.devices, device]
  })),

  updateDevice: (deviceId, updates) => set((state) => ({
    devices: state.devices.map(device =>
      device.id === deviceId ? { ...device, ...updates } : device
    )
  })),

  removeDevice: (deviceId) => set((state) => ({
    devices: state.devices.filter(device => device.id !== deviceId)
  })),

  // Signal actions
  updateSignal: (signalData) => set((state) => {
    const { deviceId, signalId, value, timestamp } = signalData;
    
    return {
      devices: state.devices.map(device => {
        if (device.id === deviceId) {
          return {
            ...device,
            signals: device.signals.map(signal => {
              if (signal.id === signalId) {
                return {
                  ...signal,
                  lastValue: value,
                  lastTimestamp: timestamp,
                  quality: 'good'
                };
              }
              return signal;
            })
          };
        }
        return device;
      })
    };
  }),

  // Analysis actions
  addAnalysis: (analysis) => set((state) => ({
    analyses: [analysis, ...state.analyses].slice(0, 100) // Keep last 100 analyses
  })),

  // Alarm actions
  addAlarm: (alarm) => set((state) => ({
    alarms: [alarm, ...state.alarms]
  })),

  acknowledgeAlarm: (alarmId) => set((state) => ({
    alarms: state.alarms.map(alarm =>
      alarm.id === alarmId ? { ...alarm, acknowledged: true } : alarm
    )
  })),

  clearAlarms: () => set({ alarms: [] }),

  // System actions
  startSystem: () => set({ isSystemRunning: true }),
  
  stopSystem: () => set({ isSystemRunning: false }),
  
  setConnectionStatus: (status) => set({ connectionStatus: status }),

  // Getters
  getDeviceById: (deviceId) => {
    const state = get();
    return state.devices.find(device => device.id === deviceId);
  },

  getSignalsByDevice: (deviceId) => {
    const state = get();
    const device = state.devices.find(d => d.id === deviceId);
    return device?.signals || [];
  },

  getActiveAlarms: () => {
    const state = get();
    return state.alarms.filter(alarm => !alarm.acknowledged);
  },

  getCriticalAlarms: () => {
    const state = get();
    return state.alarms.filter(alarm => 
      alarm.severity === 'critical' && !alarm.acknowledged
    );
  }
}));
