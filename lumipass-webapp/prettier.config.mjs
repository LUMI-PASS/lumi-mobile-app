/** @type {import("prettier").Config} */
const config = {
  // printWith: 120,
  singleQuote: true,
  semi:true,
  trailingComma: 'es5',
  tabWidth: 2,
  useTabs: true,
  plugins: ['prettier-plugin-tailwindcss'],
};
export default config;
