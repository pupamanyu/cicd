# Copyright 2020 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

package(default_visibility = ["//visibility:public"])

load("@rules_pkg//:pkg.bzl", "pkg_deb", "pkg_tar")

pkg_tar(
    name = "game-event-dag",
    srcs = ["//etls/evaluation:lor/game_event"],
    extension = "tar.bz2",
)

pkg_deb(
    name = "game-event",
    architecture = "amd64",
    built_using = "unzip (6.0.1)",
    data = ":game-event-dag",
    depends = [
        "zlib1g-dev",
        "unzip",
        ":bash-completion",
    ],
    description = "Game Event End to End ETL",
    maintainer = "dev@riotgames.com",
    package = "game-event",
    version_file = ":version.txt",
)

genrule(
   name = "embeded_label",
   outs = ["version.txt"],
   cmd = """
        EXECPATH=$$(pwd)
        cd /workspace/cicd
        COMMIT="$$(git rev-parse HEAD)"
        BRANCH="$$(git rev-parse --abbrev-ref HEAD)"
        cd $${EXECPATH}
        VERSIONTXT="./version.txt"
        echo -e $${BRANCH}_$${COMMIT} > VERSIONTXT > $@
        """
)