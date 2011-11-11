-- Bar class
-- LGPL Juan Belón Pérez
-- videojuegos.ser3d.es
-- 2011

Bar = class()
function Bar:init()
self.bgems = {}
self.time = 0
for i=1,maxGemsRow do
local gem = Gem((i*79)+32, 666, curGemColor,true)
gem.state = GEM_BAR
table.insert(self.bgems,gem)
end
end

function Bar:draw()
for k=1,maxGemsCol do
if board.gems[maxGemsRow][k].state == GEM_LIVE then
self.bgems[k].state = GEM_WAIT
self.bgems[k].y = 666
elseif self.bgems[k].state == GEM_WAIT then
self.bgems[k].state = GEM_FALL
elseif self.bgems[k].state == GEM_BAR then
local best = self:findNextTileDown(k)
self.bgems[k].state = GEM_REGEN
board.gems[best][k].state = GEM_LIVE
board.gems[best][k].time = 1
board.gems[best][k].gcolor= self.bgems[k].gcolor
board.gems[best][k].color = self.bgems[k].color
board.gems[best][k].tint = self.bgems[k].tint
--board.gems[best][k].x = self.bgems[k].x
--board.gems[best][k].y = self.bgems[k].y
board.gems[best][k].model = self.bgems[k].model
self.bgems[k].time = 1.6
elseif self.bgems[k].state == GEM_REGEN then
self.bgems[k].time = self.bgems[k].time - 0.3
if self.bgems[k].time <= 0 then
-- regen
local xy = vec2(self.bgems[k].x,self.bgems[k].y)
--self.bgems[k]:init(g.x,g.y,curGemColor,true)
self.bgems[k] = Gem(xy.x,xy.y,curGemColor,true)
self.bgems[k].state = GEM_FALL
end
elseif self.bgems[k].state == GEM_FALL then
self.bgems[k].y = self.bgems[k].y - math.random(11,33)
-- best tile
local best = board.gems[self:findNextTileDown(k)][k]
local bg  = self.bgems[k]
if bg.y < best.y then
-- end
self.bgems[k].y = best.y
self.bgems[k].yDown = best.y
self.bgems[k].state = GEM_BAR
end
end
end
 
for i,g in ipairs(self.bgems) do
g:draw()
end
end

function Bar:findNextTileDown(j)
local i = maxGemsRow
local b = maxGemsRow
local d = false
while i > 0 and not d do
if board.gems[i][j].state == GEM_DIE or board.gems[i][j].state == GEM_EXPLODE
then
if i<=b then
b = i
end
else -- cant go down,obstacle fall or live or born
d = true
--print("i:"..i..","..j)
 -- print(board.gems[i][j].state)
end
i = i - 1
end
return b
end

function Bar:touched(touch)
-- Codify does not automatically call this method
end
