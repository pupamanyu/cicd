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
    srcs = ["//etls/evaluation:game-1/game_event"],
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
    ],
    description = "Debian container package encapsulating airflow dags inside data tar ball for publishing to package registry",
    homepage = "http://bazel.build",
    maintainer = "The Authors <authors@customer.com>",
    package = "game-event",
    version = "1.0.0",
)

genrule(
   name = "version",
   cmd = "$(git rev-parse HEAD)",
   outs = ["version.txt"]
)



#genrule(
#    name = "game-event-jar",
#    srcs = ["//:build-utils/pack-jar.sh"],
#    tools = ["//:build-utils/pack-jar.sh"],
##    output_to_bindir = True,
##    outs = ["out.txt"],
#    outs = {
#            'jar': "%{name}.jar",
#               },
##    outs = glob(["*.jar"]),jar
#    cmd = "$(location //:build-utils/pack-jar.sh);echo $(location jar); [ -f '$(location jar)/*.jar' ] && echo 1 || echo 0 > $@"
#
##--ignore bazel-out --copy-files --output $(location jar)
##    && gsutil cp -r $(location jar) gs://pramodrao-dataengg-avroload > $@"
##    && gsutil -m cp $(location %s).runfiles %{name}.jar > $@"
#
##    cmd = "$(location //:build-utils/pack-jar.sh)"
#
#)

#genrule(
#   name = "copy",
#   cmd = "gsutil -m cp $(location %s).runfiles %{name}.jar>@",
#   outs = ["output.txt"],
#   deps = [":game-event-jar"]
#)

genrule(
    name = "create-jar",
    srcs = ["//:build-utils/pack-jar.sh"],
    tools = ["//:build-utils/pack-jar.sh"],
#    output_to_genfiles=True,
    output_to_bindir = True,
#    outs = ["out.txt"],
    outs = {
            'jar': "%{name}.jar",
               },
#    outs = glob(["*.jar"]),jar
    cmd = "$(location //:build-utils/pack-jar.sh) > $@"
)


#genrule(
#    name = "copy_jar",
#    srcs = [":create-jar"],
#    outs = ["msgs.hh"],
#    cmd = """
#    gsutil cp -r $(SRCS) gs://pramodrao-dataengg-avroload
#    """,
#    visibility = ["//visibility:public"],
#)

#genrule(
#    name = "copy_jar",
#    srcs = [":create-jar"],
#    outs = ["gs://pramodrao-dataengg-avroload"],
#    output_to_bindir = 1,
#    cmd = "cp $< $@",
#)