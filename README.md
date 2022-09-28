# Demo of pip backtracking

You need `rcc` to run these examples. Or do manual environment setup if you will.

You can download rcc binaries from https://downloads.robocorp.com/rcc/releases/index.html
or if you want to more information, see https://github.com/robocorp/rcc

## Success case (just for reference)

To run success case as what normal user sees, use this:

```sh
rcc run --task pass
```

And to see debugging output, use this:

```sh
rcc run --dev --task pass
```

## Actual failure case (point of this demo)

To run failing case as what normal user sees, use this ... and have patience to wait:

```sh
rcc run --task fail
```

And to see debugging output, use this ... and have patience to wait:

```sh
rcc run --dev --task fail
```
