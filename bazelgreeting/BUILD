
java_library (
    name = "greeter",
    srcs = glob(["src/main/java/com/example/*.java"]),
    visibility = ["//bazelapp:__pkg__"]
)

java_binary (
    name = "Greeting",
    srcs = glob(["src/main/java/com/example/*.java"]),
    main_class = "com.example.Greetings"
#    deps = ["//bazelgreeting:greeter", "@maven//:org_apache_commons_commons_lang3"]
)
