import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  base: '/login/',
  plugins: [react()],
  build: {
    outDir: 'dist',
    emptyOutDir: true,
  }
})
