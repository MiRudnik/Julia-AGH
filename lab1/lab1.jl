function primeSearch!(last)
    A = Array(Int,last)
    fill!(A,1)
    A[1] = 0
    for i = 2:last
        if A[i] != 0
            j = 2 * i
            while j <= last
                A[j] = 0
                j += i
            end
        end
    end
    println("Liczby pierwsze od 1 do ", last,": ")
    for i = 1:last
        if A[i] != 0
            println(i)
        end
    end
end
