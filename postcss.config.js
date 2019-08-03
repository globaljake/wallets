const purgecss = require("@fullhuman/postcss-purgecss")({
  content: [
    "./src/**/*.js",
    "./src/**/*.elm",
    "../lib/ship_web/templates/**/*.html.eex"
  ],
  defaultExtractor: content => content.match(/[A-Za-z0-9-_:/]+/g) || []
});

module.exports = {
  plugins: [
    require("tailwindcss"),
    require("postcss-preset-env"),
    ...(process.env.NODE_ENV === "production" ? [purgecss] : [])
  ]
};
