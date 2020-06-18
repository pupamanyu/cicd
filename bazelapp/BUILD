
java_binary (
    name = "App1",
    srcs = glob(["src/main/java/com/example/*.java"]),
    main_class = "com.example.App1",
    deps = ["//bazelgreeting:greeter", "@maven//:org_apache_commons_commons_lang3"]
)

#To clean cache run
# bazel clean --expunge
