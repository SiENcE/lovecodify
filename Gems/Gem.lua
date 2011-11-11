-- Gem class
-- LGPL Juan Belón Pérez
-- videojuegos.ser3d.es
-- 2011

Gem = class()
GEM_BAR  = 0
GEM_LIVE  = 1
GEM_DIE  = 2
GEM_EXPLODE= 3
GEM_FALL  = 4
GEM_BORN  = 5
GEM_WAIT  = 6
GEM_REGEN = 7
function Gem:init(x,y,seedGen,empty)
self.x = x
self.y = y
self.yo= 0 -- destiny y for falling animation
self.color = color(99,99,99,255)
self.tint = false
if empty then
self.state= GEM_DIE
else
self.state= GEM_LIVE
end
self.selected = false
local r = math.random(1, seedGen)
if r == 1 then
self.gcolor= "blue"
self.model = "Planet Cute:Gem Blue"
elseif r == 2 then
self.gcolor= "green"
self.model = "Planet Cute:Gem Green"
elseif r == 3 then
self.gcolor= "orange"
self.model = "Planet Cute:Gem Orange"
elseif r == 4 then
self.gcolor= "red"
self.model = "Planet Cute:Gem Orange"
self.color.r = 255
self.tint = true
elseif r == 5 then
self.gcolor= "pink"
self.model = "Planet Cute:Gem Orange"
self.color.r = 255
self.color.g = 0
self.color.b = 255
--tint(252, 0, 255, 255)
self.tint = true
elseif r == 6 then
self.gcolor= "purple"
self.model = "Planet Cute:Gem Blue"
self.color.r = 255
self.tint = true
elseif r == 7 then
self.gcolor= "yellow"
self.model = "Planet Cute:Gem Orange"
self.color.r = 237
self.color.g = 255
self.color.b = 0
self.tint = true
else
self.gcolor= "violet"
self.color.r = 255
self.color.g = 0
self.color.b = 255
self.tint = true
self.model = "Planet Cute:Gem Green"
end
self.explored = false -- flood fill flag
self.time = 0 -- anims
self.exploredSel = false -- selection check flood fill flag
end

function Gem:mirror(gem)
local aux = self.x
self.x = gem.x
gem.x = aux
aux  = self.y
self.y = gem.y
gem.y = aux
gem.selected = false
self.selected = false
end

function Gem:draw()
if self.state == GEM_DIE then return nil end
if self.state == GEM_EXPLODE then
sprite("Small World:Explosion", self.x,self.y,66,111)
elseif self.state == GEM_LIVE or self.state == GEM_FALL or self.state == GEM_WAIT
or self.state == GEM_REGEN
then
if self.state == GEM_REGEN then
sprite("Small World:Glow",self.x,self.y+33,66,333)
end
if self.selected then
sprite("Planet Cute:Selector", self.x,self.y,69,123)
end
if self.tint then
tint(self.color)
end
sprite(self.model, self.x,self.y,66,111)
noTint()
end
end

function Gem:touched(touch)
local xOk,yOk = false,false
local xL1 = 13
local xL2 = 16
local yL = 55
 
--print(touch.x,touch.y,self.x,self.y)
if touch.x == self.x then
xOk = true
else
if touch.x < self.x then
xOk = (self.x - touch.x) < xL1
else
xOk = (touch.x - self.x) < xL2
end
end
if touch.y == self.y then
yOk = true
elseif self.y>touch.y then
yOk = ( self.y - touch.y ) < yL
end
 -- if xOk and yOk then
 -- print(self.gcolor..","..self.color.r..","..self.color.g..","..self.color.b)
 -- print(self.tint)
 -- end
return xOk and yOk
end
