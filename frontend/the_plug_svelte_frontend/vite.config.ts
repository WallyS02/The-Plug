import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'


// https://vitejs.dev/config/
export default defineConfig({
  server: {
    proxy: {
      '/api': {
        'target': 'http://localhost:8080',
        'secure': false,
        'changeOrigin': true
      }
    },
    port: 80,
  },
  plugins: [svelte()]
})
