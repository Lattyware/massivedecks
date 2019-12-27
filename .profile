# For Heroku.
# Set the game version from the commit hash.
# You need Dyno Metadata (https://devcenter.heroku.com/articles/dyno-metadata) enabled for this to work.
export MD_VERSION="${HEROKU_SLUG_COMMIT}-dev"
