dofile ("loveCodify.lua")

LONGLINE = math.pow(3,6)
-- Use this function to perform your initial setup
function setup()
    print(string.format("Hello World! %d %d", WIDTH, LONGLINE))
    iparameter("dimension",1,5)
end

-- This function gets called once every frame
function draw()
    background(176, 239, 18, 255)
    stroke(62, 50, 198, 255)
    strokeWidth(10)
    translate((WIDTH-LONGLINE)*0.5,HEIGHT*0.5)
    
    koch(dimension, LONGLINE)
end

function koch(level, len)
    if level == 0
    then
        line(0,0,len,0)
        translate(len,0)
    else
        koch(level-1,len/3)
        rotate(60)
        koch(level-1,len/3)
        rotate(-120)
        koch(level-1,len/3)
        rotate(60)
        koch(level-1,len/3)
    end
end
