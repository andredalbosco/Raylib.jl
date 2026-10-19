# Raylib.jl

Julia bindings for [raylib](https://github.com/raysan5/raylib), a small C library for graphics, input, audio, and games.

This independent package exposes **598 non-variadic raylib 6.0 functions**, all 35 public structs and their aliases, enum constants, and named colors. It includes two small Julia helpers and runnable 2D/3D examples. Native binaries install automatically through `Raylib_jll`; no system raylib installation or C compiler is needed to use the package.

This is a new, unregistered package, independent of other projects named Raylib.jl. The API follows raylib's C spelling and resource ownership rules. It does not include raymath, rlgl, or raygui bindings.

## Install

Julia 1.10 or newer:

```julia
using Pkg
Pkg.add(url="https://github.com/andredalbosco/Raylib.jl")
```

The native dependency is pinned to `Raylib_jll` 6.0.1, whose raylib header matches the vendored 6.0 header. A graphical session with OpenGL 4.3 support is needed for windows with this binary build. Package loading and image/collision functions also work without a display. Binary availability depends on `Raylib_jll`'s supported platforms; local validation used Ubuntu x86-64.

## A window in Julia

```julia
import Raylib as rl

rl.with_window(800, 450, "Hello Julia") do
    while !rl.WindowShouldClose()
        rl.drawing() do
            rl.ClearBackground(rl.RAYWHITE)
            rl.DrawText("Hello from Julia!", 30, 30, 30, rl.DARKGRAY)
            rl.DrawCircleV(rl.Vector2(400, 250), 55, rl.SKYBLUE)
        end
    end
end
```

`with_window` closes the window on normal return or an exception. `drawing` pairs `BeginDrawing` and `EndDrawing`. The raw API is available too. Prefer qualified calls (`rl.DrawText`) to avoid name collisions with Julia's Base module.

## Run the examples

```sh
git clone https://github.com/andredalbosco/Raylib.jl.git
cd Raylib.jl
julia --project=. -e 'using Pkg; Pkg.instantiate()'
julia --project=. examples/basic_2d.jl
julia --project=. examples/basic_3d.jl
```

Press Escape to close. Add `--smoke` to render three frames and exit. Add `--smoke --screenshot=/tmp/example.png` to save the final frame.

## Calling the C API

Use the [raylib 6.0 header](gen/raylib.h) for signatures and ownership documentation. Structs are immutable Julia `isbits` values with C-compatible layouts; constructors convert ordinary numbers to C field types. A function that mutates a struct through a pointer needs a `Ref`:

```julia
camera = Ref(rl.Camera3D(rl.Vector3(6, 5, 6), rl.Vector3(0, 1, 0),
                         rl.Vector3(0, 1, 0), 45, rl.CAMERA_PERSPECTIVE))
# Inside the window loop:
rl.UpdateCamera(camera, rl.CAMERA_ORBITAL)
rl.BeginMode3D(camera[])
# ...draw...
rl.EndMode3D()
```

- Free native resources with the matching `Unload*` function. Julia's garbage collector does not release textures, images, sounds, meshes, or other raylib allocations. Unload GPU resources before closing the window.
- Input C strings accept Julia strings. Returned C strings are pointers: copy with `unsafe_string` while the pointer is valid. Do not free borrowed strings; follow the header for owning results.
- Pointer arguments follow Julia's `ccall` conversion rules. Keep Julia buffers and callbacks alive for as long as native code holds them; use `GC.@preserve` when constructing raw pointers. Incorrect pointers or lengths can crash the process.
- Callback arguments are raw function pointers. Automatic callback adapters, foreign-thread callback safety, and resource finalizers are not provided. In particular, do not pass an ordinary Julia callback directly to the native audio thread.
- Call window and rendering operations from the same main thread. Nested windows and nested drawing scopes are unsupported.
- `TraceLog` and `TextFormat` are C variadic functions and are omitted. Use Julia's logging, string interpolation, or `Printf` for those needs.

## Validation

```sh
julia --project=. -e 'using Pkg; Pkg.test()'
julia --project=. test/abi.jl  # requires cc
RAYLIB_TEST_GRAPHICS=1 LIBGL_ALWAYS_SOFTWARE=1 xvfb-run -a \
  julia --project=. -e 'using Pkg; Pkg.test()'
```

Tests resolve every wrapped native symbol, check representative calls across the C ABI, and compare all 35 struct sizes and field offsets against a C compiler. The optional graphics tests exercise exception cleanup and both examples under Xvfb. CI runs on Julia 1.10 and the current stable Julia release.

Local validation: Julia 1.13.2 on Ubuntu; 598 symbol checks, 13 native-call checks, 70 C layout checks, and graphics cleanup tests passed. Both examples rendered successfully using software OpenGL, and their exported screenshots were visually inspected. This does not establish behavioral coverage of all 598 functions; audio devices, callbacks, model loading, and other platforms have not been exercised.

## Regenerate

```sh
python3 gen/generate.py
```

The generator uses vendored upstream metadata, so regeneration is offline and deterministic. See [gen/README.md](gen/README.md) for provenance and third-party licensing.

## License

Original Julia code and tooling: MIT. Vendored raylib files retain raylib's zlib license, included in [gen/RAYLIB_LICENSE](gen/RAYLIB_LICENSE).
