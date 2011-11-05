dofile ("loveCodify.lua")


Animal = class()

function Animal:init()
    -- you can accept and set parameters here
    self.position = vec2(0,0)
    self.velocity = vec2(0,0)
    self.model = "Planet Cute:Enemy Bug"
    self.score = 0
end


function Animal:jump(power)
    sound(SOUND_JUMP)
    self.velocity = self.velocity + vec2(0.1*power, power/2)
    --clamp speed
    self.velocity.x = math.min( self.velocity.x ,7)
    self.velocity.y = math.min( self.velocity.y ,43)
end

function Animal:computeVelocity()
    gravity = vec2(math.max(Gravity.x,0), math.min(Gravity.x,-1)):normalize()
    gravity = gravity * 15
    friction = math.min(self.position.y, 1)
    return self.velocity + gravity * friction
end

function Animal:isJumping()
    return math.max(self.position.y, 0) > 0
end

function Animal:update()
    self.position = self.position + self:computeVelocity()
    
    -- Clamp y position
    -- (so you don't go through ground)
    self.position.y = math.max(self.position.y,0)
    -- Dampen velocity
    self.velocity = self.velocity * 0.98
end

function Animal:isFalling()
    return self:computeVelocity().y < 0
end

function Animal:draw()
    self:update()
    pushMatrix()
    translate(self.position.x, self.position.y) 
    sprite(self.model, 0, 0)
    popMatrix()
end



--------------------

Cloud = class()

function Cloud:init()
    -- you can accept and set parameters here
    self.shapes = {}
    self.position = vec2(0,0)
    
    -- Generate random cloud
    numCircles = math.random(4, 5)
    spacing = 30
    
    for i = 1,numCircles do
        x = i * spacing - ((numCircles/2)*spacing)
        y = (math.random() - 0.5) * 30
        rad = math.random(spacing, 2*spacing)     
        table.insert(self.shapes, {x=x, y=y, r=rad})
    end
    
    self.width = numCircles * spacing + spacing
end

function Cloud:isColliding(pos)
    startp = self.position.x - self.width/2
    endp = self.position.x + self.width/2
    
    if pos.x < endp and pos.x > startp and
       pos.y < (self.position.y + 30) and
       pos.y > (self.position.y + 10) then
        return true
    end
    
    return false
end

function Cloud:draw()
    pushStyle()
    pushMatrix()
    
    translate(self.position.x, self.position.y)
    
    noStroke()
    ellipseMode(RADIUS)
    fill(167, 190, 221, 255)
    
    for i,s in ipairs(self.shapes) do
        ellipse(s.x, s.y - 5, s.r)
    end
    
    fill(255, 255, 255, 255)
    
    for i,s in ipairs(self.shapes) do
        ellipse(s.x, s.y + 5, s.r)
    end
    
    popMatrix()
    popStyle()
end


-------------------

Explosion = class()

function Explosion:init(_position, power,r,g,b)
    -- you can accept and set parameters here
    self.duration = 0.6
    self.currentTime = 0
    self.endTime = self.currentTime + self.duration
    self.size = math.random(6,123)
    self.blastSize = self.size + power*6
    self.currentSize = self.size
    self.position = _position
    self.R = r
    self.G = g
    self.B = b
end

function Explosion:isDone()
    return self.currentTime > self.endTime*2
end

function Explosion:draw()
    self.currentTime = self.currentTime + 1/30
    
    -- Time in the attack, 0 to 1
    glowTime = (self.currentTime)/self.duration

    pushStyle()
    
    noFill()
    stroke(self.R, self.G, self.B, 255*(1-glowTime))
    strokeWidth(10*(1-glowTime))
    
    self.currentSize = self.blastSize * glowTime + (self.size * (1-glowTime))
    p = self.position
    ellipse(p.x, p.y, self.currentSize)
    
    popStyle()
end


-------------------------------


FloorBrick = class()

function FloorBrick:init(type,x,y)
    if type == 1 then
        self.model = "Planet Cute:Stone Block"
    elseif type == 2 then
        self.model = "Planet Cute:Wall Block"
    elseif type == 3 then
        self.model = "Planet Cute:Wood Block"
    else
        self.model = "Planet Cute:Grass Block"
    end
    self.x = x
    self.y = y
end

function FloorBrick:draw()
    sprite(self.model, self.x, self.y)
end

function FloorBrick:touched(touch)
    -- Codify does not automatically call this method
end



----------------------------------

Gem = class()

function Gem:init()
    r = math.random(1,3)
    if r == 1 then
        self.model = "Planet Cute:Gem Blue"
        self.color = "blue"
        self.points= 32
    elseif r == 2 then 
        self.model = "Planet Cute:Gem Green"
        self.color = "green"
        self.points= 13
    else
        self.model = "Planet Cute:Gem Orange"
        self.color = "red"
        self.points= 6
    end
end

function Gem:draw()
    pushMatrix()
    translate(self.position.x, self.position.y)
    sprite(self.model, 0,0, 50, 80 )
    popMatrix()
end

function Gem:touched(touch)
    -- Codify does not automatically call this method
end


--------------------------------------------------------


GroundLevels = class()

CULLPADDING = 79 --distance from where delete elements

function GroundLevels:init()
    -- init all elements
    self.floorbricks  = {}
    self.vegetations  = {}
    self.clouds       = {}
    self.gems         = {}
    self.explosions   = {}
    self.nextCloudWidth       = 0
    self.nextGemWidth         = 0
    self.nextFloorBrickWidth  = -WIDTH/2 -70 + 101
    self.nextVegetationWidth  = 0
    self.nextVegetationHeight = 0
    self.floorType   = 0
    self.floorbrickcount = math.random(23,66)
end

function GroundLevels:generateNextFloorBrick()
    floorbrick = FloorBrick(self.floorType, self.nextFloorBrickWidth, -66)
    table.insert(self.floorbricks, floorbrick)
    self.nextFloorBrickWidth = self.nextFloorBrickWidth + 101
    self.floorbrickcount = self.floorbrickcount - 1
    if self.floorbrickcount == 0 then
        self.floorbrickcount = math.random(23,66)
        self.floorType = math.random(1,4)
    end
end
function GroundLevels:generateNextVegetation()
    vegetation = Vegetation()
    vegetation.position = vec2(self.nextVegetationWidth,
                          self.nextVegetationHeight)
    
    table.insert(self.vegetations, vegetation)
    
    self.nextVegetationWidth = self.nextVegetationWidth + math.random(48,150)
end


function GroundLevels:generateNextCloud()
    cloud = Cloud()
    cloud.position = vec2(self.nextCloudWidth,
                         math.random(101, 666))
    
    table.insert(self.clouds, cloud)
    
    self.nextCloudWidth= self.nextCloudWidth + math.random(60,160)
end

function GroundLevels:generateNextGem()
    gem = Gem()
    gem.position = vec2(self.nextGemWidth,
                          math.random(33, 666))
    
    table.insert(self.gems, gem)
    
    self.nextGemWidth= self.nextGemWidth + math.random(66,333)
end

function GroundLevels:cullElements(wall)
    for i,v in ipairs(self.floorbricks) do
        if v.x < wall then
            table.remove(self.floorbricks,i)
        end
    end
    for i,v in ipairs(self.vegetations) do
        if v.position.x < wall then
            table.remove(self.vegetations,i)
        end
    end
    for i,v in ipairs(self.clouds) do
        if v.position.x < wall then
            table.remove(self.clouds,i)
        end
    end  
    for i,v in ipairs(self.gems) do
        if v.position.x < wall then
            table.remove(self.gems, i)
        end
    end
    for i,v in ipairs(self.explosions) do
        if v:isDone() then
            table.remove(self.explosions,i)
        end
    end
end


function GroundLevels:isAnimalCollidingWithGems()
    local x = animal.position.x
    local y = animal.position.y
    -- iterate gems
    for i,g in ipairs(self.gems) do
        -- check distance between two points (Manhattan style)
        local dx = math.abs(g.position.x - x)
        local dy = math.abs(g.position.y - y)
       -- print(x,y,gx,gy)
        if dx<66 and dy<66 and dy>16 then
            -- hit explosion
            local R,G,B = 255,0,0 -- red default
            if g.color == "blue" then
                B = 255
            elseif g.color == "green" then
                G = 255
            end
            explosion = Explosion(g.position, g.points*6,R,G,B)
            table.insert(self.explosions,explosion)
            animal.score = animal.score + g.points
            table.remove(self.gems,i)
            print("Score:", animal.score)
            sound(SOUND_PICKUP)            
        end
    end

end

function GroundLevels:update(cam)
    curWidth = -cam.x + WIDTH + CULLPADDING
  --  print (curWidth)
    self:cullElements(-cam.x - CULLPADDING)
    -- floor:
    if table.maxn(self.floorbricks)<9 then
        self:generateNextFloorBrick()
    elseif table.maxn(self.floorbricks)>9 then
        table.remove(0)
    end
    if math.fmod(math.random(1,666),2)==0 and curWidth > self.nextVegetationWidth then
        self:generateNextVegetation()
    end
    -- clouds
    if math.fmod(math.random(1,666),2)==0 and curWidth>self.nextCloudWidth then
        self:generateNextCloud()
    end
    -- gems:
    if math.fmod(math.random(1,666), 2)==0 and curWidth>self.nextGemWidth then
        self:generateNextGem()
    end
    -- collisions
    self:isAnimalCollidingWithGems()
end

function GroundLevels:draw()
    for i,v in ipairs(self.floorbricks) do
        v:draw()
    end
    for i,v in ipairs(self.vegetations) do
        v:draw()
    end
    for i,v in ipairs(self.clouds) do
        v:draw()
    end
    for i,v in ipairs(self.gems) do
        v:draw()
    end
    for i,v in ipairs(self.explosions) do
        v:draw()
    end
end


function GroundLevels:touched(touch)
    -- Codify does not automatically call this method
end


----------------------------------------




-- Use this function to perform your initial setup
function setup()
    print("TAP to JUMP")
    print("Tilt your device to move the animal!")
    print("Press RESET to restart the level")
    
    grounds = GroundLevels()
    
    animal = Animal()
    animal.position = vec2(0, 0)
    
end

-- This function gets called once every frame
function draw()
    background(47, 145, 216, 255)
    
    -- Center the camera on the animal character
    camPos = vec2(WIDTH/2 - animal.position.x, 
                  math.min(HEIGHT/2 - animal.position.y, 140))
    translate(camPos.x,camPos.y)
    
    grounds:update(camPos)
    --scene: floor bricks, clouds, gems,explosions
    grounds:draw()
    -- animal char
    animal:draw()
end

function touched(touch)
    pos = vec2(0,0)
    if touch.tapCount == 1 and not animal:isJumping() then
        animal:jump(6)
    end
end

-------------------------------------------------------------

Vegetation = class()

function Vegetation:init()
    -- you can accept and set parameters here
    r = math.random(1,6)
    if r == 1 then
        self.model = "Planet Cute:Tree Tall"
    elseif r==2 then
        self.model = "Small World:Tree Round Flower"
    elseif r==3 then
        self.model = "Small World:Tree 3"
    elseif r==4 then
        self.model = "Small World:Tree Ugly"
    elseif r==5 then
        self.model = "Small World:Tree Apple"
    else
        self.model = "Planet Cute:Tree Short"
      --  sprite("Planet Cute:Tree Tall")
    end
        
end


function Vegetation:draw()
    pushMatrix()
    translate(self.position.x, self.position.y)
    sprite(self.model)
    popMatrix()
end
