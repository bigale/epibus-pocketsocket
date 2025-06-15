// API endpoint to start Node-RED simulators
import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

export async function POST() {
  try {
    console.log('API: Starting Node-RED simulators...');
    
    const scriptPath = '/home/bigale/repos/icpxmldb/ai-kit/industrial-iot/node-red-plc-simulator/scripts/manage.sh';
    const command = `${scriptPath} start`;
    
    const { stdout, stderr } = await execAsync(command);
    
    console.log('Start command output:', stdout);
    if (stderr) console.log('Start command stderr:', stderr);
    
    return new Response(JSON.stringify({
      success: true,
      message: 'Node-RED simulators started successfully',
      output: stdout
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });
    
  } catch (error) {
    console.error('Error starting simulators:', error);
    
    return new Response(JSON.stringify({
      success: false,
      message: 'Failed to start Node-RED simulators',
      error: error instanceof Error ? error.message : String(error)
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
}
