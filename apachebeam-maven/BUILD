java_binary(
    name = "word-count",
    srcs = glob(["src/main/**/*.java"]),
    main_class = "org.apache.beam.examples.MinimalWordCount",
    deps = [
        "@maven//:org_apache_beam_beam_sdks_java_core",
        "@maven//:org_apache_beam_beam_runners_direct_java",
        "@maven//:org_apache_beam_beam_sdks_java_io_google_cloud_platform",
        "@maven//:org_slf4j_slf4j_api",
        "@maven//:org_slf4j_slf4j_jdk14",
        "@maven//:org_hamcrest_hamcrest_core",
        "@maven//:org_hamcrest_hamcrest_library",
        "@maven//:junit_junit",
    ],
)

#>bazel build //:word-count_deploy.jar
