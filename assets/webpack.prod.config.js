const webpack = require("webpack");
const path = require("path");
const glob = require("glob");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const PurgecssPlugin = require("purgecss-webpack-plugin");
const OptimizeCSSAssetsPlugin = require("optimize-css-assets-webpack-plugin");
const TerserPlugin = require("terser-webpack-plugin");
const CopyPlugin = require("copy-webpack-plugin");

module.exports = {
  output: {
    publicPath: "/assets/",
    chunkFilename: "[name].bundle.[hash:8].js",
    filename: "main.[hash:8].js",
    path: path.resolve(__dirname, "../priv/static/")
  },
  optimization: {
    minimizer: [
      new TerserPlugin({
        cache: true,
        parallel: true
      }),
      new OptimizeCSSAssetsPlugin({})
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({ filename: "main.[hash:8].css" }),
    new PurgecssPlugin({
      whitelist: ["body", "html"],
      paths: glob.sync("src/**/*", { nodir: true }),
      extractors: [
        {
          extractor: {
            extract: c => c.match(/[A-z0-9-:\/]+/g) || []
          },
          extensions: ["elm", "js"]
        }
      ]
    }),
    new CopyPlugin([{ from: "static/", to: "../static" }])
  ],
  module: {
    rules: [
      {
        test: /\.svg$/,
        use: {
          loader: "svg-inline-loader"
        }
      },
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: "babel-loader",
          options: {
            presets: [
              ["@babel/preset-env", { targets: { uglify: true } }],
              ["@babel/preset-stage-2", { decoratorsLegacy: true }]
            ]
          }
        }
      },
      {
        test: /\.css$/,
        use: [
          {
            loader: MiniCssExtractPlugin.loader
          },
          {
            loader: "css-loader",
            options: {
              importLoaders: 1,
              minimize: { discardComments: { removeAll: true } }
            }
          },
          {
            loader: "postcss-loader"
          }
        ]
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader: "elm-webpack-loader",
        options: {
          cwd: __dirname,
          runtimeOptions: "-A128m -H128m -n8m",
          optimize: true
        }
      }
    ]
  }
};
