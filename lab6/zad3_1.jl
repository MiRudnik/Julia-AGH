using Plots
Plots.gr()

function generate_julia(z; c=2, maxiter=200)
    for i=1:maxiter
        if abs(z) > 2
            return i-1
        end
        z = z^2 + c
    end
    maxiter
end

function calc_julia!(julia_set, xrange, yrange; maxiter=200, height=400, width_start=1, width_end=400)
   for x=width_start:width_end
        for y=1:height
            z = xrange[x] + 1im*yrange[y]
            julia_set[x, y] = generate_julia(z, c=-0.70176-0.3842im, maxiter=maxiter)
        end
    end
end


function calc_julia_main(h,w,threads)
   xmin, xmax = -2,2
   ymin, ymax = -1,1
   xrange = linspace(xmin, xmax, w)
   yrange = linspace(ymin, ymax, h)
   julia_set = SharedArray{Float64}(w, h)
   @sync @parallel for i = 0:(threads-1)
       w_start = trunc(Int,floor(1+((i/threads)*(w-1))))
       w_end = trunc(Int,floor(1+(((i+1)/threads)*(w-1))))
       println("Thread ",i,": from ",w_start," to ",w_end)
       calc_julia!(julia_set, xrange, yrange, height=h, width_start=w_start, width_end=w_end)
   end
   Plots.heatmap(xrange, yrange, julia_set)
   png("julia")
end


calc_julia_main(2000,2000,4)
