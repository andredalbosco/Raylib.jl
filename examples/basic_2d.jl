import Raylib as rl

# Pass --smoke to render three frames and exit (also works under Xvfb).
smoke = "--smoke" in ARGS
rl.with_window(800, 450, "Raylib.jl — 2D") do
    frame = 0
    while !rl.WindowShouldClose() && (!smoke || frame < 3)
        t = Float32(rl.GetTime())
        rl.drawing() do
            rl.ClearBackground(rl.RAYWHITE)
            rl.DrawText("Hello from Julia!", 30, 30, 30, rl.DARKGRAY)
            rl.DrawText("Press ESC to close", 30, 70, 20, rl.GRAY)
            rl.DrawCircleV(rl.Vector2(400 + 150sin(t), 250), 55, rl.SKYBLUE)
            rl.DrawRectangle(330, 330, 140, 25, rl.ORANGE)
            rl.DrawFPS(700, 20)
        end
        if smoke && frame == 2
            for arg in ARGS
                if startswith(arg, "--screenshot=")
                    image = rl.LoadImageFromScreen()
                    try
                        rl.ExportImage(image, split(arg, '='; limit=2)[2]) || error("Screenshot export failed")
                    finally
                        rl.UnloadImage(image)
                    end
                end
            end
        end
        frame += 1
    end
end
