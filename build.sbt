name := "massivedecks"

version := "dev"

lazy val root = (project in file(".")).enablePlugins(PlayScala)

scalaVersion := "2.11.8"

resolvers += "scalaz-bintray" at "http://dl.bintray.com/scalaz/releases"
resolvers += "dl-john-ky" at "http://dl.john-ky.io/maven/releases"

libraryDependencies ++= Seq(
  cache,
  ws,

  "io.john-ky" %% "hashids-scala" % "1.1.1-7d841a8",

  specs2 % Test
)

includeFilter in (Assets, LessKeys.less) := "massivedecks.less" | "error.less"

routesGenerator := InjectedRoutesGenerator
