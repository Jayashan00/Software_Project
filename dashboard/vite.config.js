import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    // This is the core fix for the 5173/8080 cross-origin issue
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
        secure: false,
      }
    },
    // If your default port 5173 is busy, Vite will automatically try 5174, 5175, etc.
    // If you want to force 5174, you can uncomment this:
    // port: 5174,
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
  },
});
