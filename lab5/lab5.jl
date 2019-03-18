# ZAD 1

@generated function gen_harmonic_mean{T,N}(args :: Vararg{T,N})
    n = :(0)
    ex = foldl((acc, i) -> :($acc + (1/args[$i])), n, 1:N)
    return :(N/$ex)
end

# TEST
println("gen_harmonic_mean(2,3,4) = ", gen_harmonic_mean(2,3,4))
println("gen_harmonic_mean(3.0,3.0,3.0) = ", gen_harmonic_mean(3.0,3.0,3.0))

#ZAD 2

# n / dx
autodiff(n :: Number) = 0

# x / dx
autodiff(x :: Symbol) = 1

# (f(x) + g(x)) / dx
function autodiff( :: Type{Val{:+}}, args...) :: Expr
    # (+) może przyjmować więcej niż 2 argumenty
    Expr(:call, :+, map(x -> autodiff(x), args)...)
end

# (f(x) - g(x)) / dx
function autodiff( :: Type{Val{:-}}, ex1, ex2) :: Expr
    Expr(:call, :-, autodiff(ex1), autodiff(ex2))
end

# (f(x) * g(x)) / dx
function autodiff( :: Type{Val{:*}}, args...) :: Expr
    # (*) może przyjmować więcej niż 2 argumenty
    f =  args[1]
    if length(args) == 2
        g = args[2]
    else
        g = Expr(:call, :*, args[2:end]...)
    end
    Expr(:call, :+,
        Expr(:call, :*, autodiff(f), g),
        Expr(:call, :*, autodiff(g), f))
end

# f(x) ^ n / dx dla n > 0
# n <= 0, (f(x) ^ g(x)) /dx  itd nie rozpatruję
function autodiff( :: Type{Val{:^}}, ex1, ex2) :: Expr
        autodiff(Expr(:call, :*, fill(ex1,ex2)...))
end

# (f(x) / g(x)) / dx
function autodiff( :: Type{Val{:/}}, ex1, ex2) :: Expr
    Expr(:call, :/,
        Expr(:call, :-,
            Expr(:call, :*, autodiff(ex1), ex2),
            Expr(:call, :*, autodiff(ex2), ex1)),
        Expr(:call, :^, ex2, 2))
end

# START
function autodiff(ex :: Expr) :: Expr
    autodiff(Val{ex.args[1]}, ex.args[2:end]...)
end

# TEST

println()
a1 = :(x + x*x*x)
a2 = autodiff(a1)
println(a2, " = 1 + 3*x*x")

b1 = :(x+x+x+x)
b2 = autodiff(b1)
println(b2, " = 4")

c1 = :(4)
c2 = autodiff(c1)
println(c2, " = 0")

# to powinno sprawdzać wszystkie wywołania
d1 = :(x*x*x + 7*x/x^2 + x*x - x + 5)
d2 = autodiff(d1)
println(d2)
# przeliczałem na kartce i wyszło to samo :D
