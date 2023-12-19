"Alphabet Tests"

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts", "unittest")
load("//:defs.bzl", "decode", "encode", "sqids")
load("//lib/tests:utils.bzl", "hashed_file")

def _simple_test_impl(ctx):
    env = unittest.begin(ctx)

    alphabet = "0123456789abcdef"
    s = sqids(alphabet = alphabet)

    numbers = [1, 2, 3]
    id = "489158"

    asserts.equals(env, s.encode(numbers), id)
    asserts.equals(env, encode(numbers, alphabet), id)
    asserts.equals(env, s.decode(id), numbers)
    asserts.equals(env, decode(id, alphabet), numbers)

    return unittest.end(env)

simple_test = unittest.make(_simple_test_impl)

def _short_alphabet_test_impl(ctx):
    env = unittest.begin(ctx)

    alphabet = "abc"
    s = sqids(alphabet = alphabet)

    numbers = [1, 2, 3]

    asserts.equals(env, s.decode(s.encode(numbers)), numbers)
    asserts.equals(env, decode(encode(numbers, alphabet), alphabet), numbers)

    return unittest.end(env)

short_alphabet_test = unittest.make(_short_alphabet_test_impl)

def _long_alphabet_test_impl(ctx):
    env = unittest.begin(ctx)

    alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_+|{}[];:'\"/?.>,<`~"
    s = sqids(alphabet = alphabet)

    numbers = [1, 2, 3]

    asserts.equals(env, s.decode(s.encode(numbers)), numbers)
    asserts.equals(env, decode(encode(numbers, alphabet), alphabet), numbers)

    return unittest.end(env)

long_alphabet_test = unittest.make(_long_alphabet_test_impl)

def _multibyte_alphabet_test_impl(ctx):
    env = analysistest.begin(ctx)

    asserts.expect_failure(env, "Alphabet cannot contain multibyte characters")

    return analysistest.end(env)

multibyte_alphabet_test = analysistest.make(_multibyte_alphabet_test_impl, expect_failure = True)

def _repeating_alphabet_characters_test_impl(ctx):
    env = analysistest.begin(ctx)

    asserts.expect_failure(env, "Alphabet must contain unique characters")

    return analysistest.end(env)

repeating_alphabet_characters_test = analysistest.make(
    _repeating_alphabet_characters_test_impl,
    expect_failure = True,
)

def _too_short_alphabet_test_impl(ctx):
    env = analysistest.begin(ctx)

    asserts.expect_failure(env, "Alphabet length must be at least 3")

    return analysistest.end(env)

too_short_alphabet_test = analysistest.make(_too_short_alphabet_test_impl, expect_failure = True)

def alphabet_test_suite(name = "alphabet_test_suite"):
    """Alphabet Test Suite

    Args:
      name: Name of the testsuite
    """

    multibyte_alphabet_test(
        name = "multibyte_alphabet_test",
        target_under_test = ":multibyte_alphabet_test_fake_target",
    )
    hashed_file(
        name = "multibyte_alphabet_test_fake_target",
        alphabet = "ë1092",
        numbers = [1, 2, 3],
        tags = ["manual"],
    )
    repeating_alphabet_characters_test(
        name = "repeating_alphabet_characters_test",
        target_under_test = ":repeating_alphabet_characters_test_fake_target",
    )
    hashed_file(
        name = "repeating_alphabet_characters_test_fake_target",
        alphabet = "aabcdefg",
        numbers = [1, 2, 3],
        tags = ["manual"],
    )
    too_short_alphabet_test(
        name = "too_short_alphabet_test",
        target_under_test = ":too_short_alphabet_test_fake_target",
    )
    hashed_file(
        name = "too_short_alphabet_test_fake_target",
        alphabet = "ab",
        numbers = [1, 2, 3],
        tags = ["manual"],
    )
    unittest.suite(
        name,
        long_alphabet_test,
        short_alphabet_test,
        simple_test,
    )
