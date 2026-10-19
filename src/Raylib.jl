"""
C-style Julia bindings to raylib 6.0. Use qualified calls (`Raylib.DrawText`)
to avoid collisions with Base names. Native resources require explicit unloading.
"""
module Raylib
using Raylib_jll: libraylib
include("bindings.jl")

"Run `f()` with a window, closing it even if `f` throws."
function with_window(f::Function, width::Integer, height::Integer, title::AbstractString; fps::Integer=60)
    InitWindow(width, height, title)
    try
        IsWindowReady() || error("raylib could not initialize a window")
        SetTargetFPS(fps)
        f()
    finally
        CloseWindow()
    end
end

"Run `f()` between BeginDrawing and EndDrawing, even if `f` throws."
function drawing(f::Function)
    BeginDrawing()
    try
        f()
    finally
        EndDrawing()
    end
end
export with_window, drawing
end
