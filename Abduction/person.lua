
Person = class()
-- Person states
PERSON_KILL =-1
PERSON_BORN = 0
PERSON_SHIP = 1
PERSON_LEVI = 2
PERSON_LOST = 3
PERSON_SAFE = 4
PERSON_FALL = 5
PERSON_BYE  = 6
function Person:init(x,y,angle)
    -- you can accept and set parameters here
    self.x = x
    self.y = y
    self.angle = angle
    local r= math.random(1,5)
    if r == 1 then
        self.model = "Planet Cute:Character Boy"
        self.points= 3
    elseif r == 2 then
        self.model = "Planet Cute:Character Cat Girl"
        self.points= 3
    elseif r == 3 then
        self.model = "Planet Cute:Character Horn Girl"
        self.points= 6
    elseif r == 4 then
        self.model = "Planet Cute:Character Pink Girl"
        self.points= 5
    else
        self.model = "Planet Cute:Character Princess Girl"
        self.points= 12
    end
    self.state = PERSON_BORN -- in asteroid, lost,waiting for the ship
    self.timeToGo = 2.3
    self.shipId = nil
end

function Person:draw()
    pushMatrix()
    --translate(0,0)
    translate(self.x,self.y)
    rotate(self.angle)
    if self.state == PERSON_BYE then
        sprite("Small World:Glow")
    elseif self.state == PERSON_BORN then
        sprite("Small World:Explosion")
    elseif self.state == PERSON_KILL then
        sprite("Small World:Bunny Skull")
    else
        sprite(self.model,0,0)
    end
    popMatrix()
end

function Person:touched(touch)
    -- Codify does not automatically call this method
end


