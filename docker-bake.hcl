variable "VERSION" {
    default = ""
}

variable "VCS_REF" {
    default = "dev"
}
   
function "splitSemVer" {
    params = [version]
    result = regex("^(?P<major>0|[1-9]\\d*)\\.(?P<minor>0|[1-9]\\d*)\\.(?P<patch>0|[1-9]\\d*)(?:-(?P<prerelease>(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+(?P<buildmetadata>[0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?$", version)
}   
    
function "generateVersionTags" {
    params = [semVer]
    result = concat(
        ["latest-prerelease"], semVer.prerelease != null ? 
            [ "${semVer.major}.${semVer.minor}.${semVer.patch}-${semVer.prerelease}" ] : 
            [
                "latest-release",
                "${semVer.major}",
                "${semVer.major}.${semVer.minor}",
                "${semVer.major}.${semVer.minor}.${semVer.patch}",
            ]
    )
}

function "repos" {
    params = []
    result = [
        "ghcr.io/lattyware/massivedecks/",
        "registry.hub.docker.com/lattyware/massivedecks/"
    ]
}   
    
function "generateTags" {
    params = [repos, versionTags, commitHash, component]
    result = flatten([
        for repo in repos: [ for tag in flatten(["latest", versionTags, commitHash]) : "${repo}${component}:${tag}" ]
    ])
}

target "build" {
    dockerfile = "./Dockerfile"
    platforms = ["linux/amd64", "linux/arm64"]
    output = ["type=registry"]
    pull = true
}

target "server" {
    context = "./server"
    inherits = ["build"]
    tags = generateTags(repos(), VERSION == "" ? [] : generateVersionTags(splitSemVer(VERSION)), VCS_REF, "server")
}

target "client" {
    context = "./client"
    inherits = ["build"]
    tags = generateTags(repos(), VERSION == "" ? [] : generateVersionTags(splitSemVer(VERSION)), VCS_REF, "client")
}

group "default" {
    targets = [ "server", "client" ]
}
