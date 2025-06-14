/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}',
  ],
  theme: {
    extend: {
      colors: {
        'industrial-blue': '#1E40AF',
        'industrial-gray': '#374151',
        'industrial-green': '#10B981',
        'industrial-red': '#EF4444',
        'industrial-yellow': '#F59E0B',
        'character-kyoko': '#8B5CF6',
        'character-byakuya': '#3B82F6',
        'character-chihiro': '#10B981',
        'character-celestia': '#EF4444',
        'character-sakura': '#F97316'
      },
      fontFamily: {
        'industrial': ['Inter', 'sans-serif'],
        'character': ['Fira Code', 'monospace']
      }
    },
  },
  plugins: [],
}
