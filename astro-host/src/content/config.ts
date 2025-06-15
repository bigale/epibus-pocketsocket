import { defineCollection, z } from 'astro:content';

// Define schema for simulator logs
const simulatorLogs = defineCollection({
  type: 'data',
  schema: z.object({
    character: z.enum(['kyoko', 'byakuya', 'chihiro', 'celestia', 'sakura']),
    timestamp: z.string().transform((str) => new Date(str)),
    level: z.enum(['info', 'warn', 'error', 'debug']),
    message: z.string(),
    nodeId: z.string().optional(),
    flowId: z.string().optional(),
    data: z.record(z.any()).optional(),
    metrics: z.object({
      cpu: z.number().optional(),
      memory: z.number().optional(),
      connections: z.number().optional(),
      messagesPerSecond: z.number().optional()
    }).optional()
  })
});

// Define schema for Node-RED flow documentation
const nodeRedFlows = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    character: z.enum(['kyoko', 'byakuya', 'chihiro', 'celestia', 'sakura']),
    description: z.string(),
    version: z.string(),
    tags: z.array(z.string()),
    difficulty: z.enum(['beginner', 'intermediate', 'advanced']),
    lastUpdated: z.string().transform((str) => new Date(str)),
    author: z.string(),
    flowId: z.string(),
    nodes: z.array(z.object({
      id: z.string(),
      type: z.string(),
      name: z.string().optional(),
      description: z.string().optional()
    })),
    inputPorts: z.array(z.object({
      name: z.string(),
      type: z.string(),
      description: z.string()
    })).optional(),
    outputPorts: z.array(z.object({
      name: z.string(),
      type: z.string(),
      description: z.string()
    })).optional(),
    configuration: z.record(z.any()).optional()
  })
});

// Define schema for industrial alerts/alarms
const industrialAlerts = defineCollection({
  type: 'data',
  schema: z.object({
    id: z.string(),
    character: z.enum(['kyoko', 'byakuya', 'chihiro', 'celestia', 'sakura']),
    timestamp: z.string().transform((str) => new Date(str)),
    severity: z.enum(['low', 'medium', 'high', 'critical']),
    type: z.enum(['temperature', 'pressure', 'flow', 'quality', 'safety', 'network']),
    source: z.object({
      deviceId: z.string(),
      deviceName: z.string(),
      location: z.string().optional()
    }),
    message: z.string(),
    value: z.number().optional(),
    threshold: z.number().optional(),
    unit: z.string().optional(),
    acknowledged: z.boolean().default(false),
    resolvedAt: z.string().transform((str) => new Date(str)).optional(),
    notes: z.string().optional()
  })
});

// Define schema for performance metrics
const performanceMetrics = defineCollection({
  type: 'data',
  schema: z.object({
    character: z.enum(['kyoko', 'byakuya', 'chihiro', 'celestia', 'sakura']),
    timestamp: z.string().transform((str) => new Date(str)),
    systemMetrics: z.object({
      cpu: z.number(),
      memory: z.number(),
      disk: z.number(),
      network: z.object({
        bytesIn: z.number(),
        bytesOut: z.number(),
        packetsIn: z.number(),
        packetsOut: z.number()
      })
    }),
    nodeRedMetrics: z.object({
      activeFlows: z.number(),
      totalNodes: z.number(),
      messagesPerSecond: z.number(),
      errorRate: z.number(),
      uptime: z.number()
    }),
    industrialMetrics: z.object({
      connectedDevices: z.number(),
      dataPointsPerSecond: z.number(),
      alarmCount: z.number(),
      qualityPercentage: z.number()
    })
  })
});

export const collections = {
  'simulator-logs': simulatorLogs,
  'node-red-flows': nodeRedFlows,
  'industrial-alerts': industrialAlerts,
  'performance-metrics': performanceMetrics
};
