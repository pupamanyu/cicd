package(default_visibility = ["//visibility:public"])

load("@rules_pkg//:pkg.bzl", "pkg_tar", "pkg_deb")
load(":version.bzl", "git_hash_cpp")
py_binary(
    name = "gen_cpp",
    srcs = ["gen_cpp.py"]
)

genrule(
    name = "gen_local_go",
    srcs = ["//etls/evaluation:lor/game_event"],
    outs = ["local.go"],
    cmd = 'git rev-parse HEAD'
)

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

genrule(
    name = "stamper",
    outs = ["stamper.out"],
    srcs = [
        "Users/ext.gampapathini/Documents/cicd/.git/HEAD",
        "Users/ext.gampapathini/Documents/cicd/.git/refs/heads/master",
    ],
    cmd = """
if [[ $$(cat $(location :.git/HEAD)) = "refs: refs/heads/<release branch>" ]]; then
  cat $(location :.git/refs/heads/master)
else
  # If we're not on the release branch, don't uncache things on commit.
  echo "dev"
fi
""",
)



git_hash_cpp(
    name = "foo",
    commit_variable_name = "GIT_COMMIT_HASH",
    dirty_variable_name = "GIT_DIRTY",
    header = "a/c/b.h",
    cpp = "a/c/b.cpp"
)
