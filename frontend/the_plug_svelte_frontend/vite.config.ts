import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'
import viteCompression from 'vite-plugin-compression';
import viteImagemin from 'vite-plugin-imagemin';


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
  ],
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
  }
})
