package(default_visibility = ["//visibility:public"])
load("@rules_pkg//:pkg.bzl", "pkg_tar", "pkg_deb")
pkg_tar(
    name = "package",
    extension = "tar.bz2",
    srcs = ["//etls/evaluation:game-1/game_event"]
)

pkg_deb(
    name = "game-event",
    architecture = "amd64",
    built_using = "unzip (6.0.1)",
    data = ":package",
    depends = [
        "zlib1g-dev",
        "unzip",
    ],
    description = "Debian package for game-event",
    homepage = "http://bazel.build",
    maintainer = "The Bazel Authors <bazel-dev@googlegroups.com>",
    package = "bazel",
    version = "3.3.1",
)
