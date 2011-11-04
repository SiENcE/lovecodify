
-- This class draws the lines streaming past in the background
-- of the game. We spawn and delete them in the self.lines table

----------------------------------------------
-- Single line
----------------------------------------------
StreamLine = class()
function StreamLine:init(pos, vel)
    self.position = pos
    self.velocity = vel
end

function StreamLine:update()
    self.position.y = self.position.y - self.velocity
end

function StreamLine:draw()
    p = self.position
    line(p.x,p.y,p.x,p.y + self.velocity)
end

function StreamLine:shouldCull()
    -- Check if off the bottom of the screen
    if (self.position.y + self.velocity) < 0 then
        return true
    end 

    return false
end

----------------------------------------------
-- All lines
----------------------------------------------
StreamingLines = class()

function StreamingLines:init()
    self.minSpeed = 5
    self.speed = 30
    self.spawnRate = 2
    self.lines = {}
end

function StreamingLines:updateAndCull()
    toCull = {}
    for i,v in ipairs(self.lines) do
        if v:shouldCull() then
            -- table.insert( toCull, i )
            table.remove( self.lines, i )
        else
            v:update()
        end
    end

    -- print("Removing ", #toCull)
    --for i = #toCull,1,-1 do
    --    table.remove( self.lines, i )
    --end
end

function StreamingLines:update()
    -- Create spawnRate lines per update
    for i = 1,self.spawnRate do
        -- Generate random spawn location
        vel = math.random(self.minSpeed, self.speed)
        spawn = vec2( math.random(WIDTH), HEIGHT + vel )

        table.insert(self.lines, StreamLine(spawn, vel))
    end

    -- Update and cull offscreen lines
    self:updateAndCull()
end

function StreamingLines:draw()
    --print("Num lines = ", #self.lines)

    pushStyle()

    noSmooth()
    stroke(179, 153, 180, 173)
    strokeWidth(2)
    lineCapMode(SQUARE)
 
    for i,v in ipairs(self.lines) do
        v:draw()
    end

    popStyle()
end
