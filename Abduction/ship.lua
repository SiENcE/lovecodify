
Ship = class()

function Ship:init(x,y)
    -- you can accept and set parameters here
    self.x = x
    self.y = y
    self.isFiring = false
end

function Ship:draw()
    if self.isFiring then
        pushMatrix()
        rotate(180)
        sprite("Small World:Beam", -self.x-5, -self.y+109)
        popMatrix()
    end
    sprite("Small World:Base Large",self.x,self.y)
end


