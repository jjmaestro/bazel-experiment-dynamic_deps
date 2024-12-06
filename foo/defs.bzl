"""
defs.bzl
"""

load("//:utils.bzl", "CartesianTarget", "product")

DIM1S = ["dim_1.1", "dim_1.2"]
DIM2S = ["dim_2.A", "dim_2.B", "dim_2.C"]

def foo_build(name, target):
    native.genrule(
        name = name,
        outs = ["%s.txt" % name],
        cmd = "echo '{target_name}' > $@".format(
            target_name = name,
        ),
        visibility = ["//visibility:public"],
    )

    return target

def foo_build_all(name, dim1 = None, dim2 = None):
    targets, default = product.targets(
        name,
        dim1 = dim1 or DIM1S,
        dim2 = dim2 or DIM2S,
    )

    return product.macro(name, foo_build, targets, default)
