"Blocklist Tests"

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//:defs.bzl", "decode", "encode", "sqids")

def _default_blocklist_test_impl(ctx):
    env = unittest.begin(ctx)

    s = sqids()

    numbers = [4572721]
    id = "aho1e"

    asserts.equals(env, s.decode(id), numbers)
    asserts.equals(env, decode(id), numbers)
    asserts.equals(env, s.encode(numbers), "JExTR")
    asserts.equals(env, encode(numbers), "JExTR")

    return unittest.end(env)

default_blocklist_test = unittest.make(_default_blocklist_test_impl)

def _empty_blocklist_test_impl(ctx):
    env = unittest.begin(ctx)

    blocklist = []
    s = sqids(blocklist = blocklist)

    numbers = [4572721]
    id = "aho1e"

    asserts.equals(env, s.decode(id), numbers)
    asserts.equals(env, decode(id), numbers)
    asserts.equals(env, s.encode(numbers), id)
    asserts.equals(env, encode(numbers, blocklist = blocklist), id)

    return unittest.end(env)

empty_blocklist_test = unittest.make(_empty_blocklist_test_impl)

def _custom_blocklist_test_impl(ctx):
    env = unittest.begin(ctx)

    blocklist = ["ArUO"]
    s = sqids(blocklist = blocklist)

    numbers = [4572721]
    id = "aho1e"
    blocked_id = "ArUO"
    blocked_numbers = [100000]

    asserts.equals(env, s.decode(id), numbers)
    asserts.equals(env, decode(id), numbers)
    asserts.equals(env, s.encode(numbers), id)
    asserts.equals(env, encode(numbers, blocklist = blocklist), id)

    asserts.equals(env, s.decode(blocked_id), blocked_numbers)
    asserts.equals(env, decode(blocked_id), blocked_numbers)
    asserts.equals(env, s.encode(blocked_numbers), "QyG4")
    asserts.equals(env, encode(blocked_numbers, blocklist = blocklist), "QyG4")
    asserts.equals(env, s.decode("QyG4"), blocked_numbers)
    asserts.equals(env, decode("QyG4"), blocked_numbers)

    return unittest.end(env)

custom_blocklist_test = unittest.make(_custom_blocklist_test_impl)

def _blocklist_test_impl(ctx):
    env = unittest.begin(ctx)

    blocklist = [
        "JSwXFaosAN",  # normal result of 1st encoding, block that word on purpose
        "OCjV9JK64o",  # result of 2nd encoding
        "rBHf",  # result of 3rd encoding is `4rBHfOiqd3`, let's block a substring
        "79SM",  # result of 4th encoding is `dyhgw479SM`, let's block the postfix
        "7tE6",  # result of 4th encoding is `7tE6jdAHLe`, let's block the prefix
    ]
    s = sqids(blocklist = blocklist)

    numbers = [1000000, 2000000]
    id = "1aYeB7bRUt"

    asserts.equals(env, s.encode(numbers), id)
    asserts.equals(env, encode(numbers, blocklist = blocklist), id)
    asserts.equals(env, s.decode(id), numbers)
    asserts.equals(env, decode(id), numbers)

    return unittest.end(env)

blocklist_test = unittest.make(_blocklist_test_impl)

def _decoding_blocklist_words_test_impl(ctx):
    env = unittest.begin(ctx)

    blocklist = ["86Rf07", "se8ojk", "ARsz1p", "Q8AI49", "5sQRZO"]
    numbers = [1, 2, 3]
    s = sqids(blocklist = blocklist)

    for id in blocklist:
        asserts.equals(env, s.decode(id), numbers)
        asserts.equals(env, decode(id), numbers)

    return unittest.end(env)

decoding_blocklist_words_test = unittest.make(_decoding_blocklist_words_test_impl)

def _match_against_short_blocklist_word_test_impl(ctx):
    env = unittest.begin(ctx)

    blocklist = ["pnd"]
    s = sqids(blocklist = blocklist)
    numbers = [1000]

    asserts.equals(env, s.decode(s.encode(numbers)), numbers)
    asserts.equals(env, decode(encode(numbers, blocklist = blocklist)), numbers)

    return unittest.end(env)

match_against_short_blocklist_word_test = unittest.make(_match_against_short_blocklist_word_test_impl)

def _blocklist_filtering_test_impl(ctx):
    env = unittest.begin(ctx)

    alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    blocklist = ["sxnzkl"]
    s = sqids(alphabet = alphabet, blocklist = blocklist)
    numbers = [1, 2, 3]
    id = "IBSHOZ"

    asserts.equals(env, s.encode(numbers), id)
    asserts.equals(env, encode(numbers, alphabet, blocklist), id)
    asserts.equals(env, s.decode(id), numbers)
    asserts.equals(env, decode(id, alphabet), numbers)

    return unittest.end(env)

blocklist_filtering_test = unittest.make(_blocklist_filtering_test_impl)

def blocklist_test_suite(name = "blocklist_test_suite"):
    unittest.suite(
        name,
        default_blocklist_test,
        empty_blocklist_test,
        custom_blocklist_test,
        blocklist_test,
        decoding_blocklist_words_test,
        match_against_short_blocklist_word_test,
        blocklist_filtering_test,
    )
