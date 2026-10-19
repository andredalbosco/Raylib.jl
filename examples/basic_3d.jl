import Raylib as rl

smoke = "--smoke" in ARGS
camera = rl.Camera3D(rl.Vector3(6, 5, 6), rl.Vector3(0, 1, 0),
                     rl.Vector3(0, 1, 0), 45, rl.CAMERA_PERSPECTIVE)
rl.with_window(800, 450, "Raylib.jl — 3D") do
    frame = 0
    while !rl.WindowShouldClose() && (!smoke || frame < 3)
        rl.drawing() do
            rl.ClearBackground(rl.RAYWHITE)
            rl.BeginMode3D(camera)
            try
                rl.DrawCube(rl.Vector3(0, 1, 0), 2, 2, 2, rl.ORANGE)
                rl.DrawCubeWires(rl.Vector3(0, 1, 0), 2, 2, 2, rl.MAROON)
                rl.DrawGrid(20, 1)
            finally
                rl.EndMode3D()
            end
            rl.DrawText("Julia + raylib: a cube in 3D", 20, 20, 24, rl.DARKGRAY)
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
