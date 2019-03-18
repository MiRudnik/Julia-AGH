import Base.*
import Base.convert
import Base.promote_rule

struct Gn{N} <: Integer
    val :: Int
    function Gn{N}(x::Int) where N
        if N < 2
            throw(DomainError())
        else
            x = x % N
            # operator '%' zwraca liczbe o tym samym znaku, wiec nie przeszkadza w porównaniu pozniej
            if gcd(x,N) == 1 && x > 0
                new(x)
            else
                throw(DomainError())
            end
        end
    end
end

function *(x::Gn{N}, y::Gn{N}) where N
    Gn{N}((x.val * y.val) % N)
end

function *(x::Gn{N}, y::T) where {N, T <: Integer}
    Gn{N}((x.val * y) % N)
end

function *(x::T, y::Gn{N}) where {N, T <: Integer}
    Gn{N}((x * y.val) % N)
end

convert(::Type{Int64}, x::Gn{N}) where N = x.val

convert(::Type{Gn{N}}, x::Int64) where N = Gn{N}(x)

promote_rule(::Type{Gn{N}}, ::Type{T}) where {N, T <: Integer} = T

# zakladam ze funkcja dziala dla liczb nieujemnych skoro ma korzystac z poprzedniej funkcji
function to_power(a::Gn{N}, x::T) where {N, T <: Integer}
    if x < 0
        throw(DomainError())
    elseif x == 0
        return Gn{N}(1)
    else
        b = a.val
        for i = 1:(x-1)
            a = a * b
        end
        a
    end
end

function interval(x::Gn{N}) where N
    r = 1
    if x.val == 1
        return r
    end
    e = count_elements(typeof(x))
    for r = 2:e
        if e % r == 0   # r dzieli ilosc elementow
            if to_power(x,r).val == 1
                return r
            end
        end
    end
end

function inverse(a::Gn{N}) where N
    for i = 1:(N-1)
        if gcd(N,i) == 1
            b = Gn{N}(i)
            if a * b == 1
                return b
            end
        end
    end
end

function count_elements(::Type{Gn{N}}) where N
    if N < 2
        throw(DomainError())
    end
    s = 1   # 1 jest zawsze
    for i = 2:(N-1)
        if gcd(i,N) == 1
            s += 1
        end
    end
    s
end

function test_RSA()
    N = 55
    c = 17
    b = 4
    r = interval(Gn{N}(4))
    println("r = ",r)
    d = inverse(Gn{r}(c))
    println("d = ",d)
    a = to_power(Gn{N}(b),d.val)
    println("a = ",a.val)
    if  b == to_power(a,c)
        println("Wiadomosc b byla zakodowana kluczem ($N,$c).")
    else
        println("Wiadomosc b nie byla zakodowana kluczem ($N,$c).")
    end
end
