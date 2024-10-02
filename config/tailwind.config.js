const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}',
    './node_modules/flowbite/**/*.js'
  ],
  safelist: [
    {
      pattern: /grid-cols-\d+/,
      variants: ['sm', 'md', 'lg', 'xl'],
    },
    {
      pattern: /col-span-\d+/,
      variants: ['sm', 'md', 'lg', 'xl'],
    },
  ],
  theme: {
    extend: {
      fontFamily: {
        serif: ["Playfair Display", ...defaultTheme.fontFamily.serif],
        rock: ["New Rocker", 'system-ui'],
        special:["Fredericka the Great", 'sans-serif']
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
    require('flowbite/plugin')
  ]
}
