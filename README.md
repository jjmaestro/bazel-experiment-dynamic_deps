# Experiment: Bazel package depending on other package targets dynamically

Example Bazel repo with a `//foo` package that creates a bunch of targets and a
`//bar` package that attempts to use these targets as 1:1 dependencies.

That is, we want to have `//bar` targets that depend on a `//foo` target
counterpart but we don't want to hardcode the `//foo` targets in `//bar` (e.g.
assume they are dynamic and/or can change.

Is there a way to do this? :-?

## Attempt 1

Call the `foo_build_all` macro from `bar_build_all` macro.

This one works, e.g.:

```shell
/src/workspace$ bazel build //bar:bar~foo~dim_1.1~dim_2.A
INFO: Analyzed target //bar:bar~foo~dim_1.1~dim_2.A (2 packages loaded, 3 targets configured).
INFO: Found 1 target...
Target //bar:bar~foo~dim_1.1~dim_2.A up-to-date:
  bazel-bin/bar/bar~foo~dim_1.1~dim_2.A.txt
INFO: Elapsed time: 0.108s, Critical Path: 0.01s
INFO: 3 processes: 1 internal, 2 processwrapper-sandbox.
INFO: Build completed successfully, 3 total actions

/src/workspace$ cat bazel-bin/bar/bar~foo~dim_1.1~dim_2.A.txt
name: //bar:bar~foo~dim_1.1~dim_2.A
src:  //foo:foo~dim_1.1~dim_2.A
foo~dim_1.1~dim_2.A
```

But "it's messy", because `foo_build_all` being a macro, it "polutes" `//bar`
with `//foo` targets:

```shell
/src/workspace$ bazel query //bar/...
//bar:bar~foo~dim_1.1~dim_2.A
//bar:bar~foo~dim_1.1~dim_2.B
//bar:bar~foo~dim_1.1~dim_2.C
//bar:bar~foo~dim_1.2~dim_2.A
//bar:bar~foo~dim_1.2~dim_2.B
//bar:bar~foo~dim_1.2~dim_2.C
//bar:foo
//bar:foo~dim_1.1~dim_2.A
//bar:foo~dim_1.1~dim_2.B
//bar:foo~dim_1.1~dim_2.C
//bar:foo~dim_1.2~dim_2.A
//bar:foo~dim_1.2~dim_2.B
//bar:foo~dim_1.2~dim_2.C
```
