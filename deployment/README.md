# Production Deployment with Docker

Each directory in this one is an example of how one might create a production deployment of Massive Decks using Docker.

  - [memory](memory) contains a deployment that creates a server that simply stores all the game data and caches in memory.
  - [postgres](postgres) contains a deployment that creates a server that uses a postgres database for storage and caching.

These use [Docker Compose](https://docs.docker.com/compose/), a tool that comes with Docker for running multi-container
applications.
