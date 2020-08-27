workspace(name = "data")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "bazel_skylib",
    sha256 = "97e70364e9249702246c0e9444bccdc4b847bed1eb03c5a3ece4f83dfe6abc44",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.0.2/bazel-skylib-1.0.2.tar.gz",
        "https://github.com/bazelbuild/bazel-skylib/releases/download/1.0.2/bazel-skylib-1.0.2.tar.gz",
    ],
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

http_archive(
    name = "build_stack_rules_proto",
    sha256 = "78e378237c6e7bd7cfdda155d4f7010b27723f26ebfa6345e79675bddbbebc11",
    strip_prefix = "rules_proto-56665373fe541d6f134d394624c8c64cd5652e8c",
    urls = ["https://github.com/stackb/rules_proto/archive/56665373fe541d6f134d394624c8c64cd5652e8c.tar.gz"],
)

load("@build_stack_rules_proto//python:deps.bzl", "python_proto_library")

python_proto_library()

load("@io_bazel_rules_python//python:pip.bzl", "pip_import", "pip_repositories")

pip_repositories()

pip_import(
    name = "protobuf_py_deps",
    requirements = "@build_stack_rules_proto//python/requirements:protobuf.txt",
)

load("@protobuf_py_deps//:requirements.bzl", protobuf_pip_install = "pip_install")

protobuf_pip_install()

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

git_repository(
    name = "rules_python",
    # Highest commit on master branch on 2020-02-06
    commit = "17dba4b7006199a289532afd99b7efa3d7b5fb29",
    remote = "https://github.com/bazelbuild/rules_python",
    shallow_since = "1583226079 +0100",
)

load("@rules_python//python:repositories.bzl", "py_repositories")

py_repositories()

# Importing pip dependencies https://github.com/bazelbuild/rules_python#using-the-packaging-rules
load("@rules_python//python:pip.bzl", "pip3_import", "pip_repositories")

pip_repositories()

#pip3_import(
#    name = "my_deps",
#    requirements = "//third_party/python:requirements.txt",
#)
#
#load("@my_deps//:requirements.bzl", "pip_install")

#pip_install()

git_repository(
    name = "subpar",
    remote = "https://github.com/google/subpar",
    tag = "2.0.0",
)

http_archive(
    name = "io_bazel_rules_go",
    sha256 = "f04d2373bcaf8aa09bccb08a98a57e721306c8f6043a2a0ee610fd6853dcde3d",
    urls = [
        "https://storage.googleapis.com/bazel-mirror/github.com/bazelbuild/rules_go/releases/download/0.18.6/rules_go-0.18.6.tar.gz",
        "https://github.com/bazelbuild/rules_go/releases/download/0.18.6/rules_go-0.18.6.tar.gz",
    ],
)

load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

go_register_toolchains()

git_repository(
    name = "io_bazel_rules_wheel",
    remote = "https://github.com/georgeliaw/rules_wheel",
    tag = "v0.2.0",
)

RULES_JVM_EXTERNAL_TAG = "3.1"

RULES_JVM_EXTERNAL_SHA = "e246373de2353f3d34d35814947aa8b7d0dd1a58c2f7a6c41cfeaff3007c2d14"

http_archive(
    name = "rules_jvm_external",
    sha256 = RULES_JVM_EXTERNAL_SHA,
    strip_prefix = "rules_jvm_external-%s" % RULES_JVM_EXTERNAL_TAG,
    url = "https://github.com/bazelbuild/rules_jvm_external/archive/%s.zip" % RULES_JVM_EXTERNAL_TAG,
)

#load("@rules_jvm_external//:defs.bzl", "maven_install")
#load("//third_party/java:library_deps.bzl", "DATA_MAVEN_ARTIFACTS")
#
#maven_install(
#    artifacts = DATA_MAVEN_ARTIFACTS,
#    maven_install_json = "@data//third_party/java:maven_install.json",
#    repositories = [
#        "https://build-artifacts.riotgames.com:8443/nexus/content/groups/riot",
#        "https://repo1.maven.org/maven2",
#    ],
#    strict_visibility = True,
#)
#
#load("@maven//:defs.bzl", "pinned_maven_install")
#
#pinned_maven_install()

git_repository(
    name = "subpar",
    remote = "https://github.com/google/subpar",
    tag = "2.0.0",
)

http_archive(
    name = "rules_pkg",
    sha256 = "352c090cc3d3f9a6b4e676cf42a6047c16824959b438895a76c2989c6d7c246a",
    url = "https://github.com/bazelbuild/rules_pkg/releases/download/0.2.5/rules_pkg-0.2.5.tar.gz",
)

load("@rules_pkg//:deps.bzl", "rules_pkg_dependencies")

rules_pkg_dependencies()
