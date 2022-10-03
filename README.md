# Example of pip backtracking failure

## Failing case description

Installing (internally conflicting) "requirements.txt" which has lots of
transient dependencies, with simple command like `pip install -r requirements.txt`
with "very simple" looking content of "requirements.txt" looking like:

```
pywebview[qt]==3.6.2
rpaframework==15.6.0
```

And note that this specific example applies only on Linux environments.
But I think problem is general, and "old, previously working" requirement sets
can get "rotten" over time, as dependency "future" takes "wrong" turn. This
is because resolver works from latest to oldest, and even one few versions of
some required dependencies can derail resolver into backtracking "mode".

## Context of our problem space.

Here are some things, that make this problem to Robocorp customers.

- machines executing "pip install" can be fast or slow (or very slow)
- pip version can be anything old or new (backward compatible generic usage)
- pip environment setup time is "billable" time, so "fail fast" is cheaper
  in monetary terms than "fail 4+ hours later on total environment build
  failure"
- automation is setting up environment, not humans
- our tooling for automation in our `rcc` which is used here to also make this
  repeatable process
- and general context for automation is RPA (robotic process automation) so
  processes should be repeatable and reliable and not break, even if time passes

## Problem with backtracking

### It is very slow to fail.

Currently happy path works (fast enough), but if you derail resolver to unbeaten
path, then resolution takes long time, because in pip source
https://github.com/pypa/pip/blob/main/src/pip/_internal/resolution/resolvelib/resolver.py#L91
there is magical internal variable `try_to_avoid_resolution_too_deep = 2000000`
which causes very long search until it fails.

### Brute force search for possibly huge search space.

When package, like `rpaframework` below, has something around 100 dependencies
it its dependency tree, even happy path resolution takes 100+ rounds of pip
dependency resolution to find it. When backtracking, (just one) processor
becomes 100% busy for backtracking work.

### In automation, there is no "human" to press "Control-C".

> INFO: pip is looking at multiple versions of selenium to determine which
> version is compatible with other requirements. This could take a while.

and ...

> INFO: This is taking longer than usual. You might need to provide the
> dependency resolver with stricter constraints to reduce runtime.
> See https://pip.pypa.io/warnings/backtracking for guidance.
> If you want to abort this run, press Ctrl + C.

... are nice for `pip` to inform user that it is taking longer than usual, but
in our customers automation cases, there is nobody who could see those, or
to press that "Ctrl + C".

This could be improved, if there would be environment variable like
`MAX_PIP_RESOLUTION_ROUNDS` instead of having hard coded 2000000 internal limit.
Also adding this as environment variable (instead of command line option is
better backwards compatibility, since "extra" environment variable does not
kill old pip version commands, but CLI option will).

## Basic setup

What is needed:

- a linux machine
- python3, in our case we have tested 3.9.13
- pip, in our case we have tested 22.1.2 (but mostly anything after 20.3 has
  this feature; this current example uses pip v22.2.2)

## Example code

You need `rcc` to run these examples. Or do manual environment setup if you will.

You can download rcc binaries from https://downloads.robocorp.com/rcc/releases/index.html
or if you want to more information, see https://github.com/robocorp/rcc

### Success case (just for reference)

To run success case as what normal user sees, use this:

```sh
rcc run --task pass
```

And to see debugging output, use this:

```sh
rcc run --dev --task pass
```

### Actual failure case (point of this demo)

To run failing case as what normal user sees, use this ... and have patience to wait:

```sh
rcc run --task fail
```

And to see debugging output, use this ... and have patience to wait:

```sh
rcc run --dev --task fail
```
