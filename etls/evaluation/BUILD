package(default_visibility = ["//visibility:public"])

pkg_tar(
    name = "package",
    extension = "tar.bz2",
    srcs = ["//etls/evaluation:lor/game_event"]
)

pkg_deb(
    name = "lor-game-event",
    architecture = "amd64",
    built_using = "unzip (6.0.1)",
    data = ":package",
    depends = [
        "zlib1g-dev",
        "unzip",
    ],
    description = "Debian package for lor-game-event",
    homepage = "http://bazel.build",
    maintainer = "The Bazel Authors <bazel-dev@googlegroups.com>",
    package = "bazel",
    version = "3.3.1",
)
#
#genrule(
#    name = "stamper",
#    outs = ["stamper.out"],
#    srcs = [
#        "Users/ext.gampapathini/Documents/cicd/.git/HEAD",
#        "Users/ext.gampapathini/Documents/cicd/.git/refs/heads/master",
#    ],
#    cmd = """
#if [[ $$(cat $(location :.git/HEAD)) = "refs: refs/heads/<release branch>" ]]; then
#  cat $(location :.git/refs/heads/master)
#else
#  # If we're not on the release branch, don't uncache things on commit.
#  echo "dev"
#fi
#""",
#)
