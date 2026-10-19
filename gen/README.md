# Binding inputs

Vendored from [raysan5/raylib tag 6.0](https://github.com/raysan5/raylib/tree/6.0):

- `raylib.h`: `src/raylib.h`
- `raylib_api.json`: `tools/rlparser/output/raylib_api.json`
- `RAYLIB_LICENSE`: `LICENSE`

All three retain their upstream zlib license. The generated Julia API derives names, types, constants, and signatures from these inputs.

The upstream JSON includes descriptions containing unescaped double quotes. `generate.py` escapes description values before parsing; the vendored bytes are unchanged. The generator deliberately excludes the two variadic C functions, `TraceLog` and `TextFormat`.

SHA-256:

```
047e7255f93f8c34039cab906ad76136706b5c7b4c5b5b065d84141963ee9b6b  raylib.h
d4e2dd0727a8edf4d4f828e23f86e3bb74e373861edd0eabef4a634ae74936d6  raylib_api.json
```

`Raylib_jll` 6.0.1 builds raylib commit `dbc56a87da87d973a9c5baa4e7438a9d20121d28`; its header was compared byte-for-byte with this header. The [Yggdrasil recipe](https://github.com/JuliaPackaging/Yggdrasil/blob/master/R/Raylib/build_tarballs.jl) identifies that source commit.

The generator emits `src/bindings.jl` and `test/abi.c`. The latter verifies struct sizes and field offsets against the vendored header when compiled and compared by `test/abi.jl`.
