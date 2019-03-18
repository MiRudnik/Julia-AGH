last = 0 # do zapewnienia kolejnosci 1 > 2 > 3

function task(n::Int64)
    while((last)%3 + 1 != n) # zaczynamy od task(1)
        yield()
    end
    for i=1:5
        println(n)
        global last = n
        yield()
    end
end

@sync begin

    @async task(3)
    @async task(2)
    @async task(1)
end
