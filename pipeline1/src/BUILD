package(default_visibility = ["//visibility:public"])
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")

py_library(
name = 'main',
srcs = ['main.py'],
)

pkg_tar(
    name = "pipeline1",
    extension = "tar.gz",
    srcs = [    "main.py",
                "requirements.txt",
                "//:dependencies/billingoutput.py",
                "//:dependecies/commitments_intervals.py",
                "//:dependecies/commitments_schema.py",
                "//:dependecies/distribute_commitment.py",
                "//:dependecies/helper_function.py",
                "//:dependecies/project_label_credit_data.py"],
)
