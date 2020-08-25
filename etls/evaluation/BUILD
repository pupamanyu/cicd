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
        ":bash-completion",
    ],
    description = "test",
    homepage = "http://bazel.build",
    maintainer = "authors@customer.com",
    package = "game-event",
    version_file = ":version.txt",
#    version = my_name
)

genrule(
   name = "embeded_label",
   outs = ["version.txt"],
   cmd = """
   EXECPATH=$$(pwd)

        cd /workspace/cicd
         IMPLVERSION="$$(git rev-parse HEAD)"
         cd $${EXECPATH}

         VERSIONTXT="./version.txt"
         echo -e $${IMPLVERSION} > VERSIONTXT > $@
        """

)

#cd /Users/ext.gampapathini/Documents/cicd

genrule(
    name = "game-event-jar",
    srcs = ["//:build-utils/pack-jar.sh"],
    tools = ["//:build-utils/pack-jar.sh"],
#    output_to_bindir = True,
#    outs = ["out.txt"],
    outs = {
            'jar': "%{name}.jar",
               },
#    outs = glob(["*.jar"]),jar
    cmd = "$(location //:build-utils/pack-jar.sh) > $@"

#--ignore bazel-out --copy-files --output $(location jar)
#    && gsutil cp -r $(location jar) gs://pramodrao-dataengg-avroload > $@"
#    && gsutil -m cp $(location %s).runfiles %{name}.jar > $@"

#    cmd = "$(location //:build-utils/pack-jar.sh)"

)

#genrule(
#   name = "copy",
#   cmd = "gsutil -m cp $(location %s).runfiles %{name}.jar>@",
#   outs = ["output.txt"],
#   deps = [":game-event-jar"]
#)

genrule(
    name = "create-manifest",
    srcs = [],
#    tools = ["//:build-utils/manifest.sh"],
#    output_to_genfiles=True,
    output_to_bindir = True,
#    outs = { : "%{name}.jar",},
#    outs = {
#            'jar': "%{name}.jar",
#               },
    outs = ["MANIFEST.txt"],
#    cmd = "$(location //:build-utils/pack-test-jar.sh) > $@"
#    cmd = "$(location //:build-utils/manifest.sh) > $@"
    cmd = 'echo -e "Name: "etls/evaluation/game-1" \nSpecification-Title: "Game Event End to End ETL"\nSpecification-Version: "test"\nSpecification-Vendor: "Example Company, Inc."\nImplementation-Title: "etls.evaluation"\nImplementation-Version: "test"\nImplementation-Vendor: "Example Company, Inc."\n"> $@'

)

genrule(
    name = "create-jar",
#    srcs = [":create-manifest"],
#    tools = ["//:build-utils/pack-test-jar.sh"],
#    output_to_genfiles=True,
    output_to_bindir = True,
#    outs = { : "%{name}.jar",},
#    outs = {
#            'jar': "%{name}.jar",
#               },
    outs = ["game-event.jar"],
#    cmd = "$(location //:build-utils/pack-test-jar.sh) > $@"
    cmd = """
            EXECPATH=$$(pwd)
            cd /workspace/cicd/
            IMPLVERSION="$$(git rev-parse HEAD)"
            SPECVERSION="$$(git rev-parse --abbrev-ref HEAD)"
            JARNAME="game-event_$${SPECVERSION}_$${SPECVERSION}"
            cd $${EXECPATH}


            NAME="etls/evaluation/game-1"
            SPECTITLE="Game Event End to End ETL"
            SPECVENDOR="Example Company, Inc."
            IMPLTITLE="etls.evaluation"

            IMPLVENDOR="Example Company, Inc."

            MANIFESTTXT="./manifest.txt"
            gen_manifest() {
              echo -e "Name: $${NAME} \nSpecification-Title: $${SPECTITLE}\nSpecification-Version: $${SPECVERSION}\nSpecification-Vendor: $${SPECVENDOR}\nImplementation-Title: $${IMPLTITLE}\nImplementation-Version: $${IMPLVERSION}\nImplementation-Vendor: $${IMPLVENDOR}\n"
              }
            gen_manifest > $${MANIFESTTXT}
            jar cmf $${MANIFESTTXT} $${JARNAME} -C /workspace/cicd/etls/evaluation/game-1 game_event
            cp $${JARNAME} $@
            """

)

#echo -e "Name: "etls/evaluation/game-1" \nSpecification-Title: "Game Event End to End ETL"\nSpecification-Version: "test"\nSpecification-Vendor: "Example Company, Inc."\nImplementation-Title: "etls.evaluation"\nImplementation-Version: "test"\nImplementation-Vendor: "Example Company, Inc."\n"

#cmd = """
#            echo "path is ... $$(pwd)"
#
#            pushd cd /workspace
#            IMPLVERSION="$$(git rev-parse HEAD)"
#            SPECVERSION="$$(git rev-parse --abbrev-ref HEAD)"
#            popd
#            NAME="etls/evaluation/game-1"
#            SPECTITLE="Game Event End to End ETL"
#            SPECVENDOR="Example Company, Inc."
#            IMPLTITLE="etls.evaluation"
#
#            IMPLVENDOR="Example Company, Inc."
#
#            MANIFESTTXT="./manifest.txt"
#            gen_manifest() {
#              echo -e "Name: $${NAME} \nSpecification-Title: $${SPECTITLE}\nSpecification-Version: $${SPECVERSION}\nSpecification-Vendor: $${SPECVENDOR}\nImplementation-Title: $${IMPLTITLE}\nImplementation-Version: $${IMPLVERSION}\nImplementation-Vendor: $${IMPLVENDOR}\n"
#            }
#            gen_manifest > $${MANIFESTTXT}
#            jar cmf $${MANIFESTTXT} game-event.jar -C /Users/ext.gampapathini/Documents/cicd/etls/evaluation/game-1 game_event
#            cp game-event.jar $@
#            """


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

#genrule(
#    name = "create-jar",
#    srcs = [],
#    outs = ["test.jar"],
#    cmd = "./$(location //:build-utils/pack-test-jar.sh) > \"$@\"",
#    tools = ["//:build-utils/pack-test-jar.sh"],
#)