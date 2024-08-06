import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'
import { readFileSync } from 'fs'

const proxyConfig = JSON.parse(readFileSync('src/proxy.conf.json', 'utf-8'));

// https://vitejs.dev/config/
export default defineConfig({
  server: {
    proxy: proxyConfig,
    port: 80,
  },
  plugins: [svelte()],
  define: {
    'process.env': process.env
  }
})
