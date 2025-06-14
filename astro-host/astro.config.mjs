import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import tailwind from '@astrojs/tailwind';

export default defineConfig({
  integrations: [
    react(),
    tailwind()
  ],
  server: {
    port: 3000,
    host: true
  },
  build: {
    assets: 'assets'
  },
  vite: {
    server: {
      watch: {
        usePolling: true
      }
    },
    optimizeDeps: {
      include: ['react', 'react-dom']
    }
  }
});
