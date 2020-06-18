
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_jar")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

RULES_JVM_EXTERNAL_TAG = "3.0"
RULES_JVM_EXTERNAL_SHA = "62133c125bf4109dfd9d2af64830208356ce4ef8b165a6ef15bbff7460b35c3a"

http_archive(
    name = "rules_jvm_external",
    strip_prefix = "rules_jvm_external-%s" % RULES_JVM_EXTERNAL_TAG,
    sha256 = RULES_JVM_EXTERNAL_SHA,
    url = "https://github.com/bazelbuild/rules_jvm_external/archive/%s.zip" % RULES_JVM_EXTERNAL_TAG,
)

load("@rules_jvm_external//:defs.bzl", "maven_install")

#maven_install(
#    artifacts = [
#        "org.apache.commons:commons-lang3:3.9"
#    ],
#    repositories = [
#        "https://repo1.maven.org/maven2",
#    ]
#)

maven_install(
    artifacts = [
        "org.apache.beam:beam-sdks-java-io-google-cloud-platform:2.19.0",
        "org.apache.beam:beam-sdks-java-core:2.19.0",
        "org.apache.beam:beam-runners-direct-java:2.19.0",
        "org.hamcrest:hamcrest-core:1.3",
        "org.hamcrest:hamcrest-library:1.3",
        "org.slf4j:slf4j-api:1.7.25",
        "org.slf4j:slf4j-jdk14:1.7.25",
        "junit:junit:4.12",
    ],
    repositories = [
        "https://repo1.maven.org/maven2/",
        "https://maven.google.com",
    ],
    maven_install_json = "//:maven_install.json",
)

http_jar (
    name = "apache-commons-lang",
    url = "https://repo1.maven.org/maven2/org/apache/commons/commons-lang3/3.9/commons-lang3-3.9.jar"
)

load("@maven//:defs.bzl", "pinned_maven_install")
pinned_maven_install()

