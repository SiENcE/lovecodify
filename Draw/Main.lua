-- got it from here
-- credits to brab
-- http://twolivesleft.com/Codea/Talk/discussion/85/minimalist-drawing-program

dofile ("loveCodify.lua")
dofile ("Draw/Touch.lua")

tt = nil

last_touch = nil
touch = nil
moving = false

-- Use this function to perform your initial setup
function setup()
    tt = Touches()
end

-- This function gets called once every frame
function draw()
    background(0, 0, 0, 0)
    
    stroke(255)
    -- default seems to be 0
    strokeWidth(8)
    lineCapMode(ROUND)
    
    touch = vec2(CurrentTouch.x, CurrentTouch.y)
    if CurrentTouch.state == ENDED then
        -- to make sure we don't miss the touch began state
        moving = false
    elseif CurrentTouch.state == BEGAN then
        if touch ~= last_touch then
            moving = true
            last_touch = touch
            tt:add(touch)
        end
    elseif CurrentTouch.state == MOVING then
        if touch ~= last_touch then
            if moving then
                tt:expand(touch)
            else
                -- Did not detect the move
                moving = true
                tt:add(touch)
            end
            last_touch = touch
        end       
    end 
    
    tt:draw()
end
