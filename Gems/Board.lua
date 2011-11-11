-- Board class
-- LGPL Juan Belón Pérez
-- videojuegos.ser3d.es
-- 2011

Board = class()
function Board:init()
self.gems = {}
self.texts = {}
self.sel1 = nil
self.sel2 = nil
self.gemsEx= {}
-- board init:
for k=1,maxGemsRow do
self.gems[k] = {}
for i=1,maxGemsCol do
local gem = Gem((i*79)+33, 55+(70*k), curGemColor,(k>3))
--table.insert(self.gems, gem)
self.gems[k][i] = gem
end
end
end

-- O(n^2)
function Board:update()
-- set level
if gemsCleared > currentLvl*33 and gemsCleared<currentLvl*66 then
currentLvl = currentLvl + 1
if currentLvl > 5 and currentLvl < 12 then
curGemColor = 5
elseif currentLvl > 11 and currentLvl < 18 then
curGemColor = 6
elseif currentLvl > 17 and currentLvl < 23 then
curGemColor = 7
elseif currentLvl > 23 then
curGemColor = 8
end
end
self:checkSolutions()
for i=1 , maxGemsRow do
for j=1, maxGemsCol do
if self.gems[i][j].state == GEM_EXPLODE then
self.gems[i][j].time = self.gems[i][j].time - 0.23
 -- print(self.gems[i][j].time)
if self.gems[i][j].time<=0 then
self.gems[i][j].state = GEM_DIE
end
elseif self.gems[i][j].state == GEM_LIVE
--or self.gems[i][j].state == GEM_BORN
then
if (i>1 and (
self.gems[i-1][j].state == GEM_DIE or
self.gems[i-1][j].state == GEM_EXPLODE
))
then
self.gems[i][j].state = GEM_FALL
self.gems[i][j].time = 13
if not (self:nextGemDown(i,j,self.gems[i][j])) then
self.gems[i][j].state = GEM_LIVE
end
else
self.gems[i][j].state = GEM_LIVE
end
elseif self.gems[i][j].state == GEM_FALL then
self.gems[i][j].time = self.gems[i][j].time - 0.1
self.gems[i][j].y = self.gems[i][j].y - 2.3
if self.gems[i][j].y <= self.gems[i][j].yDown or self.gems[i][j].time <=0 then
self.gems[i][j].y = self.gems[i][j].yDown
self.gems[i][j].state = GEM_LIVE
end
end
end
end
--self:stopAnimations()
end

-- O(n)
function Board:nextGemDown(i,j,gem)
local k =i - 1
local b =i -- best tile
while k > 0 do
if self.gems[k][j].state == GEM_DIE or self.gems[k][j].state == GEM_EXPLODE then
if k<b then
b = k
end
else -- cant go down,obstacle fall or live or born
break
end
k = k - 1
end
if b<i then
local y = self.gems[b][j].y
self.gems[b][j]:mirror(gem)
gem.yDown = gem.y
gem.y = y
self.gems[i][j] = self.gems[b][j]
self.gems[b][j] = gem
return true
end
return false
end
-- dont use
function Board:stopAnimations()
for i=1,maxGemsRow do
for j=1, maxGemsCol do
if self.gems[i][j].state == GEM_EXPLODE then
self.gems[i][j].state = GEM_DIE
elseif self.gems[i][j].state == GEM_FALL then
self.gems[i][j].y = self.gems[i][j].yDown
self.gems[i][j].state = GEM_LIVE
end
end
end
end

function Board:draw()
self:update()
-- some cool random backgrounds here :)
-- box background
pushMatrix()
translate(341,233)
rotate(180)
sprite("Planet Cute:Wood Block",0,0,630,881)
popMatrix()
-- lines
fill(204, 134, 70, 255)
stroke(204, 134, 70, 255)
strokeWidth(32)
smooth()
lineCapMode(0)
-- right line
line(666,70,666,669)
-- bottom line
--line(55,77,669,77)
fill(204, 134, 70, 121)
stroke(204, 134, 70, 121)
-- bar line (is part of the board)
line(55,600,666,600)
-- left line
line(60,77,60,666)
-- top line
 -- line(55,669,666,669)
-- floor
for i=0, 7 do
sprite("Planet Cute:Brown Block",(79*i)+77,44,101,87)
end
-- board gems
local i,j
for i=1, maxGemsRow do
for j=1,maxGemsCol do
(self.gems[i][j]):draw()
end
end
noSmooth()
stroke(255, 255, 255, 255)
strokeWidth(2)
 
for i,t in ipairs(self.texts) do
if t.time<=0 then
table.remove(self.texts,i)
else
t:draw()
end
end
end

function Board:isVequal(v1,v2)
if v1==nil and v2 == nil then
return true
elseif v1==nil or v2 == nil then
return false
end
return v1[0]==v2[0] and v2[1]==v1[1]
end

function Board:floodFillSelection(i,j,gcolor,count,start)
if not (start) then
if self.gems[i][j].exploredSel then -- done case
return 0
end
 
if self.gems[i][j].gcolor==gcolor and not (self.gems[i][j].exploredSel) and
 self.gems[i][j].state==GEM_LIVE then
-- single match base case
 count = count + 1
end
end
-- selection flag flood fill
self.gems[i][j].exploredSel = true
if self.gems[i][j].state==GEM_DIE then -- empty case
return 0
end

-- adyacent cells
-- up
if i<maxGemsRow and not (self.gems[i+1][j].exploredSel) and
self.gems[i+1][j].gcolor==gcolor
then
count = count + self:floodFillSelection(i+1,j,gcolor,count,false)
end
 
-- left
if j>1 and not (self.gems[i][j-1].exploredSel) and self.gems[i][j-1].gcolor==gcolor then
count = count + self:floodFillSelection(i,j-1,gcolor,count,false)
end
 
-- right
if j<maxGemsCol and not (self.gems[i][j+1].exploredSel) and
self.gems[i][j+1].gcolor==gcolor
then
count = count + self:floodFillSelection(i,j+1,gcolor,count,false)
end
 
-- down
if i>1 and not (self.gems[i-1][j].exploredSel) and
self.gems[i-1][j].gcolor==gcolor
then
count = count + self:floodFillSelection(i-1,j,gcolor,count,false)
end
return count
end

--O(log(n))
function Board:floodFill(i,j,gcolor)
if self.gems[i][j].explored then -- done case
return 0
end
 
if self.gems[i][j].gcolor==gcolor and not (self.gems[i][j].explored) and
 self.gems[i][j].state==GEM_LIVE then
-- single match base case
 local index = {}
 index[0] = i
 index[1] = j
 table.insert(self.gemsEx,index)  
else
return
end
-- flag flood fill
self.gems[i][j].explored = true
if self.gems[i][j].state==GEM_DIE then -- empty case
return
end

-- adyacent cells
-- up
if i<maxGemsRow and not (self.gems[i+1][j].explored) and self.gems[i+1][j].gcolor==gcolor then
self:floodFill(i+1,j,gcolor)
end
 
-- left
if j>1 and not (self.gems[i][j-1].explored) and self.gems[i][j-1].gcolor==gcolor then
self:floodFill(i,j-1,gcolor)
end
 
-- right
if j<maxGemsCol and not (self.gems[i][j+1].explored) and self.gems[i][j+1].gcolor==gcolor then
self:floodFill(i,j+1,gcolor)
end
 
-- down
if i>1 and not (self.gems[i-1][j].explored) and self.gems[i-1][j].gcolor==gcolor then
self:floodFill(i-1,j,gcolor)
end
end

-- O(8*n^2*m)*O(log2(n)) -- worst case
function Board:checkSolutions()
local colors = {"blue","green","orange","red","pink","purple","yellow","violet"}
for k,c in ipairs(colors) do
if k > curGemColor then
return
end
for i=1 ,maxGemsRow do
for j=1, maxGemsCol do
if self.gems[i][j].state == GEM_LIVE and self.gems[i][j].gcolor==c then
self:floodFill(i,j,c)
local n = table.maxn(self.gemsEx)
if n>2 then -- explode gems!!
sound(SOUND_PICKUP)
local points = math.pow(2,n)
score = score + points
gemsCleared = gemsCleared + n
for t,gem in ipairs(self.gemsEx) do
self.gems[gem[0]][gem[1]].state = GEM_EXPLODE
self.gems[gem[0]][gem[1]].time = 1
end
local a = math.floor(n/2) + 1
table.insert(self.texts, FontAnim(points,
self.gems[self.gemsEx[a][0]][self.gemsEx[a][1]].x,
self.gems[self.gemsEx[a][0]][self.gemsEx[a][1]].y
))
end
self.gemsEx = {} -- reset aux values for solution computations
self:clearExplorations()
end
end
end
end
 
end

-- O(n^2)
function Board:clearExplorations()
for i=1 ,maxGemsRow do
for j=1, maxGemsCol do
if self.gems[i][j].state == GEM_LIVE then
self.gems[i][j].explored =false
end
end
end
end


function Board:clearExploredSelection()
for i=1,maxGemsRow do
for j=1,maxGemsCol do
self.gems[i][j].exploredSel = false
end
end
end

function Board:checkBrothers(origin,destiny, io,jo,id,jd)
local r = {}
local c1 = origin.gcolor
local c2 = destiny.gcolor
self:clearExploredSelection()
destiny.exploredSel = true
r = self:floodFillSelection(io,jo,c2,0,true)
--print("c2:"..r)
if r>2 then return true end
self:clearExploredSelection()
origin.exploredSel = true
r = self:floodFillSelection(id,jd,c1,0,true)
--print("c1:"..r)
if r>2 then return true end
--self:checkBrothersSides(origin,destiny,io,jo,id,jd)
return false
end

function Board:checkBrothersSides(origin,destiny,io,jo,id,jd)
-- left
if jo<jd then
if jo>1 and self.gems[io][jo-1].gcolor == c2 then return true end
else
if jd>1 and self.gems[id][jd-1].gcolor == c1 then return true end
end
-- right
if jo<jd then
if jo<maxGemsCol and self.gems[io][jo+1].gcolor == c2 then return true end 
else
if jd<maxGemsCol and self.gems[id][jd+1].gcolor == c1 then return true end
end
-- bottom
if io<id then
if io>1 and self.gems[io-1][jo].gcolor == c2 then return true end
else
if id>1 and self.gems[id-1][jd].gcolor == c1 then return true end
end
-- top
if io<id then
if io<maxGemsRow and self.gems[io+1][jo].gcolor == c2 then return true end
else
if id<maxGemsRow and self.gems[id+1][jd].gcolor == c1 then return true end
end
return false
end

-- O(1)
function Board:checkSelections(index)
if self:isVequal(index,self.sel1)
--or self:isVequal(index,self.sel2)
then
self.gems[self.sel1[0]][self.sel1[1]].selected = false
return nil
end
if self.sel1 == nil then
self.sel1 = index
elseif self.sel2 == nil then
self.sel2 = index
elseif not self:isVequal(index,self.sel1) then
if self.sel1 ~= nil then
self.gems[self.sel1[0]][self.sel1[1]].selected = false
end
self.sel1 = index
else
if self.sel2 ~= nil then
self.gems[self.sel2[0]][self.sel2[1]].selected = false
end
self.sel2 = index
end
if self:isVequal(self.sel1,self.sel2) then
self.sel2 = nil
end
if self.sel1 ~= nil and self.sel2 ~= nil then
local g1 = self.gems[self.sel1[0]][self.sel1[1]]
local g2 = self.gems[self.sel2[0]][self.sel2[1]]
local i1,i2,j1,j2 = self.sel1[0],self.sel2[0],self.sel1[1],self.sel2[1]
if math.abs(i1-i2)>1 or math.abs(j1-j2)>1 or
g1.state~=GEM_LIVE or g2.state~=GEM_LIVE or
(i1~=i2 and j1~=j2)
then
g1.selected = false
g2.selected = false
self.sel1 = nil
self.sel2 = nil
return
end
if not(self:checkBrothers(g1,g2,i1,j1,i2,j2)) then
g2.selected = false
self.sel2 = nil
return
end
-- do change
g1:mirror(g2)
self.gems[self.sel1[0]][self.sel1[1]] = g2
self.gems[self.sel2[0]][self.sel2[1]] = g1
self.sel1 = nil
self.sel2 = nil
sound(SOUND_SHOOT)
end
end


-- O(n2)
function Board:touched(touch)
 -- if self.state ~= BOARD_PLAY then return end
local i,j
magic:touched(touch)
for i=1,maxGemsRow do
for j=1,maxGemsCol do
if self.gems[i][j]:touched(touch) then
self.gems[i][j].selected = true
-- magic.color = self.gems[i][j].color -- optional tuning
--print(i,j)
local k = {}
k[0] = i
k[1] = j
self:checkSelections(k)
return
else
--print(i,j,maxGemsCol)
end
 
end
end
end

FontAnim = class()
function FontAnim:init(text,x,y)
self.text = text
self.x  = x
self.y  = y
self.time = 3
end

function FontAnim:draw()
self.time = self.time - 1/11
if self.time > 0 then
number(self.x, self.y, self.text, 10)
end
end
