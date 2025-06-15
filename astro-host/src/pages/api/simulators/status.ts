// API endpoint to check Node-RED simulator status
import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

export async function GET() {
  try {
    console.log('API: Checking Node-RED simulator status...');
    
    const scriptPath = '/home/bigale/repos/icpxmldb/ai-kit/industrial-iot/node-red-plc-simulator/scripts/manage.sh';
    const command = `${scriptPath} status`;
    
    const { stdout, stderr } = await execAsync(command);
    
    console.log('Status command output:', stdout);
    if (stderr) console.log('Status command stderr:', stderr);
    
    // Parse the output to determine if simulators are running
    const isRunning = stdout.includes('running') && !stdout.includes('0/5 simulators running');
    const runningCount = stdout.match(/(\d+)\/5 simulators running/)?.[1] || '0';
    
    return new Response(JSON.stringify({
      success: true,
      isRunning: isRunning,
      runningCount: parseInt(runningCount),
      totalCount: 5,
      status: stdout,
      message: isRunning ? 'Simulators are running' : 'Simulators are stopped'
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });
    
  } catch (error) {
    console.error('Error checking simulator status:', error);
    
    return new Response(JSON.stringify({
      success: false,
      isRunning: false,
      runningCount: 0,
      totalCount: 5,
      message: 'Failed to check Node-RED simulator status',
      error: error instanceof Error ? error.message : String(error)
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
}
