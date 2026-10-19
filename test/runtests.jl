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

@testset "Mutable image" begin
    image = Ref(rl.GenImageColor(2, 2, rl.BLACK))
    try
        rl.ImageDrawPixel(image, 0, 0, rl.RED)
        rl.ImageFlipVertical(image)
        @test rl.ColorToInt(rl.GetImageColor(image[], 0, 1)) == rl.ColorToInt(rl.RED)
        @test rl.ColorToInt(rl.GetImageColor(image[], 0, 0)) == rl.ColorToInt(rl.BLACK)
        rl.ImageResizeNN(image, 4, 4)
        @test (image[].width, image[].height) == (4, 4)
        @test rl.ColorToInt(rl.GetImageColor(image[], 0, 3)) == rl.ColorToInt(rl.RED)
    finally
        rl.UnloadImage(image[])
    end
end

@testset "Audio buffers without a device" begin
    samples = Int16[0, 8192, -16384, 32767]
    # The source Wave borrows Julia memory; only the native copy is unloaded.
    wave = GC.@preserve samples begin
        rl.WaveCopy(rl.Wave(length(samples), 22050, 16, 1, pointer(samples)))
    end
    try
        @test rl.IsWaveValid(wave)
        cropped = Ref(wave)
        rl.WaveCrop(cropped, 1, 3)
        wave = cropped[]
        @test wave.frameCount == 2
        output = rl.LoadWaveSamples(wave)
        @test output != C_NULL
        if output != C_NULL
            try
                @test unsafe_wrap(Array, output, 2) ≈ Float32[0.25, -0.5] atol=1f-4
            finally
                rl.UnloadWaveSamples(output)
            end
        end
    finally
        rl.UnloadWave(wave)
    end
end

if get(ENV, "RAYLIB_TEST_GRAPHICS", "0") == "1"
    @testset "Graphics and exception cleanup" begin
        @test_throws ErrorException rl.with_window(128, 128, "cleanup") do
            error("intentional failure")
        end
        @test !rl.IsWindowReady()
        rl.with_window(128, 128, "texture") do
            image = rl.GenImageColor(2, 2, rl.RED)
            texture = try
                rl.LoadTextureFromImage(image)
            finally
                rl.UnloadImage(image)
            end
            try
                @test rl.IsTextureValid(texture)
                pixels = fill(rl.GREEN, 4)
                rl.UpdateTexture(texture, pixels)
                readback = rl.LoadImageFromTexture(texture)
                try
                    @test (readback.width, readback.height) == (2, 2)
                    @test rl.ColorToInt(rl.GetImageColor(readback, 1, 1)) == rl.ColorToInt(rl.GREEN)
                finally
                    rl.UnloadImage(readback)
                end
            finally
                rl.UnloadTexture(texture)
            end
        end
        for example in ("basic_2d.jl", "basic_3d.jl")
            run(`$(Base.julia_cmd()) --project=$(dirname(@__DIR__)) $(joinpath(@__DIR__, "..", "examples", example)) --smoke`)
        end
    end
end
