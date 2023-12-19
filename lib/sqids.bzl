"""Sqids Bazel

Generate unique IDs from numbers

This module implements encoding and decoding [sqids](https://sqids.org/).
The code is heavily adopted from [sqids-python](https://github.com/sqids/sqids-python).
"""

load("@aspect_bazel_lib//lib:strings.bzl", "ord")
load("//lib:constants.bzl", "DEFAULT_ALPHABET", "DEFAULT_BLOCKLIST", "DEFAULT_MIN_LENGTH")

_FOREVER = range(1073741824)

def _unique(arr):
    ret = list()
    for a in arr:
        if a not in ret:
            ret.append(a)
    return ret

def _sum(numbers):
    ret = 0
    for n in numbers:
        ret += n
    return ret

def _to_id(num, alphabet):
    id_chars = []
    chars = alphabet.elems()
    result = num

    for _ in _FOREVER:
        id_chars.insert(0, chars[result % len(chars)])
        result = result // len(chars)
        if result == 0:
            break

    return "".join(id_chars)

def _shuffle(alphabet):
    chars = list(alphabet.elems())

    j = len(chars) - 1
    for i in _FOREVER:
        if j > 0:
            r = (i * j + ord(chars[i]) + ord(chars[j])) % len(chars)
            chars[i], chars[r] = chars[r], chars[i]
            j -= 1
            continue
        break

    return "".join(chars)

def _is_blocked_id(id_, blocklist):
    id_ = id_.lower()

    for word in blocklist:
        if len(word) > len(id_):
            continue
        if len(id_) <= 3 or len(word) <= 3:
            if id_ == word:
                return True
        elif any([c.isdigit() for c in word.elems()]):
            if id_.startswith(word) or id_.endswith(word):
                return True
        elif word in id_:
            return True

    return False

def _filter_blocklist(blocklist, alphabet):
    filtered_blocklist = list()
    alphabet_lower = alphabet.lower()
    for word_lower in [w.lower() for w in blocklist if len(w) >= 3]:
        intersection = [c for c in word_lower.elems() if c in alphabet_lower]
        if len(intersection) == len(word_lower):
            filtered_blocklist.append(word_lower)
    return _unique(filtered_blocklist)

def _encode_numbers(options, numbers, increment):
    if increment > len(options.alphabet):
        fail("Reached max attempts to re-generate the ID")

    offset = _sum(
        [
            ord(options.alphabet[v % len(options.alphabet)]) + i
            for i, v in enumerate(numbers)
        ],
    )
    offset = (offset + len(numbers)) % len(options.alphabet)
    offset = (offset + increment) % len(options.alphabet)
    alphabet = options.alphabet[offset:] + options.alphabet[:offset]
    prefix = alphabet[0]
    alphabet = alphabet[::-1]
    ret = [prefix]

    for i, num in enumerate(numbers):
        ret.append(_to_id(num, alphabet[1:]))

        if i >= len(numbers) - 1:
            continue

        ret.append(alphabet[0])
        alphabet = _shuffle(alphabet)

    id_ = "".join(ret)

    if options.min_length > len(id_):
        id_ += alphabet[0]

        for _ in _FOREVER:
            if (options.min_length - len(id_)) > 0:
                alphabet = _shuffle(alphabet)
                id_ += alphabet[:min(options.min_length - len(id_), len(alphabet))]
                continue
            break

    return id_

def _sqrt(a, b):
    if b == 0:
        return 1
    ret = a
    for _ in range(b - 1):
        ret *= a
    return ret

def _to_number(alphabet, id_):
    chars = alphabet.elems()
    return _sum([chars.index(c) * _sqrt(len(chars), i) for i, c in enumerate(id_[::-1].elems())])

def _decode(options, id_):
    ret = []

    if not id_:
        return ret

    alphabet_chars = options.alphabet.elems()
    if any([c not in alphabet_chars for c in id_.elems()]):
        return ret

    prefix = id_[0]
    offset = options.alphabet.index(prefix)
    alphabet = options.alphabet[offset:] + options.alphabet[:offset]
    alphabet = alphabet[::-1]
    id_ = id_[1:]

    for _ in _FOREVER:
        if id_:
            separator = alphabet[0]
            chunks = id_.split(separator)
            if chunks:
                if not chunks[0]:
                    return ret

                ret.append(_to_number(alphabet[1:], chunks[0]))
                if len(chunks) > 1:
                    alphabet = _shuffle(alphabet)
            id_ = separator.join(chunks[1:])
            continue
        break
    return ret

def _encode(options, numbers):
    id = ""
    if numbers == None:
        return id

    in_range_numbers = [n for n in numbers if n >= 0]
    if len(in_range_numbers) != len(numbers):
        fail("Encoding supports numbers greater than 0")

    for i in _FOREVER:
        id = _encode_numbers(options, numbers, i)
        if not _is_blocked_id(id, options.blocklist):
            break
    return id

def _check_options(alphabet, min_length):
    for char in alphabet.elems():
        if ord(char) > 127:
            fail("Alphabet cannot contain multibyte characters")

    if len(alphabet) < 3:
        fail("Alphabet length must be at least 3")

    if len(_unique(alphabet.elems())) != len(alphabet):
        fail("Alphabet must contain unique characters")

    if type(min_length) != "int":
        fail("Minimum length must be an integer")

    MIN_LENGTH_LIMIT = 255
    if min_length < 0 or min_length > MIN_LENGTH_LIMIT:
        fail("Minimum length has to be between 0 and %s" % MIN_LENGTH_LIMIT)

def encode(numbers = None, alphabet = DEFAULT_ALPHABET, blocklist = DEFAULT_BLOCKLIST, min_length = DEFAULT_MIN_LENGTH):
    """encode a list of numbers to an id

    Example:
      ```starlark
      load("@sqids_bazel//:defs.bzl", "encode")

      print(encode([1, 2, 3])) // 86Rf07
      ```

    Args:
      numbers: list of numbers to encode
      alphabet: list of characters to generate the ids from
      blocklist: list of words to avoid in hashes
      min_length: minimal count of characters

    Returns:
      A generated id as string
    """
    _check_options(alphabet, min_length)
    options = struct(
        alphabet = _shuffle(alphabet),
        blocklist = _filter_blocklist(blocklist, alphabet),
        min_length = min_length,
    )
    return _encode(options, numbers)

def decode(id, alphabet = DEFAULT_ALPHABET):
    """decode a string to a list of numbers

    Example:
      ```starlark
      load("@sqids_bazel//:defs.bzl", "decode")

      print(decode("86Rf07")) // [1, 2, 3]
      ```

    Args:
      id: list of numbers to encode
      alphabet: list of characters to generate the ids from

    Returns:
      A list of numbers
    """
    _check_options(alphabet, DEFAULT_MIN_LENGTH)
    options = struct(
        alphabet = _shuffle(alphabet),
    )
    return _decode(options, id)

def sqids(alphabet = DEFAULT_ALPHABET, blocklist = DEFAULT_BLOCKLIST, min_length = DEFAULT_MIN_LENGTH):
    """Generate unique IDs from numbers

    For convinience, export a function that takes optional arguments alphabet,
    blocklist and min_length and exports a `struct` that holds `decode` and
    `encode` methods which only take an id or a list of numbers, respectively.

    This API is similar to the [javascript](https://github.com/sqids/sqids-javascript) or
    [python](https://github.com/sqids/sqids-python) implementation.

    Example:
      ```starlark
      load("@sqids_bazel//:defs.bzl", "sqids")

      s = sqids()
      print(s.encode([1, 2, 3])) // 86Rf07
      ```

    Args:
      alphabet: list of characters to generate the ids from
      blocklist: list of words to avoid in hashes
      min_length: minimal count of characters

    Returns:
      A `struct` holding the `encode` and `decode` methods.
    """

    _check_options(alphabet, min_length)

    options = struct(
        alphabet = _shuffle(alphabet),
        blocklist = _filter_blocklist(blocklist, alphabet),
        min_length = min_length,
    )

    def encode_wrapper(numbers = None):
        return _encode(options, numbers)

    def decode_wrapper(id = None):
        return _decode(options, id)

    return struct(
        encode = encode_wrapper,
        decode = decode_wrapper,
    )
