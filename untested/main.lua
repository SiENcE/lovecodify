dofile ("loveCodify.lua")

-- This demo shows you how to use CurrentTouch for simple interaction
-- CurrentTouch is a global updated with a single touch position
-- Usage:
--  CurrentTouch.x
--  CurrentTouch.y
--  CurrentTouch.prevX
--  CurrentTouch.prevY
--  CurrentTouch.deltaX
--  CurrentTouch.deltaY
--  CurrentTouch.id
--  CurrentTouch.state = BEGAN | MOVING | ENDED
--  CurrentTouch.tapCount

function setup()
    print("Touch and drag on the screen")
end

function draw()
    noSmooth()
    
    fill(0, 0, 0, 50)
    rect(0,0,WIDTH,HEIGHT)

    noStroke()

    if CurrentTouch.state == BEGAN then
        fill(16, 178, 197, 255)
    elseif CurrentTouch.state == MOVING then
        fill(255, 0, 0, 255)
    elseif CurrentTouch.state == ENDED then
        fill(210, 218, 16, 255)
    end

    ellipse(CurrentTouch.x, CurrentTouch.y, 100,100)
end

