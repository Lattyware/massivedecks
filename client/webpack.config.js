const webpack = require("webpack");
const { CleanWebpackPlugin } = require("clean-webpack-plugin");
const TerserPlugin = require("terser-webpack-plugin");
const path = require("path");
const CompressionPlugin = require("compression-webpack-plugin");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const sass = require("sass");
const ClosurePlugin = require("closure-webpack-plugin");

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
        name: "[name].[hash].css",
        outputPath: "assets/styles",
        esModule: false,
      },
    },
    {
      loader: "extract-loader",
    },
    // Load CSS to inline styles.
    {
      loader: "css-loader",
      options: { sourceMap: dev },
    },
    // Transform CSS for compatibility.
    {
      loader: "postcss-loader",
      options: {
        sourceMap: dev,
      },
    },
    // Allow relative URLs.
    {
      loader: "resolve-url-loader",
      options: { sourceMap: dev },
    },
    // Load SASS to CSS.
    {
      loader: "sass-loader",
      options: {
        implementation: sass,
        sourceMap: true,
        sassOptions: {
          includePaths: ["node_modules"],
        },
      },
    },
  ];

  const elmLoaders = [
    // Load elm to JS.
    {
      loader: "elm-webpack-loader",
      options: {
        files: [path.resolve(src, "elm/MassiveDecks.elm")],
        optimize: prod,
        debug: dev,
        forceWatch: dev,
        cwd: __dirname,
      },
    },
  ];

  const plugins = [
    new HtmlWebpackPlugin({
      template: "src/html/index.html",
      filename: "index.html",
      inject: "body",
      excludeChunks: ["cast"],
      test: /\.html$/,
    }),
    new HtmlWebpackPlugin({
      template: "src/html/cast.html",
      filename: "cast.html",
      inject: "body",
      excludeChunks: ["index"],
      test: /\.html$/,
    }),
  ];

  if (dev) {
    // Load CSS without refreshing in a dev env.
    cssLoaders.unshift({
      loader: "css-hot-loader",
      options: {
        reloadAll: true,
      },
    });
    // Load elm without refreshing in a dev env.
    // Disable if working with chromecasts.
    // noinspection JSCheckFunctionSignatures
    elmLoaders.unshift({ loader: "elm-hot-webpack-loader" });
    plugins.push(new webpack.HotModuleReplacementPlugin());
  }

  if (prod) {
    // If we are in production, ensure we don't have old files lying around.
    plugins.push(new CleanWebpackPlugin());
    plugins.push(
      new CompressionPlugin({
        test: /\.(js|css|html|webmanifest|svg)$/,
      }) //,
      // new CompressionPlugin({
      //   test: /\.(js|css|html|webmanifest|svg)$/,
      //   filename: "[path].br[query]",
      //   algorithm: "brotliCompress",
      //   compressionOptions: { level: 11 }
      // })
    );
    plugins.push(new webpack.HashedModuleIdsPlugin());
  }

  return {
    context: path.resolve(__dirname),
    entry: {
      // Main entry point.
      index: "./src/ts/index.ts",
      // Chromecast entry point.
      cast: "./src/ts/cast.ts",
    },
    // Source maps only in development.
    devtool: prod ? undefined : "eval-source-map",
    output: {
      path: dist,
      publicPath: "/",
      filename:
        mode === "production"
          ? "assets/scripts/[name].[chunkhash].js"
          : "assets/scripts/[name].[hash].js",
    },
    module: {
      rules: [
        // HTML
        {
          test: /\.html$/,
          exclude: [/elm-stuff/, /node_modules/],
          use: [
            {
              loader: "html-loader",
              options: {
                attributes: {
                  list: [
                    {
                      tag: "img",
                      attribute: "src",
                      type: "src",
                    },
                    {
                      tag: "link",
                      attribute: "href",
                      type: "src",
                    },
                  ],
                },
              },
            },
          ],
        },
        // Elm scripts.
        {
          test: /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/],
          use: elmLoaders,
        },
        // Typescript scripts.
        {
          test: /\.ts$/,
          exclude: [/elm-stuff/, /node_modules/],
          use: "ts-loader",
          include: src,
        },
        // Styles.
        {
          test: /\.s?css$/,
          exclude: [/elm-stuff/, /node_modules/],
          use: cssLoaders,
        },
        // Image assets.
        {
          test: /\.(jpg|png|svg)$/,
          loader: "file-loader",
          options: {
            name: "assets/images/[name].[hash].[ext]",
            esModule: false,
          },
        },
        // Font assets.
        {
          test: /\.(woff2)$/,
          loader: "file-loader",
          options: {
            name: "assets/fonts/[name].[hash].[ext]",
            publicPath: "/",
            esModule: false,
          },
        },
        // App manifest.
        {
          test: /\.webmanifest$/,
          exclude: [/elm-stuff/, /node_modules/, /dist/],
          use: [
            {
              loader: "file-loader",
              options: {
                name: "assets/[name].[hash].[ext]",
                publicPath: "/",
                esModule: false,
              },
            },
            {
              loader: "app-manifest-loader",
            },
          ],
        },
      ],
    },
    resolve: {
      extensions: [".js", ".ts", ".elm", ".scss"],
      modules: ["node_modules"],
    },
    plugins: plugins,
    optimization: {
      runtimeChunk: "single",
      splitChunks: {
        cacheGroups: {
          vendors: {
            test: /[\\/]node_modules[\\/]/,
            name: "vendors",
            chunks: "all",
          },
        },
      },
      minimizer: [
        new ClosurePlugin(
          {
            mode: "STANDARD",
            platform: "java",
            test: /assets\/scripts\/.*\.js$/,
          },
          {
            compilation_level: "SIMPLE_OPTIMIZATIONS",
            externs: "src/js/extern.js",
            languageOut: "ECMASCRIPT6_STRICT",
          }
        ),
        new TerserPlugin({
          test: /assets\/scripts\/.*\.js$/,
          sourceMap: dev,
          parallel: true,
          terserOptions: {
            output: {
              comments: false,
            },
          },
        }),
      ],
    },
    devServer: {
      hot: true,
      allowedHosts: ["localhost"],
      proxy: {
        // Forward to the server.
        "/api/**": {
          target: "http://localhost:8081",
          ws: true,
        },
        // As we are an SPA, this lets us route all requests to the index.
        "**": {
          target: "http://localhost:8080",
          pathRewrite: {
            cast: "cast.html",
            ".*": "",
          },
        },
      },
    },
  };
};
