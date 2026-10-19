# Raylib.jl

Julia bindings for [raylib 6.0](https://github.com/raysan5/raylib/tree/6.0). Native binaries install through `Raylib_jll`. Requires Julia 1.10+.

```julia
using Pkg
Pkg.add(url="https://github.com/andredalbosco/Raylib.jl")
```

Run from this checkout:

```sh
julia --project=. -e 'using Pkg; Pkg.instantiate()'
julia --project=. examples/basic_2d.jl
julia --project=. examples/basic_3d.jl
```

`examples/basic_3d.jl` shows camera mutation through `Ref`.

The API follows raylib's C names. Release native resources with their matching `Unload*` functions. `TraceLog` and `TextFormat` are omitted.

Tests: `julia --project=. -e 'using Pkg; Pkg.test()'`. Regenerate bindings: `python3 gen/generate.py`.
