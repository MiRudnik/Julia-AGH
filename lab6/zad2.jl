# zmienne ze sciezka, ew. rozszerzeniem i iloscia konsumentow
path="C:\\Users\\micha\\Python\\mrudnik"
extension="py"
consuments=5


function producer(c::Channel)
        for (root, dirs, files) in walkdir(path)
        for file in files
            if(extension!="")
                # sprawdzanie rozszerzenia
                parsed = split(file, ".")
                if(parsed[end] != extension)
                    continue
                end
            end
            put!(c,joinpath(root, file))
            yield()
        end

    end
      close(c)
end

function consument(c::Channel)
    linesum=0
    for file in c
        println("Znaleziony plik: ", file)
        linesum+=countlines(file)
        yield()
    end
    return linesum
end


@sync begin
    c=Channel{String}(50)
    sums=SharedArray{Int64}(consuments)
    @async producer(c)
    @sync for i=1:consuments
        @async sums[i] = consument(c)
    end
    println("\nSuma linii w plikach: ", sum(sums))
end

#= WYWOLANIE
D:\Studia\4sem\Julia\lab6>julia zad2.jl
Znaleziony plik: C:\Users\micha\Python\mrudnik\coursesSite\manage.py
Znaleziony plik: C:\Users\micha\Python\mrudnik\coursesSite\courses\admin.py
Znaleziony plik: C:\Users\micha\Python\mrudnik\coursesSite\courses\models.py
Znaleziony plik: C:\Users\micha\Python\mrudnik\coursesSite\courses\apps.py
Znaleziony plik: C:\Users\micha\Python\mrudnik\coursesSite\courses\forms.py
Znaleziony plik: C:\Users\micha\Python\mrudnik\coursesSite\courses\tests.py
Znaleziony plik: C:\Users\micha\Python\mrudnik\coursesSite\courses\urls.py
Znaleziony plik: C:\Users\micha\Python\mrudnik\coursesSite\courses\validators.py
Znaleziony plik: C:\Users\micha\Python\mrudnik\coursesSite\courses\views.py
Znaleziony plik: C:\Users\micha\Python\mrudnik\coursesSite\courses\__init__.py
Znaleziony plik: C:\Users\micha\Python\mrudnik\coursesSite\courses\migrations\0001_initial.py
Znaleziony plik: C:\Users\micha\Python\mrudnik\coursesSite\courses\migrations\0002_auto_20180612_1327.py
Znaleziony plik: C:\Users\micha\Python\mrudnik\coursesSite\courses\migrations\0003_auto_20180612_1341.py
Znaleziony plik: C:\Users\micha\Python\mrudnik\coursesSite\courses\migrations\0004_auto_20180613_1256.py
Znaleziony plik: C:\Users\micha\Python\mrudnik\coursesSite\courses\migrations\0005_auto_20180613_1741.py
Znaleziony plik: C:\Users\micha\Python\mrudnik\coursesSite\courses\migrations\0006_auto_20180613_1757.py
Znaleziony plik: C:\Users\micha\Python\mrudnik\coursesSite\courses\migrations\__init__.py
Znaleziony plik: C:\Users\micha\Python\mrudnik\coursesSite\coursesSite\settings.py
Znaleziony plik: C:\Users\micha\Python\mrudnik\coursesSite\coursesSite\urls.py
Znaleziony plik: C:\Users\micha\Python\mrudnik\coursesSite\coursesSite\views.py
Znaleziony plik: C:\Users\micha\Python\mrudnik\coursesSite\coursesSite\wsgi.py
Znaleziony plik: C:\Users\micha\Python\mrudnik\coursesSite\coursesSite\__init__.py
Znaleziony plik: C:\Users\micha\Python\mrudnik\hangman\hangman.py
Znaleziony plik: C:\Users\micha\Python\mrudnik\Plots_n_data\gun_violence.py
Znaleziony plik: C:\Users\micha\Python\mrudnik\Plots_n_data\plotDrawer.py
Znaleziony plik: C:\Users\micha\Python\mrudnik\Plots_n_data\weather.py
Znaleziony plik: C:\Users\micha\Python\mrudnik\Plots_n_data\__init__.py
Znaleziony plik: C:\Users\micha\Python\mrudnik\Plots_n_data\Tests\testWeather.py

Suma linii w plikach: 943
=#
