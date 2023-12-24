"Sqids Bazel Dependencies"

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def sqids_bazel_dependencies():
    "Runtime dependencies for sqids bazel"

    http_archive(
        name = "bazel_skylib",
        sha256 = "cd55a062e763b9349921f0f5db8c3933288dc8ba4f76dd9416aac68acee3cb94",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.5.0/bazel-skylib-1.5.0.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.5.0/bazel-skylib-1.5.0.tar.gz",
        ],
    )

    http_archive(
        name = "aspect_bazel_lib",
        sha256 = "c858cc637db5370f6fd752478d1153955b4b4cbec7ffe95eb4a47a48499a79c3",
        strip_prefix = "bazel-lib-2.0.3",
        url = "https://github.com/aspect-build/bazel-lib/releases/download/v2.0.3/bazel-lib-v2.0.3.tar.gz",
    )
