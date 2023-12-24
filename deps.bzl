"Sqids Bazel Dependencies"

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def sqids_bazel_dependencies():
    "Runtime dependencies for sqids bazel"

    http_archive(
        name = "aspect_bazel_lib",
        sha256 = "c858cc637db5370f6fd752478d1153955b4b4cbec7ffe95eb4a47a48499a79c3",
        strip_prefix = "bazel-lib-2.0.3",
        url = "https://github.com/aspect-build/bazel-lib/releases/download/v2.0.3/bazel-lib-v2.0.3.tar.gz",
    )
