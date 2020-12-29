const webpack = require("webpack");
const { CleanWebpackPlugin } = require("clean-webpack-plugin");
const TerserPlugin = require("terser-webpack-plugin");
const path = require("path");
const CompressionPlugin = require("compression-webpack-plugin");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const sass = require("sass");
const ClosurePlugin = require("closure-webpack-plugin");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

module.exports = (env, argv) => {
  const mode =
    argv !== undefined && argv.mode !== undefined
      ? argv.mode
      : process.env["WEBPACK_MODE"] !== undefined
      ? process.env["WEBPACK_MODE"]
      : "production";

  const prod = mode === "production";

  const dist = path.resolve(__dirname, "dist");
  const src = path.resolve(__dirname, "src");

  const version = process.env["MD_VERSION"];
  const metadataFilename = `${src}/elm/MassiveDecks/Version.elm`;
  class InjectMetadataPlugin {
    apply(compiler) {
      if (version !== undefined) {
        const logger = compiler.getInfrastructureLogger("InjectMetadataPlugin");
        compiler.hooks.beforeRun.tap("InjectMetadataPlugin", () => {
          const original = this.before(logger);
          const hook = () => {
            this.after(logger, original);
          };
          compiler.hooks.done.tap("InjectMetadataPlugin", hook);
          compiler.hooks.failed.tap("InjectMetadataPlugin", hook);
        });
      }
    }

    before(logger) {
      logger.info("Metadata Injected");
      const original = fs.readFileSync(metadataFilename, "utf8");
      const updated = original
        .toString()
        .replace(/^(version\s*=\s*")(.*?)(")/m, `$1${version}$3`);
      fs.writeFileSync(metadataFilename, updated);
      return original;
    }

    after(logger, original) {
      logger.info("Metadata Reverted");
      fs.writeFileSync(metadataFilename, original);
    }
  }

  const cssLoaders = [
    // Load CSS to inline styles.
    {
      loader: "css-loader",
      options: { sourceMap: !prod },
    },
    // Transform CSS for compatibility.
    {
      loader: "postcss-loader",
      options: {
        sourceMap: !prod,
      },
    },
    // Allow relative URLs.
    {
      loader: "resolve-url-loader",
      options: { sourceMap: !prod },
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
    {
      loader: "elm-webpack-loader",
      options: {
        optimize: prod,
        debug: !prod,
      },
    },
  ];

  const plugins = [
    new InjectMetadataPlugin(),
    new CleanWebpackPlugin(),
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

  if (prod) {
    cssLoaders.unshift({
      loader: MiniCssExtractPlugin.loader,
    });
    plugins.push(
      new CompressionPlugin({
        test: /\.(js|css|html|webmanifest|svg)$/,
      }),
      new CompressionPlugin({
        test: /\.(js|css|html|webmanifest|svg)$/,
        filename: "[path].br[query]",
        algorithm: "brotliCompress",
        compressionOptions: { level: 11 }
      })
    );
    plugins.push(new webpack.HashedModuleIdsPlugin());
  } else {
    cssLoaders.unshift({ loader: "style-loader" });
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

  return {
    context: path.resolve(__dirname),
    entry: {
      // Main entry point.
      index: "./src/ts/index.ts",
      // Chromecast entry point.
      cast: "./src/ts/cast.ts",
    },
    output: {
      path: dist,
      publicPath: "/",
      filename: "assets/scripts/[name].[contenthash].js",
    },
    module: {
      rules: [
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
          parallel: true,
          terserOptions: {
            output: {
              comments: false,
            },
          },
        }),
      ],
    },
    devtool: !prod ? "eval-source-map" : undefined,
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
