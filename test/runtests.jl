using Test, Libdl
import Raylib as rl

@testset "Native symbols" begin
    lib = dlopen(rl.libraylib)
    for name in names(rl)
        value = getproperty(rl, name)
        if value isa Function && name ∉ (:with_window, :drawing)
            @test dlsym(lib, name; throw_error=false) !== nothing
        end
    end
    dlclose(lib)
end

@testset "Values across the C ABI" begin
    @test sizeof(rl.Vector2) == 8
    @test sizeof(rl.Vector3) == 12
    @test sizeof(rl.Color) == 4
    @test sizeof(rl.Camera3D) == 44
    @test rl.ColorToInt(rl.Color(0x12, 0x34, 0x56, 0x78)) == 0x12345678
    @test rl.Fade(rl.RED, 0.5).a == 127
    c = rl.GetColor(0x12345678)
    @test (c.r, c.g, c.b, c.a) == (0x12, 0x34, 0x56, 0x78)
    @test rl.CheckCollisionRecs(rl.Rectangle(0, 0, 10, 10), rl.Rectangle(5, 5, 10, 10))
    @test !rl.CheckCollisionCircles(rl.Vector2(0, 0), 1, rl.Vector2(10, 10), 1)
    r = rl.GetCollisionRec(rl.Rectangle(0, 0, 10, 10), rl.Rectangle(5, 5, 10, 10))
    @test (r.x, r.y, r.width, r.height) == (5, 5, 5, 5)
    @test unsafe_string(rl.TextSubtext("Julia raylib", 6, 6)) == "raylib"
    image = rl.GenImageColor(4, 3, rl.ORANGE)
    try
        @test (image.width, image.height) == (4, 3)
        pixel = rl.GetImageColor(image, 2, 1)
        @test rl.ColorToInt(pixel) == rl.ColorToInt(rl.ORANGE)
    finally
        rl.UnloadImage(image)
    end
end

if get(ENV, "RAYLIB_TEST_GRAPHICS", "0") == "1"
    @testset "Graphics and exception cleanup" begin
        @test_throws ErrorException rl.with_window(128, 128, "cleanup") do
            error("intentional failure")
        end
        @test !rl.IsWindowReady()
        for example in ("basic_2d.jl", "basic_3d.jl")
            run(`$(Base.julia_cmd()) --project=$(dirname(@__DIR__)) $(joinpath(@__DIR__, "..", "examples", example)) --smoke`)
        end
    end
end
