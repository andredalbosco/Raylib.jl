import Raylib as rl

smoke = "--smoke" in ARGS
# Ref lets raylib update the camera through a C pointer.
camera = Ref(rl.Camera3D(rl.Vector3(6, 5, 6), rl.Vector3(0, 1, 0),
                     rl.Vector3(0, 1, 0), 45, rl.CAMERA_PERSPECTIVE))
rl.with_window(800, 450, "Raylib.jl — 3D") do
    frame = 0
    while !rl.WindowShouldClose() && (!smoke || frame < 3)
        rl.UpdateCamera(camera, rl.CAMERA_ORBITAL)
        rl.drawing() do
            rl.ClearBackground(rl.RAYWHITE)
            rl.BeginMode3D(camera[])
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
        frame += 1
    end
end
