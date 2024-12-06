load("//:utils.bzl", "product")
load("//foo:defs.bzl", "DEFAULT_TARGET", "TARGETS")

def _bar_build(name, foo_target):
    src = "//foo:%s" % foo_target.name

    native.genrule(
        name = name,
        srcs = [src],
        outs = ["%s.txt" % name],
        cmd = """
        {{
            echo "name: //bar:{name}"
            echo "src:  {src}"
            cat $(location {src})
        }} > $@
        """.format(name = name, src = src),
    )

def bar_build_all(name, dim1 = None, dim2 = None):
    product.macro("bar", _bar_build, TARGETS, DEFAULT_TARGET)
