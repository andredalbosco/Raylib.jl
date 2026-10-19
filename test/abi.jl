# Requires a C compiler; compares every struct size and field offset to raylib.h.
using Test
import Raylib as rl
mktempdir() do tmp
    exe = joinpath(tmp, "abi")
    run(`cc -I$(joinpath(@__DIR__, "..", "gen")) $(joinpath(@__DIR__, "abi.c")) -o $exe`)
    @testset "C header ABI layouts" begin
        for line in split(chomp(read(`$exe`, String)), '\n')
            words = split(line)
            T = getproperty(rl, Symbol(words[1]))
            @test sizeof(T) == parse(Int, words[2])
            @test [fieldoffset(T, i) for i in 1:fieldcount(T)] == parse.(Int, words[3:end])
        end
    end
end
