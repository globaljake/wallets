const path = require("path");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const CopyPlugin = require("copy-webpack-plugin");
const HtmlWebpackPlugin = require("html-webpack-plugin");

module.exports = (env, options) => ({
  entry: {
    web: path.join(__dirname, "src/Web/index.js")
    // examples: path.join(__dirname, "src/Examples/index.js")
  },
  output: {
    publicPath: "/",
    chunkFilename: "[name].bundle.js",
    filename: "[name].[contenthash].js",
    path: path.resolve(__dirname, "./dist")
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: "babel-loader",
          options: {
            presets: ["@babel/preset-env"]
          }
        }
      },
      {
        test: /\.css$/,
        use: [MiniCssExtractPlugin.loader, "css-loader", "postcss-loader"]
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader: "elm-webpack-loader",
        options: {
          cwd: __dirname,
          runtimeOptions: "-A128m -H128m -n8m",
          debug: options.mode === "development",
          optimize: options.mode === "production"
        }
      }
    ]
  },
  plugins: [
    new HtmlWebpackPlugin({ template: "src/Web/index.html", chunks: ["web"] }),
    new MiniCssExtractPlugin({ filename: "[name].[contenthash].css" }),
    new CopyPlugin([{ from: "public/", to: "../dist" }])
  ]
});
