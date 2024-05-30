import {defineConfig} from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

const dirName = path.resolve();

// https://vitejs.dev/config/
export default defineConfig({
    plugins: [react()],
    resolve: {
        alias: [
            { find: "@", replacement: path.resolve(dirName, './src') },
            { find: "@common", replacement: path.resolve(dirName, '../../common/src') },
        ],
    },
    build: {
        assetsInlineLimit: 0,
    },
    publicDir: '../public',
    server: {
        proxy: {
            '/api': {
                target: 'http://localhost:1000',
                changeOrigin: true,
                secure: false,
                ws: true
            }
        }
    }
})

