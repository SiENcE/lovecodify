-- got it from here
-- credits to Ipda41001
-- http://twolivesleft.com/Codify/Talk/discussion/23/day-night-background-colorizer-with-speed-parm
-- http://pastebin.com/B0FtrE1f
dofile ("loveCodify.lua")

--day/night background colorizer with speed parm

-- Use this function to perform your initial setup
function setup()
    print("Hello World!")
    background(0, 0, 0, 0)
    Sun = 0
    Track = 0
    Rise = 1
    Day = 2
    Set = 3
    Night = 4
    Time = Rise
    parameter("DaySpeed",0.00,1.00,1)
end

-- This function gets called once every frame
function draw()
    if Time == Rise then
        if Sun < 255 then
            Sun = Sun + DaySpeed
        else
            Time = Day
            Track = 0
        end
    elseif Time == Day or Time == Night then
        if Track < 255 then
            Track = Track + DaySpeed
        else
            if Time == Day then
                Time = Set
            else
                Time = Rise
            end
        end
    elseif Time == Set then
        if Sun > 0 then
            Sun = Sun - DaySpeed
        else
            Time = Night
            Track = 0
        end
    end
    background(Sun,Sun, 0, 0)
end
