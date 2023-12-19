"Min Length Tests"

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts", "unittest")
load("//:defs.bzl", "decode", "encode", "sqids")
load("//lib:constants.bzl", "DEFAULT_ALPHABET")
load("//lib/tests:utils.bzl", "hashed_file")

def _simple_test_impl(ctx):
    env = unittest.begin(ctx)

    min_length = len(DEFAULT_ALPHABET)
    s = sqids(min_length = min_length)

    numbers = [1, 2, 3]
    id = "86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTM"

    asserts.equals(env, s.encode(numbers), id)
    asserts.equals(env, encode(numbers, min_length = min_length), id)
    asserts.equals(env, s.decode(id), numbers)
    asserts.equals(env, decode(id), numbers)

    return unittest.end(env)

simple_test = unittest.make(_simple_test_impl)

def _incremental_test_impl(ctx):
    env = unittest.begin(ctx)

    numbers = [1, 2, 3]
    map = {
        6: "86Rf07",
        7: "86Rf07x",
        8: "86Rf07xd",
        9: "86Rf07xd4",
        10: "86Rf07xd4z",
        11: "86Rf07xd4zB",
        12: "86Rf07xd4zBm",
        13: "86Rf07xd4zBmi",
    }

    map[len(DEFAULT_ALPHABET) + 0] = "86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTM"
    map[len(DEFAULT_ALPHABET) + 1] = "86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTMy"
    map[len(DEFAULT_ALPHABET) + 2] = "86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTMyf"
    map[len(DEFAULT_ALPHABET) + 3] = "86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTMyf1"

    for min_length, id in map.items():
        s = sqids(min_length = min_length)

        asserts.equals(env, s.encode(numbers), id)
        asserts.equals(env, encode(numbers, min_length = min_length), id)
        asserts.equals(env, len(s.encode(numbers)), min_length)
        asserts.equals(env, len(encode(numbers, min_length = min_length)), min_length)
        asserts.equals(env, s.decode(id), numbers)
        asserts.equals(env, decode(id), numbers)

    return unittest.end(env)

incremental_test = unittest.make(_incremental_test_impl)

def _incremental_numbers_test_impl(ctx):
    env = unittest.begin(ctx)

    min_length = len(DEFAULT_ALPHABET)
    s = sqids(min_length = min_length)

    ids = {
        "SvIzsqYMyQwI3GWgJAe17URxX8V924Co0DaTZLtFjHriEn5bPhcSkfmvOslpBu": [0, 0],
        "n3qafPOLKdfHpuNw3M61r95svbeJGk7aAEgYn4WlSjXURmF8IDqZBy0CT2VxQc": [0, 1],
        "tryFJbWcFMiYPg8sASm51uIV93GXTnvRzyfLleh06CpodJD42B7OraKtkQNxUZ": [0, 2],
        "eg6ql0A3XmvPoCzMlB6DraNGcWSIy5VR8iYup2Qk4tjZFKe1hbwfgHdUTsnLqE": [0, 3],
        "rSCFlp0rB2inEljaRdxKt7FkIbODSf8wYgTsZM1HL9JzN35cyoqueUvVWCm4hX": [0, 4],
        "sR8xjC8WQkOwo74PnglH1YFdTI0eaf56RGVSitzbjuZ3shNUXBrqLxEJyAmKv2": [0, 5],
        "uY2MYFqCLpgx5XQcjdtZK286AwWV7IBGEfuS9yTmbJvkzoUPeYRHr4iDs3naN0": [0, 6],
        "74dID7X28VLQhBlnGmjZrec5wTA1fqpWtK4YkaoEIM9SRNiC3gUJH0OFvsPDdy": [0, 7],
        "30WXpesPhgKiEI5RHTY7xbB1GnytJvXOl2p0AcUjdF6waZDo9Qk8VLzMuWrqCS": [0, 8],
        "moxr3HqLAK0GsTND6jowfZz3SUx7cQ8aC54Pl1RbIvFXmEJuBMYVeW9yrdOtin": [0, 9],
    }

    for id_str, numbers in ids.items():
        asserts.equals(env, s.encode(numbers), id_str)
        asserts.equals(env, encode(numbers, min_length = min_length), id_str)
        asserts.equals(env, s.decode(id_str), numbers)
        asserts.equals(env, decode(id_str), numbers)

    return unittest.end(env)

incremental_numbers_test = unittest.make(_incremental_numbers_test_impl)

def _min_lengths_test_impl(ctx):
    env = unittest.begin(ctx)

    for min_length in [0, 1, 5, 10, len(DEFAULT_ALPHABET)]:
        for numbers in [
            [0],
            [0, 0, 0, 0, 0],
            [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            [100, 200, 300],
            [1000, 2000, 3000],
            [1000000],
        ]:
            s = sqids(min_length = min_length)

            id_str = s.encode(numbers)
            asserts.true(env, len(id_str) >= min_length)
            asserts.equals(env, s.decode(id_str), numbers)
            id_str = encode(numbers, min_length = min_length)
            asserts.true(env, len(id_str) >= min_length)
            asserts.equals(env, decode(id_str), numbers)

    return unittest.end(env)

min_lengths_test = unittest.make(_min_lengths_test_impl)

def _out_of_range_invalid_min_length_test_impl(ctx):
    env = analysistest.begin(ctx)

    asserts.expect_failure(env, "Minimum length has to be between 0 and 255")

    return analysistest.end(env)

out_of_range_invalid_min_length_test = analysistest.make(_out_of_range_invalid_min_length_test_impl, expect_failure = True)

def min_length_test_suite(name = "min_length_test_suite"):
    """Min Length Test Suite

    Args:
      name: Name of the testsuite
    """

    out_of_range_invalid_min_length_test(
        name = "out_of_range_invalid_min_length_test_1",
        target_under_test = ":out_of_range_invalid_min_length_test_1_fake_target",
    )
    hashed_file(
        name = "out_of_range_invalid_min_length_test_1_fake_target",
        min_length = -1,
        numbers = [1, 2, 3],
        tags = ["manual"],
    )
    out_of_range_invalid_min_length_test(
        name = "out_of_range_invalid_min_length_test_2",
        target_under_test = ":out_of_range_invalid_min_length_test_2_fake_target",
    )
    hashed_file(
        name = "out_of_range_invalid_min_length_test_2_fake_target",
        min_length = 256,
        numbers = [1, 2, 3],
        tags = ["manual"],
    )
    unittest.suite(
        name,
        incremental_numbers_test,
        incremental_test,
        min_lengths_test,
        simple_test,
    )
