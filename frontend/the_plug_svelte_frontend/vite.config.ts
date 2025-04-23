import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'
import viteCompression from 'vite-plugin-compression';
import viteImagemin from 'vite-plugin-imagemin';
import {svelteTesting} from "@testing-library/svelte/vite";


// https://vitejs.dev/config/
// @ts-ignore
// @ts-ignore
// @ts-ignore
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
  plugins: [
      svelte(),
      viteCompression({
        algorithm: 'gzip',
        ext: '.gz',
      }),
      viteImagemin({
        gifsicle: { optimizationLevel: 3 },
        optipng: { optimizationLevel: 5 },
        mozjpeg: { quality: 75 },
        pngquant: { quality: [0.65, 0.9], speed: 4 },
        svgo: {
          plugins: [{ removeViewBox: false }, { cleanupIDs: false }],
        },
      }),
      svelteTesting()
  ],
  // @ts-ignore
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./vitest-setup.ts'],
    include: ['src/**/*.spec.ts'],
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
  }
})
