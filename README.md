# [Sqids Bazel](https://sqids.org/bazel)

[![Github Actions](https://img.shields.io/github/actions/workflow/status/sqids/sqids-bazel/ci.yml)](https://github.com/sqids/sqids-bazel/actions)

[Sqids](https://sqids.org/bazel) (*pronounced "squids"*) is a small library that lets you **generate unique IDs from numbers**. It's good for link shortening, fast & URL-safe ID generation and decoding back into numbers for quicker database lookups.

Features:

- **Encode multiple numbers** - generate short IDs from one or several non-negative numbers
- **Quick decoding** - easily decode IDs back into numbers
- **Unique IDs** - generate unique IDs by shuffling the alphabet once
- **ID padding** - provide minimum length to make IDs more uniform
- **URL safe** - auto-generated IDs do not contain common profanity
- **Randomized output** - Sequential input provides nonconsecutive IDs
- **Many implementations** - Support for [multiple programming languages](https://sqids.org/)

## 🧰 Use-cases

Good for:

- Generating IDs for public URLs (eg: link shortening)
- Generating IDs for internal systems (eg: event tracking)
- Decoding for quicker database lookups (eg: by primary keys)

Not good for:

- Sensitive data (this is not an encryption library)
- User IDs (can be decoded revealing user count)

## 🚀 Getting started

```starlark
@TODO
```

## 👩‍💻 Examples

Simple encode & decode:

```starlark
@TODO
```

> **Note**
> 🚧 Because of the algorithm's design, **multiple IDs can decode back into the same sequence of numbers**. If it's important to your design that IDs are canonical, you have to manually re-encode decoded numbers and check that the generated ID matches.

Enforce a *minimum* length for IDs:

```starlark
@TODO
```

Randomize IDs by providing a custom alphabet:

```starlark
@TODO
```

Prevent specific words from appearing anywhere in the auto-generated IDs:

```starlark
@TODO
```

## 📝 License

[MIT](LICENSE)
