/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{svelte,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        olive: '#83781B',
        olivine: '#A8C686',
        asparagus: '#709255',
        darkAsparagus: '#7B9C56',
        darkMossGreen: '#3E5622',
        darkGreen: '#172815',
      },
    },
  },
  plugins: [],
}
