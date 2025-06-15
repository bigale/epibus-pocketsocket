// API endpoint to stop Node-RED simulators
import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

export async function POST() {
  try {
    console.log('API: Stopping Node-RED simulators...');
    
    const scriptPath = '/home/bigale/repos/icpxmldb/ai-kit/industrial-iot/node-red-plc-simulator/scripts/manage.sh';
    const command = `${scriptPath} stop`;
    
    const { stdout, stderr } = await execAsync(command);
    
    console.log('Stop command output:', stdout);
    if (stderr) console.log('Stop command stderr:', stderr);
    
    return new Response(JSON.stringify({
      success: true,
      message: 'Node-RED simulators stopped successfully',
      output: stdout
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });
    
  } catch (error) {
    console.error('Error stopping simulators:', error);
    
    return new Response(JSON.stringify({
      success: false,
      message: 'Failed to stop Node-RED simulators',
      error: error instanceof Error ? error.message : String(error)
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
}
