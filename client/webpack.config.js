const TerserPlugin = require("terser-webpack-plugin");
const path = require("path");
const CompressionPlugin = require("compression-webpack-plugin");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const sass = require("sass");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const fs = require("fs");

module.exports = (env, argv) => {
  const mode =
    argv?.mode !== undefined
      ? argv.mode
      : process.env["WEBPACK_MODE"] !== undefined
      ? process.env["WEBPACK_MODE"]
      : "production";

  const production = mode === "production";

  const inDocker = process.env["MD_DEV_ENV"] === "docker";

  const dist = path.resolve(__dirname, "dist");
  const src = path.resolve(__dirname, "src");
  const assets = path.resolve(__dirname, "assets");

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

  return {
    mode,
    context: path.resolve(__dirname),
    entry: {
      // Main entry point.
      index: path.join(src, "ts", "index.ts"),
      // Chromecast entry point.
      cast: path.join(src, "ts", "cast.ts"),
    },
    output: {
      path: dist,
      publicPath: "/",
      filename: "assets/scripts/[name].[contenthash].js",
      clean: true,
    },
    module: {
      rules: [
        // Elm scripts.
        {
          test: /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/],
          use: [
            {
              loader: "elm-webpack-loader",
              options: {
                optimize: production,
                debug: !production,
              },
            },
          ],
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
          use: [
            production
              ? {
                  loader: MiniCssExtractPlugin.loader,
                }
              : { loader: "style-loader" },
            // Load CSS to inline styles.
            {
              loader: "css-loader",
              options: { sourceMap: !production },
            },
            // Transform CSS for compatibility.
            {
              loader: "postcss-loader",
              options: {
                sourceMap: !production,
              },
            },
            // Allow relative URLs.
            {
              loader: "resolve-url-loader",
              options: { sourceMap: !production },
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
          ],
        },
        // Image assets.
        {
          test: /\.(jpg|png|svg)$/,
          type: "asset/resource",
          generator: {
            filename: "assets/images/[name].[hash][ext]",
          },
        },
        // Font assets.
        {
          test: /\.(woff2)$/,
          type: "asset/resource",
          generator: {
            filename: "assets/fonts/[name].[hash][ext]",
          },
        },
        // App manifest.
        {
          test: /\.webmanifest$/,
          exclude: [/elm-stuff/, /node_modules/, /dist/],
          type: "asset/resource",
          generator: {
            filename: "assets/[name].[hash][ext]",
          },
          use: [
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
    plugins: [
      new InjectMetadataPlugin(),
      new MiniCssExtractPlugin({
        filename: "assets/styles/[name].[contenthash].css",
      }),
      new HtmlWebpackPlugin({
        template: path.join(src, "html", "index.html"),
        filename: "index.html",
        inject: "body",
        excludeChunks: ["cast"],
      }),
      new HtmlWebpackPlugin({
        template: path.join(src, "html", "cast.html"),
        filename: "cast.html",
        inject: "body",
        excludeChunks: ["index"],
      }),
      ...(production
        ? [
            new CompressionPlugin({
              test: /\.(js|css|html|webmanifest|svg)$/,
            }),
          ]
        : []),
    ],
    optimization: {
      minimizer: [
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
    devtool: !production ? "eval-source-map" : undefined,
    devServer: {
      static: [{ directory: dist }],
      hot: true,
      host: inDocker ? "0.0.0.0" : "localhost",
      allowedHosts: ["localhost"],
      proxy: {
        // Forward to the server.
        "/api/**": {
          target: inDocker ? "http://server:8081" : "http://localhost:8081",
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
