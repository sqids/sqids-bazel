#!/usr/bin/env bash

# This script is used in .github/workflows/release.yaml to create a
# Github Release.
#
# It basically outputs two files:
#
#   - An archive from git with all the files meant to be published
#   - A `release.md` file that is used to updated the release notes
#
# when executing the script, it needs to be given an argument naming the
# git reference that shall be used to create an archive from, e.g.:
#
# ./.github/workflows/release.sh "v0.0.0"

set -o errexit -o nounset -o pipefail

NAME=sqids-bazel
TAG=${1}
VERSION=${TAG:1}
PREFIX="${NAME}-${VERSION}"
ARCHIVE="${NAME}-${TAG}.tar.gz"

git archive --worktree-attributes --format=tar --prefix=${PREFIX}/ ${TAG} | gzip >$ARCHIVE
SHA=$(shasum -a 256 $ARCHIVE | awk '{print $1}')

cat > release.md <<EOF

## Use with Bzlmod

\`\`\`starlark
bazel_dep(name = "sqids_bazel", version = "${VERSION}")
\`\`\`

## Use with \`WORKSPACE\`

In you \`WORKSPACE\` file, paste:

\`\`\`starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "sqids_bazel",
    sha256 = "${SHA}",
    strip_prefix = "${PREFIX}",
    url = "https://github.com/sqids/sqids-bazel/releases/download/${TAG}/${ARCHIVE}",
)

load("@sqids_bazel//:deps.bzl", "sqids_bazel_dependencies")

sqids_bazel_dependencies()
\`\`\`

EOF
