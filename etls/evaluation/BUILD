package(default_visibility = ["//visibility:public"])

load("@rules_pkg//:pkg.bzl", "pkg_deb", "pkg_tar")

pkg_tar(
    name = "package",
    srcs = ["//etls/evaluation:game-1/game_event"],
    extension = "tar.bz2",
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
    description = "Debian container package encapsulating airflow dags inside data tar ball for publishing to package registry",
    homepage = "http://bazel.build",
    maintainer = "The Authors <authors@customer.com>",
    package = "game-event",
    version = "1.0.0",
)
