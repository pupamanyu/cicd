package(default_visibility = ["//visibility:public"])
java_binary (
    name = "WordCount",
    srcs = glob(["data-processing-code/src/main/java/org/apache/beam/examples/*.java"]),
    main_class = "org.apache.beam.examples.WordCount",
    deps = ["//pipeline1:pipeline1"]
)
