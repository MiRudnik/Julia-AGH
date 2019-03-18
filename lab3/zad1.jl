import Base.Random

function fun1()
    for i = 1:100000
        str = randstring(10)
    end
end

function fun2()
    for i = 1:10000
        str = randstring(10)
    end
end

function runFunctions()
    for i = 1:500
        fun1()
        fun2()
    end
end

Profile.clear()
@profile runFunctions()
Profile.print(format=:flat)
using ProfileView
ProfileView.view()
