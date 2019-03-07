const webpack = require("webpack");
const path = require("path");
const CopyPlugin = require("copy-webpack-plugin");

const ASSET_PATH = "http://192.168.86.70:8080/assets/";

module.exports = {
  output: {
    publicPath: ASSET_PATH,
    chunkFilename: "[name].bundle.js",
    filename: "main.js",
    path: path.resolve(__dirname, "../priv/static")
  },
  plugins: [
    new CopyPlugin([{ from: "static/", to: "../static" }]),
    new webpack.DefinePlugin({
      "process.env.ASSET_PATH": JSON.stringify(ASSET_PATH)
    })
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
              "@babel/preset-env",
              ["@babel/preset-stage-2", { decoratorsLegacy: true }]
            ]
          }
        }
      },
      {
        test: /\.css$/,
        use: ["style-loader", "postcss-loader"]
      },
      {
        test: /\.elm$/,
        exclude: /(node_modules|elm-stuff)/,
        use: [
          {
            loader: "string-replace-loader",
            options: {
              multiple: [
                {
                  search: "%ASSET_PATH%",
                  replace: ASSET_PATH
                }
              ]
            }
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
          debug: true
        }
      }
    ]
  },
  devServer: {
    inline: true,
    host: "0.0.0.0",
    stats: { colors: true },
    overlay: true,
    historyApiFallback: {
      disableDotRule: true
    }
  }
};
