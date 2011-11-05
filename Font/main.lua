dofile("loveCodify.lua")

dofile("Font/packedromans.lua")

-- Just a "Main" tab for Codea to demo the class

function setup()
   f=Font()
   frame=1
   sw=2
   iparameter("sw", 1, 20)
   sc=1
   parameter("sc", 1, 3)
   x=50
   iparameter("x", 0, WIDTH)
   y = HEIGHT / 2
   iparameter("y", 0, HEIGHT)
end

function draw()
   background(162, 166, 188, 255)
   stroke(0, 0, 0, 255)
   noSmooth()
   strokeWidth(sw)
   lineCapMode(ROUND)
   scale(sc)
   f:drawstring("Hershey Roman Simplex " .. frame, x, y)
   frame = frame + 1
end
