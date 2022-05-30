variable "VERSION" {
    default = ""
}

variable "VCS_REF" {
    default = "unknown"
}

variable "BUILD_DATE" {
    default = "unknown"
}

variable "MODE" {
    default = "production"
}
   
function "splitSemVer" {
    params = [version]
    result = regexall("^v?(?P<major>0|[1-9]\\d*)\\.(?P<minor>0|[1-9]\\d*)\\.(?P<patch>0|[1-9]\\d*)(?:-(?P<prerelease>(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+(?P<buildmetadata>[0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?$", version)
}
    
function "generateVersionTags" {
    params = [semVer]
    result = length(semVer) != 1 ? [] : concat(
        semVer[0]["prerelease"] != null ?
            ["${semVer[0]["major"]}.${semVer[0]["minor"]}.${semVer[0]["patch"]}-${semVer[0]["prerelease"]}"] :
            [
                "${semVer[0]["major"]}.${semVer[0]["minor"]}.${semVer[0]["patch"]}",
                "${semVer[0]["major"]}.${semVer[0]["minor"]}",
                "${semVer[0]["major"]}",
                "latest-release",
            ],
        ["latest-prerelease"]
    )
}

function "repos" {
    params = []
    result = [
        "ghcr.io/lattyware/massivedecks/",
        "massivedecks/"
    ]
}   
    
function "generateTags" {
    params = [component]
    result = flatten([
        for repo in repos(): [ for tag in flatten(["${VCS_REF}-dev", generateVersionTags(splitSemVer(VERSION)), "latest"]) : "${repo}${component}:${tag}" ]
    ])
}

target "build" {
    dockerfile = "./Dockerfile"
    platforms = ["linux/amd64", "linux/arm64"]
    output = ["type=docker"]
    pull = true
    args = {
        VERSION = VERSION != "" ? VERSION : "${VCS_REF}-dev"
        VCS_REF = VCS_REF
        BUILD_DATE = BUILD_DATE
        MODE = MODE
    }
}

target "server" {
    context = "./server"
    inherits = ["build"]
    tags = generateTags("server")
}

target "client" {
    context = "./client"
    inherits = ["build"]
    tags = generateTags("client")
}

group "default" {
    targets = [ "server", "client" ]
}
