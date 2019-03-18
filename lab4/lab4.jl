using Gadfly
using DataFrames
using CSV
using DifferentialEquations

@ode_def LotkaVolterra begin
    dx = A*x - B*x*y
    dy = -C*y + D*x*y
end A B C D

# PUNKT 1
function SolveLotkaVolterra(A::Float64, B::Float64, C::Float64, D::Float64,
                                u::Float64, v::Float64, expNo::Int64)

    f = LotkaVolterra()

    p = [A,B,C,D]
    u0 = [u,v]
    tspan = (0.0, 30.0)
    prob = ODEProblem(f,u0,tspan,p)
    sol = solve(prob, RK4(), dt = 0.01)

    df1 = DataFrame(time = sol.t, prey = map(x -> x[1], sol.u),
                        predator = map(x -> x[2], sol.u), exp = expNo)

    filename = string("experiment",expNo,".csv")
    CSV.write(filename, df1)
end

# PUNKT 2
function makeSeriesLV()
    for i = 1:4
        A = 10*rand()
        B = 10*rand()
        C = 10*rand()
        D = 10*rand()
        u0 = 10*rand()
        u1 = 10*rand()
        SolveLotkaVolterra(A,B,C,D,u0,u1,i)
    end
end

# PUNKT 2 cd.
function analyzeExperiments(filename::String)

    df = DataFrame()
    for i = 1:4
        tmpdf = CSV.read(string("experiment",i,".csv"))
        print("Experiment ", i, ":\n",
                "\tPredator: mean = ", mean(tmpdf[:predator]),
                    " max = ", maximum(tmpdf[:predator]),
                    " min = ", minimum(tmpdf[:predator]), "\n",
                "\tPrey: mean = ", mean(tmpdf[:prey]),
                    " max = ", maximum(tmpdf[:prey]),
                    " min = ", minimum(tmpdf[:prey]), "\n\n")
        if i == 1
            df = tmpdf
        else
            df = vcat(df,tmpdf)
        end
    end

    df[:difference] = df[:predator] - df[:prey]

    CSV.write(filename, df)

end

# PUNKT 3
function drawSomePlots(filename::String)
    df = CSV.read(filename)

    p1 = plot(df, ygroup=:exp, Geom.subplot_grid(
            layer(x=:time, y=:predator, Theme(default_color="red"), Geom.line),
            layer(x=:time, y=:prey, Theme(default_color="deepskyblue"), Geom.line),
            layer(x=:time, y=:difference, Theme(default_color="green"), Geom.line),
            free_y_axis=true),
        Guide.title("Lotka Volterra Model"),
        Guide.xlabel("time [s]"), Guide.ylabel("fauna by experiment"),
        Guide.manual_color_key("Legend", ["Predator", "Prey", "Difference"],
        ["red", "deepskyblue", "green"]))

    draw(PNG("experiments.png",400,200), p1)

    layers = Vector{Gadfly.Layer}()
    colors = ["red", "blue", "yellow", "cyan"]
    for i in 1:4
        dfexp = df[df[:exp] .== i, :]   # grupowanie po eksperymencie
        usedColor = colors[i]
        push!(layers, layer(dfexp, x = "prey", y = "predator",
            Geom.line(preserve_order = true), Theme(default_color = usedColor))...)
    end
    p2 = plot(layers, Guide.YLabel("predator"), Guide.XLabel("prey"), Guide.Title("Fauna"),
        Guide.manual_color_key("Legend", ["exp1", "exp2", "exp3", "exp4"],
            [colors[1], colors[2], colors[3], colors[4]]))

    draw(PNG("phase-space plot.png",400,200), p2)

end

# WYWOŁANIA
filename = "allExperiments.csv"
makeSeriesLV()
analyzeExperiments(filename)
drawSomePlots(filename)
