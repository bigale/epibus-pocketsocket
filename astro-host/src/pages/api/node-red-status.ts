// API endpoint for Node-RED service discovery and health checks
import type { APIRoute } from 'astro';
import { serviceDiscovery } from '../../utils/nodeRedServiceDiscovery';

export const GET: APIRoute = async ({ request }) => {
  try {
    const url = new URL(request.url);
    const refresh = url.searchParams.get('refresh') === 'true';
    
    // Always do a fresh discovery for now to ensure accuracy
    const result = await serviceDiscovery.discoverServices();
    
    return new Response(JSON.stringify(result, null, 2), {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Access-Control-Allow-Origin': '*'
      }
    });
  } catch (error) {
    console.error('Service discovery error:', error);
    
    return new Response(JSON.stringify({
      error: 'Service discovery failed',
      message: error instanceof Error ? error.message : 'Unknown error',
      timestamp: new Date().toISOString()
    }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json'
      }
    });
  }
};

export const POST: APIRoute = async ({ request }) => {
  try {
    const body = await request.json();
    const { character } = body;
    
    if (!character) {
      return new Response(JSON.stringify({
        error: 'Character name required'
      }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      });
    }
    
    // Force refresh for specific character
    const result = await serviceDiscovery.discoverServices();
    const service = result.services.find(s => s.character === character);
    
    if (!service) {
      return new Response(JSON.stringify({
        error: 'Character not found'
      }), {
        status: 404,
        headers: { 'Content-Type': 'application/json' }
      });
    }
    
    return new Response(JSON.stringify(service), {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      }
    });
  } catch (error) {
    return new Response(JSON.stringify({
      error: 'Failed to check character service',
      message: error instanceof Error ? error.message : 'Unknown error'
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
};
