import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'node:path'
import autoprefixer from 'autoprefixer'
import viteSharp from 'vite-plugin-sharp'

// Load the entry stylesheet without blocking first render (async CSS pattern).
// The app shell is empty until the deferred module script mounts Vue, so the
// stylesheet normally applies before any content is painted.
const deferEntryCss = () => ({
  name: 'defer-entry-css',
  transformIndexHtml(html) {
    return html.replace(
      /<link rel="stylesheet" crossorigin href="([^"]+\.css)">/,
      (match, href) =>
        `<link rel="stylesheet" crossorigin href="${href}" media="print" onload="this.media='all'">\n    <noscript><link rel="stylesheet" crossorigin href="${href}"></noscript>`,
    )
  },
})

export default defineConfig(() => {
  return {
    plugins: [
      vue(),
      deferEntryCss(),
      viteSharp({
        compress: {
          jpeg: { quality: 80 },
          png: { quality: 80 },
          webp: { quality: 80 },
          avif: { quality: 75 },
        },
        resize: {
          width: 1200,
          height: 1200,
          withoutEnlargement: true,
        },
      }),
    ],
    base: '/',
    css: {
      postcss: {
        plugins: [
          autoprefixer({}), // add options if needed
        ],
      },
    },
    resolve: {
      alias: [
        // webpack path resolve to vitejs
        {
          find: /^~(.*)$/,
          replacement: '$1',
        },
        {
          find: '@/',
          replacement: `${path.resolve(__dirname, 'src')}/`,
        },
        {
          find: '@',
          replacement: path.resolve(__dirname, '/src'),
        },
        {
          find: 'vue-i18n',
          replacement: path.resolve(__dirname, 'vendor/node_modules/vue-i18n'),
        },
        {
          find: '@intlify',
          replacement: path.resolve(__dirname, 'vendor/node_modules/@intlify'),
        },
      ],
      extensions: ['.mjs', '.js', '.ts', '.jsx', '.tsx', '.json', '.vue', '.scss'],
    },
    server: {
      host: true,
      port: 5173,
      allowedHosts: true,
      watch: {
        usePolling: true,
      },
      proxy: {
        '/api': 'http://app:8000',
        '/storage': 'http://app:8000',
      },
    },
  }
})
