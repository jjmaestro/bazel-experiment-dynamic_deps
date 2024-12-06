load("defs.bzl", "bar_build_all")

bar_build_all("bar")

genquery(
    name = "foo_all",
    expression = 'filter("^//foo:foo~", //foo:all)',
    scope = [
        "//foo",
        "//foo:all_targets",
    ],
    strict = False,
)
