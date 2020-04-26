const CopyPlugin = require("copy-webpack-plugin");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const HtmlWebpackPlugin = require("html-webpack-plugin");

module.exports = (env, { mode }) => ({
  entry: "./src/Web",
  output: { filename: "[name].[hash].js" },
  module: {
    rules: [
      { test: /\.js$/, exclude: /node_modules/, use: loader.babel(mode) },
      {
        test: /\.css$/,
        use: [MiniCssExtractPlugin.loader, "css-loader", loader.postcss(mode)],
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: loader.elm(mode),
      },
    ],
  },
  plugins: [
    new HtmlWebpackPlugin({ template: "src/Web/index.html" }),
    new MiniCssExtractPlugin({ filename: "[name].[contenthash].css" }),
    new CopyPlugin([{ from: "public" }]),
  ],
});

const loader = {
  babel(mode_) {
    return {
      loader: "babel-loader",
      options: { presets: ["@babel/preset-env"] },
    };
  },
  postcss(mode) {
    const prodPlugins = [
      require("@fullhuman/postcss-purgecss")({
        content: ["./src/**/*.js", "./src/**/*.elm", "./src/**/*.html"],
        defaultExtractor: (content) => content.match(/[A-Za-z0-9-_:/]+/g) || [],
      }),
      require("cssnano"),
    ];
    return {
      loader: "postcss-loader",
      options: {
        plugins: [
          require("tailwindcss"),
          require("postcss-preset-env"),
          ...(mode === "production" ? prodPlugins : []),
        ],
      },
    };
  },
  elm(mode) {
    return {
      loader: "elm-webpack-loader",
      options: {
        cwd: __dirname,
        runtimeOptions: "-A128m -H128m -n8m",
        debug: mode === "development",
        optimize: mode === "production",
      },
    };
  },
};
