"""utils.bzl"""

__MAX_ITERATIONS__ = 2 << 31 - 2

def _defaults(args):
    return tuple([values[0] for values in args])

def _product_args(defaults = None, *args):
    """Cartesian product of a list of lists.

    Arguments:
        *args: List of lists, each a list of values.

    Return:
        product: Cartesian product of the elements in the lists.
        default: The Cartesian product elements that's considered the default
                 value. It is chosen by the defaults function passed to
                 product_args.

    Example:
        product, default = product_args([1, 2], ['a'], [3, 4])

        for values in product:
            print(values)
        (1, 'a', 3)
        (1, 'a', 4)
        (2, 'a', 3)
        (2, 'a', 4)

        print(default)
        (1, 'a', 3)
    """
    defaults = defaults or _defaults

    if not args:
        return

    stack = [(0, [])]

    product = []

    for i in range(__MAX_ITERATIONS__):
        if not len(stack):
            break

        if i + 1 == __MAX_ITERATIONS__:
            fail("product: __MAX_ITERATIONS__")

        index, current = stack.pop()

        if index == len(args):
            product.append(tuple(current))
        else:
            for element in reversed(args[index]):
                stack.append((index + 1, current + [element]))

    return product, defaults(args)

def _product_kwargs(defaults = None, **kwargs):
    """Cartesian product of a dict of lists."""
    keys = kwargs.keys()
    values = kwargs.values()

    product, default = _product_args(defaults, *values)

    product = [dict(zip(keys, pvalues)) for pvalues in product]
    default = dict(zip(keys, default))

    return product, default

def _to_name(**kwargz):
    return "~".join([str(v) for v in kwargz.values()])

def CartesianTarget(name, to_name = None, **kwargs):
    to_name = to_name or _to_name

    kwargs = {"name": name} | kwargs
    kwargs["name"] = to_name(**kwargs)

    return struct(**kwargs)

def _product_targets(name, defaults = None, **kwargs):
    """Cartesian product of a dict of lists that returns a list of
    CartesianTarget.
    """
    product, default = _product_kwargs(defaults, **kwargs)

    product = [CartesianTarget(name, **element) for element in product]
    default = CartesianTarget(name, **default)

    return product, default

def _product_macro(name, macro, targets, default):
    for target in targets:
        macro(target.name, target)

    native.alias(
        name = name,
        actual = default.name,
        visibility = ["//visibility:public"],
    )

    # NOTE:
    # This is needed to put all build_names in the :all_targets
    # scope so that we can get them in a genquery.
    native.filegroup(
        name = "all_targets",
        srcs = [target.name for target in targets],
        visibility = ["//visibility:public"],
    )

product = struct(
    args = _product_args,
    kwargs = _product_kwargs,
    targets = _product_targets,
    macro = _product_macro,
)
