-- got it from here
-- credits to Ipda41001
-- http://twolivesleft.com/Codea/Talk/discussion/78/vec2-example
if dofile ~= nil then
	dofile ("loveCodify.lua")
end

function setup()
end

function draw()
    background(0, 0, 0, 0)
     stroke(212, 255, 0, 255)
     fill(255, 0, 0, 255)
    ellipse(0,0,50,50)
     fill(28, 48, 245, 255)
    ellipse(WIDTH,HEIGHT,50,50)
     stroke(211, 255, 0, 255)
     strokeWidth(5)
     noFill()
    line(1, 1, WIDTH, HEIGHT)
     stroke(123, 1, 155, 255)
    line(WIDTH, 1 , 1,HEIGHT)
     stroke(6, 252, 40, 255)
    line(1, 374, WIDTH-1, 374)
    ellipse(374, 374, 50, 50)
    sprite("SpaceCute:Planet", WIDTH/2, HEIGHT/2)
    
    ellipse(CurrentTouch.x, CurrentTouch.y, CurrentTouch.x+10, CurrentTouch.y+10)
end
