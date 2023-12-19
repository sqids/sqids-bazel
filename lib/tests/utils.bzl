"Test utils"

load("//:defs.bzl", "sqids")
load("//lib:constants.bzl", "DEFAULT_ALPHABET", "DEFAULT_MIN_LENGTH")

def _hashed_file_impl(ctx):
    s = sqids(alphabet = ctx.attr.alphabet, min_length = ctx.attr.min_length)
    hash = s.encode(ctx.attr.numbers)
    out = ctx.actions.declare_file("%s-%s" % (ctx.attr.name, hash))

    ctx.actions.write(
        output = out,
        content = "%s" % hash,
    )

    return [DefaultInfo(files = depset([out]))]

hashed_file = rule(
    _hashed_file_impl,
    attrs = {
        "alphabet": attr.string(default = DEFAULT_ALPHABET),
        "min_length": attr.int(default = DEFAULT_MIN_LENGTH),
        "numbers": attr.int_list(mandatory = True),
    },
)
