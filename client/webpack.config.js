const webpack = require("webpack");
const { CleanWebpackPlugin } = require("clean-webpack-plugin");
const TerserPlugin = require("terser-webpack-plugin");
const UglifyJsPlugin = require("uglifyjs-webpack-plugin");
const path = require("path");
const inliner = require("sass-inline-svg");

module.exports = (env, argv) => {
  // WebStorm doesn't give any arguments, causing this to blow up without the check.
  const mode = typeof argv === "undefined" ? "production" : argv.mode;

  const prod = mode === "production";
  const dev = mode === "development";

  const dist = path.resolve(__dirname, "dist");
  const src = path.resolve(__dirname, "src");

  const cssLoaders = [
    // Extract to separate file.
    {
      loader: "file-loader",
      options: {
        name: "[name].css",
        outputPath: "assets/styles"
      }
    },
    {
      loader: "extract-loader"
    },
    // Load CSS to inline styles.
    {
      loader: "css-loader",
      options: { sourceMap: dev, importLoaders: 2 }
    },
    // Transform CSS for compatibility.
    {
      loader: "postcss-loader",
      options: {
        sourceMap: dev,
        ident: "postcss",
        plugins: loader => [
          require("postcss-import")({ root: loader.resourcePath }),
          require("postcss-preset-env")(),
          require("cssnano")()
        ]
      }
    },
    // Load SASS to CSS.
    {
      loader: "sass-loader",
      options: {
        sourceMap: dev,
        includePaths: ["node_modules"],
        functions: {
          "inline-svg": inliner("./", { encodingFormat: "uri" })
        }
      }
    }
  ];

  const elmLoaders = [
    // Load elm to JS.
    {
      loader: "elm-webpack-loader",
      options: {
        files: [
          path.resolve(src, "elm/MassiveDecks.elm"),
          path.resolve(src, "elm/MassiveDecks/Cast.elm")
        ],
        optimize: prod,
        debug: dev,
        forceWatch: dev,
        cwd: __dirname
      }
    }
  ];

  const plugins = [];

  if (dev) {
    // Load CSS without refreshing in a dev env.
    cssLoaders.unshift({
      loader: "css-hot-loader",
      options: {
        reloadAll: true
      }
    });
    // Load elm without refreshing in a dev env.
    // Disable if working with chromecasts.
    elmLoaders.unshift({ loader: "elm-hot-webpack-loader" });
    plugins.push(new webpack.HotModuleReplacementPlugin());
  }

  if (prod) {
    // If we are in production, ensure we don't have old files lying around.
    plugins.push(new CleanWebpackPlugin());
  }

  return {
    context: path.resolve(__dirname),
    entry: {
      // Main entry point.
      index: "./src/ts/index.ts",
      // Chromecast entry point.
      cast: "./src/ts/cast.ts"
    },
    // Source maps only in development.
    devtool: prod ? "none" : "inline-source-map",
    output: {
      path: dist,
      publicPath: "/",
      filename: "assets/scripts/[name].js"
    },
    module: {
      rules: [
        // HTML
        {
          test: /\.html$/,
          exclude: [/elm-stuff/, /node_modules/],
          use: [
            {
              loader: "file-loader",
              options: {
                name: "[name].[ext]"
              }
            },
            {
              loader: "extract-loader"
            },
            {
              loader: "html-loader",
              options: { attrs: ["img:src", "link:href"] }
            }
          ]
        },
        // Elm scripts.
        {
          test: /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/],
          use: elmLoaders
        },
        // Typescript scripts.
        {
          test: /\.ts$/,
          exclude: [/elm-stuff/, /node_modules/],
          use: "ts-loader",
          include: src
        },
        // Styles.
        {
          test: /\.s?css$/,
          exclude: [/elm-stuff/, /node_modules/],
          use: cssLoaders
        },
        // Image assets.
        {
          test: /\.(jpg|png|svg)$/,
          loader: "file-loader",
          options: {
            name: "assets/images/[name].[ext]"
          }
        },
        // Font assets.
        {
          test: /\.(woff2)$/,
          loader: "file-loader",
          options: {
            name: "assets/fonts/[name].[ext]",
            publicPath: "/"
          }
        },
        // App manifest.
        {
          test: /\.webmanifest$/,
          use: [
            {
              loader: "file-loader",
              options: {
                name: "[name].[ext]",
                publicPath: "/"
              }
            },
            {
              loader: "app-manifest-loader"
            }
          ]
        }
      ]
    },
    resolve: {
      extensions: [".js", ".ts", ".elm", ".scss"],
      modules: ["node_modules"]
    },
    plugins: plugins,
    optimization: {
      minimizer: [
        // Typescript
        new TerserPlugin({
          test: /assets\/scripts\/(index|cast)\.js$/,
          sourceMap: dev,
          parallel: true,
          terserOptions: {
            output: {
              comments: false
            }
          }
        }),
        // Elm - we can do otherwise dangerous optimisation thanks to the purity.
        new UglifyJsPlugin({
          test: /assets\/scripts\/massive-decks\.js$/,
          uglifyOptions: {
            compress: {
              pure_funcs: [
                "F2",
                "F3",
                "F4",
                "F5",
                "F6",
                "F7",
                "F8",
                "F9",
                "A2",
                "A3",
                "A4",
                "A5",
                "A6",
                "A7",
                "A8",
                "A9"
              ],
              pure_getters: true,
              keep_fargs: false,
              unsafe_comps: true,
              unsafe: true,
              passes: 3
            },
            mangle: true
          }
        })
      ]
    },
    devServer: {
      hot: true,
      proxy: {
        // Forward to the server.
        "/api/**": {
          target: "http://localhost:8081",
          ws: true
        },
        // As we are an SPA, this lets us route all requests to the index.
        "**": {
          target: "http://localhost:8080",
          pathRewrite: {
            "cast.html": "cast.html",
            ".*": ""
          }
        }
      }
    }
  };
};
