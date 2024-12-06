load("//:utils.bzl", "CartesianTarget")
load("//foo:defs.bzl", "foo_build_all")

def bar_build(name, target):
    src = "//foo:%s" % target.foo_target_name

    native.genrule(
        name = target.name,
        srcs = [src],
        outs = ["%s.txt" % target.name],
        cmd = """
        {{
            echo "name: //bar:{name}"
            echo "src:  {src}"
            cat $(location {src})
        }} > $@
        """.format(name = target.name, src = src),
    )

    return target

def bar_build_all(name):
    return [
        bar_build(name, CartesianTarget(name, foo_target_name = foo_target.name))
        for foo_target in foo_build_all("foo")
    ]
