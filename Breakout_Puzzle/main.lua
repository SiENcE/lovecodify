-- credits ruilov 
-- http://twolivesleft.com/Codea/Talk/discussion/137/crillion-breakout-puzzle-game
-- https://gist.github.com/1357112

if dofile ~= nil then
	dofile ("loveCodify.lua")
end

tileSize = 40
wallThickness = 15
gridW = 15
gridH = 11
dims = vec2(tileSize*gridW,tileSize*gridH)
bottom = vec2(60,60)
top = bottom+dims
ballRadius = tileSize/4
speedY = 4.2

map = nil
ball = nil
explosions = {}

gameState = "paused"
lastStateT = 0
mapIdx = 1
livesused = 0
    
function setup()
    initMapCode()   
    map = Map(mapIdx)
    ball = makeBall(mapIdx)
    editMap = makeTiles(editStr)
    
    -- editor
    watch("livesused")
    iparameter("editor",0,1,0)
    iparameter("tileColor",0,8,0)
    iparameter("tileType",0,3,0)
    iparameter("moveBallOn",0,1,0)
    iparameter("printMap",0,1,0)
    print("touch screen to move")
end

function draw()
    if editor ~= 0 then drawEditor() else runGame() end
end

function runGame() 
    
    if gameState == "won" then
        if ElapsedTime - lastStateT < 2 then
            -- just wait
        else
            -- start new level
            gameState = "paused"
            lastStateT = ElapsedTime
            mapIdx = mapIdx%table.maxn(maps) +1
            map = Map(mapIdx)
            ball = makeBall(mapIdx)
        end
    elseif gameState == "paused" then
        -- just wait for user
        userInput()   
    elseif gameState == "game over" then  
        if ElapsedTime - lastStateT < 1 then
            -- just wait
        else
            gameState = "paused"
            lastStateT = ElapsedTime
            map = Map(mapIdx)
            ball = makeBall(mapIdx)
        end
    elseif gameState == "running" then
        -- update game state
        local userInputV = userInput()
    
        collidedTiles = moveBall(userInputV) 
        for tile,dir in pairs(collidedTiles) do
            if tile.dead then
                gameState = "game over"
                lastStateT = ElapsedTime
                livesused = livesused + 1
                sound(SOUND_SHOOT,2)
            elseif tile.star then
                -- ball changes color
                ball.color = tile.color
                sound(SOUND_BLIT,8)
                
            elseif tile.color == ball.color then
                if tile.movable then 
                    if math.abs(dir) < 2 then 
                        newX = tile.x - dir
                        newY = tile.y
                    else 
                        newX = tile.x
                        newY = tile.y - dir/2 
                    end
                    
                    if math.abs(newX) < gridW /2 and math.abs(newY) < gridH /2 and
                        not map:hasXY(newX,newY) then
                        -- move tile
                        sound(SOUND_JUMP,40)
                        tile.x = newX
                        tile.y = newY
                    end
                else 
                    -- destroy tile
                    map.tiles[tile]=nil
                    table.insert(explosions,Explosion(tile.x,tile.y))
                    sound(SOUND_EXPLODE,55)
                end
            elseif tile.color == gray then
                    -- hit wall
                    sound(SOUND_BLIT,8)
            end
        end
            
        won = true
        for tile,v in pairs(map.tiles) do
            if not tile.dead and not tile.star and not tile.movable and
                tile.color ~= gray then 
                    won = false 
            end  
        end
        if won then
            print("you won",mapIdx)
            gameState = "won"
            lastStateT = ElapsedTime
            sound(SOUND_JUMP,13)
        end
    end
    
    for i,exp in ipairs(explosions) do
        keep = exp:advance()
        if not keep then table.remove(explosions,i) end
    end

    drawGame()   
end

function userInput() 
    if CurrentTouch.state == BEGAN or CurrentTouch.state == MOVING then
        if gameState =="running" and math.abs(CurrentTouch.x - top.x+10)<20 and
        math.abs(CurrentTouch.y-top.y-80)<20 then
            gameState = "game over"
            lastStateT = ElapsedTime-1
            livesused = livesused + 1
        elseif gameState == "running" and ElapsedTime - lastStateT > .2 then
            if CurrentTouch.x<WIDTH/2 then return(-1) else return(1) end   
        else 
            gameState = "running" 
            lastStateT = ElapsedTime
        end
    end
    return(0)
end

function drawGame()
    background()
    if gameState == "won" then
        c = math.floor((ElapsedTime-lastStateT)*127)
        fill(c,c,c,255)
    else 
        noFill()
    end
    stroke(255, 255, 255, 255)
    strokeWidth(wallThickness)
    rect(bottom.x-wallThickness,bottom.y-wallThickness,
        dims.x+2*wallThickness,dims.y+2*wallThickness)
    
    translate(bottom.x+dims.x/2,bottom.y+dims.y/2)

    map:draw() 
    ball:draw()
    
    for i,exp in ipairs(explosions) do
        exp:draw()
    end
    
    resetStyle()
    resetMatrix()
    strokeWidth(8)
    stroke(255, 255, 255, 255)
    noFill()
    ellipse(top.x-10,top.y+80,60,60)
    fill(0, 0, 0, 255)
    strokeWidth(0)
    rect(top.x-10,top.y+80,15,100)
    strokeWidth(8)
    lineCapMode(PROJECT)
    line(top.x+4,top.y+101,top.x-2,top.y+80)
    line(top.x+6,top.y+102,top.x+26,top.y+101)
end

-- 0 is no inpit, -1 is left and 1 is right
function moveBall(userInputY)
    speedX = math.abs(speedY)/tileSize
    if mapIdx == 12 then speedX = speedX / 1.1 end
    
    -- allow moving the target if the ball is almost there
    if math.abs(ball.targetX-ball.x) <= speedX then
        ball.targetX = ball.targetX + userInputY/2
    end
    
    if ball.targetX - ball.x < 0 then speedX = -speedX 
    elseif ball.targetX == ball.x then speedX = 0 end
    
    -- PHYSICS LOOP
    simT = 0
    speed = vec2(speedX / DeltaTime, speedY / DeltaTime)
    collidedTiles = {}
    lastTs = {}
    
    while simT < DeltaTime do
        -- calculate the next collision, including getting to the target
        minT = DeltaTime-simT
        newVec = vec2(speed.x,speed.y)
        newTargetX = ball.targetX
        thisTile = nil
        thisDir = 0
        
        -- hit the target?
        targetT = (ball.targetX - ball.x) / speed.x
        if targetT > 0 and targetT < minT then
            minT = targetT
            newVec = vec2(0,speed.y)
            newTargetX = ball.targetX
            thisTile = nil
        end
        
        -- hit the walls?
        topWallT = (dims.y/2-ballRadius-ball.y) / speed.y
        if (topWallT > 0 or (topWallT == 0 and speed.y > 0)) and topWallT < minT then
            minT = topWallT
            newVec = vec2(speed.x,-speed.y)
            newTargetX = ball.targetX
            thisTile = nil
        end
        bottomWallT = (-dims.y/2+ballRadius-ball.y) / speed.y
        if (bottomWallT > 0 or (bottomWallT == 0 and speed.y < 0)) and bottomWallT < minT then
            minT = bottomWallT
            newVec = vec2(speed.x,-speed.y)
            newTargetX = ball.targetX
            thisTile = nil
        end
        leftWallT = (-gridW/2+ballRadius/tileSize-ball.x) / speed.x
        if (leftWallT > 0 or (leftWallT == 0 and speed.x < 0)) and leftWallT < minT then
            minT = leftWallT
            newVec = vec2(-speed.x,speed.y)
            newTargetX = -gridW/2 + .75
            thisTile = nil
        end
        rightWallT = (gridW/2-ballRadius/tileSize-ball.x) / speed.x
        if (rightWallT > 0 or (rightWallT == 0 and speed.x > 0)) and rightWallT < minT then
            minT = rightWallT
            newVec = vec2(-speed.x,speed.y)
            newTargetX = gridW/2 - .75
            thisTile = nil
        end
        
        -- collide with tiles?
        for tile,v in pairs(map.tiles) do
            rightX = (tile.x+.5)+ballRadius/tileSize
            leftX = (tile.x-.5)-ballRadius/tileSize
            topY = (tile.y+.5)*tileSize+ballRadius
            bottomY = (tile.y-.5)*tileSize-ballRadius

            -- top wall
            topWallT = (topY-ball.y) / speed.y
            if (topWallT > 0 or (topWallT == 0 and speed.y < 0))
                and topWallT < minT then
                    -- check the x coord
                    ballXAtT = ball.x + speed.x * topWallT
                    if ballXAtT > leftX and ballXAtT < rightX then
                        minT = topWallT
                        newVec = vec2(speed.x,-speed.y)
                        newTargetX = ball.targetX
                        thisTile = tile
                        thisDir = 2
                    end
            end
            
            -- bottom wall
            bottomWallT = (bottomY-ball.y) / speed.y
            if (bottomWallT > 0 or (bottomWallT == 0 and speed.y > 0))
                and bottomWallT < minT then
                    -- check the x coord
                    ballXAtT = ball.x + speed.x * bottomWallT
                    if ballXAtT > leftX and ballXAtT < rightX then
                        minT = bottomWallT
                        newVec = vec2(speed.x,-speed.y)
                        newTargetX = ball.targetX
                        thisTile = tile
                        thisDir = -2
                    end
            end
            
            -- left wall
            leftWallT = (leftX-ball.x) / speed.x
            if (leftWallT > 0 or (leftWallT == 0 and speed.x > 0))
                and leftWallT < minT then
                    -- check the y coord
                    ballYAtT = ball.y + speed.y * leftWallT
                    if ballYAtT > bottomY and ballYAtT < topY then
                        minT = leftWallT
                        newVec = vec2(-speed.x,speed.y)
                        newTargetX = tile.x - 1.25
                        thisTile = tile
                        thisDir = -1
                    end
            end
            -- right wall
            rightWallT = (rightX-ball.x) / speed.x
            if (rightWallT > 0 or (rightWallT == 0 and speed.x < 0))
                and rightWallT < minT then
                    -- check the y coord
                    ballYAtT = ball.y + speed.y * rightWallT
                    if ballYAtT > bottomY and ballYAtT < topY then
                        minT = rightWallT
                        newVec = vec2(-speed.x,speed.y)
                        newTargetX = tile.x + 1.25
                        thisTile = tile
                        thisDir = 1
                    end
            end
        end
        
        -- advance minT
        simT = simT + minT
        ball.x = ball.x + speed.x * minT
        ball.y = ball.y + speed.y * minT
        ball.targetX = newTargetX
        speed = newVec
        
        if thisTile ~= nil then
            collidedTiles[thisTile] = thisDir
        end
        
        -- safety check
        if table.maxn(lastTs) > 10 then
            sum = 0
            for i,v in ipairs(lastTs) do sum = sum + v end
            if sum<=0 then
                print("loopong forever?")
                gameOver = true
                break
            end
            table.remove(lastTs,1)
         end  
         table.insert(lastTs,minT)
    end
    
    speedY = speed.y * DeltaTime
    
    return(collidedTiles)
end

-- BALL.LUA

Ball = class()

function Ball:init(x,y,color)
    -- you can accept and set parameters here
    self.x = x
    self.y = y
    self.targetX = x
    self.color = color
end

function Ball:draw()
    fill(self.color)
    ellipseMode(RADIUS)
    noStroke()
    ellipse(self.x*tileSize,self.y,ballRadius,ballRadius)
end

-- EDITOR.LUA

function drawEditor()
    userInputEditor()
    
    background()
    noFill()
    stroke(255, 255, 255, 255)
    strokeWidth(wallThickness)
    rect(bottom.x-wallThickness,bottom.y-wallThickness,
        dims.x+2*wallThickness,dims.y+2*wallThickness)
    
    translate(bottom.x+dims.x/2,bottom.y+dims.y/2)
    
    map:draw()
    ball:draw()
    
    resetMatrix()
    translate(bottom.x+300,top.y+40)
    for t,v in pairs(editMap) do
        t:draw()
    end    
    
end

lastTouchT = 0
alreadyPrinted = false
function userInputEditor()
    if CurrentTouch.state ~= BEGAN and CurrentTouch.state ~= MOVING then return(0) end
    if ElapsedTime - lastTouchT < .05 then return(0) end
    
    lastTouchT = ElapsedTime
    
    if printMap ~= 0 then 
        if not alreadyPrinted then
            map:print(ball)
            alreadyPrinted = true
            return(0)
        end
    else alreadyPrinted = false
    end
    
    if CurrentTouch.x < bottom.x or CurrentTouch.x > top.x then return(0) end
    if CurrentTouch.y < bottom.y or CurrentTouch.y > top.y then return(0) end
     
    x = math.floor((CurrentTouch.x-bottom.x)/tileSize)-(gridW-1)/2
    y = math.floor((CurrentTouch.y-bottom.y)/tileSize)-(gridH-1)/2
    
    if moveBallOn == 1 then
        ball.x = x + .25
        ball.y = CurrentTouch.y-(bottom.y+top.y)/2
        return(0)
    end
    
    foundTile = false
    for tile,v in pairs(map.tiles) do
        if tile.x==x and tile.y==y then
            foundTile = true
            t = makeTile()
            t.x = x
            t.y = y
            map.tiles[tile] = nil
            if t.color ~= black then map.tiles[t] = true end
            break
        end
    end
    
    if not foundTile then
        t = makeTile()
        t.x = x
        t.y = y
        if t.color ~= black then map.tiles[t] = true end
    end
end

function makeTile()
    tile = Tile(0,0,nil)
    if tileColor == 0 then tile.color = black end
    if tileColor == 1 then tile.color = gray end
    if tileColor == 2 then tile.color = brown end
    if tileColor == 3 then tile.color = pink end
    if tileColor == 4 then tile.color = blue end
    if tileColor == 5 then tile.color = red end
    if tileColor == 6 then tile.color = green end
    if tileColor == 7 then tile.color = lightblue end
    if tileColor == 8 then tile.color = yellow end
    
    if tileType == 1 then tile.dead = true end
    if tileType == 2 then tile.star = true end
    if tileType == 3 then tile.movable = true end
    return(tile)
end

-- EXPLOSION.LUA
Explosion = class()

function Explosion:init(x,y)
    self.x = x
    self.y = y
    self.frame = 0
end

function Explosion:advance()
    self.frame = self.frame + 1
    return self.frame < 10
end

function Explosion:draw()
    pushStyle()
    strokeWidth(0)
    fill(131, 131, 131, 255)
    radius = tileSize/4 * self.frame/10 * 2
    ellipse((self.x-.25)*tileSize+10,(self.y-.25)*tileSize,radius,radius)
    ellipse((self.x+.25)*tileSize,(self.y-.25)*tileSize,radius,radius)
    ellipse((self.x-.25)*tileSize,(self.y+.25)*tileSize-5,radius,radius)
    ellipse((self.x+.25)*tileSize,(self.y+.25)*tileSize,radius,radius)
end

-- TILE.LUA

Tile = class()

function Tile:init(x,y,color)
    self.x = x
    self.y = y
    self.color = color
    self.dead = false
    self.star = false
    self.movable = false
end

function Tile:draw()
    pushStyle()
    strokeWidth(1)
    fill(self.color)
    rect((self.x-1/2)*tileSize,(self.y-1/2)*tileSize,tileSize,tileSize)
    
    if self.star then
        fill(247, 247, 247, 255)
        ellipse(self.x*tileSize,self.y*tileSize,tileSize/2,tileSize/2)
    end
    
    if self.movable then
        fill(255, 255, 255, 255)
        rect((self.x-.1)*tileSize,(self.y-.4)*tileSize,tileSize*.2,tileSize*.8)
    end
    
    if self.dead then
        fill(0, 0, 0, 255)
        rect((self.x-.2)*tileSize,(self.y-.2)*tileSize,tileSize*.4,tileSize*.4)
    end
    popStyle()
end

-- MAP.LUA
pink = color(255, 0, 230, 255)
blue = color(98, 0, 255, 255)
red = color(255, 0, 0, 255)
brown = color(255, 163, 0, 255)  -- for dead
green = color(0, 255, 8, 255)
lightblue = color(0, 210, 255, 255)
yellow=color(152, 153, 26, 255)
gray = color(171, 171, 171, 255)   -- for brick
black = color(0, 0, 0, 255)  -- just for the editor

colorMap = {p=pink,b=brown,u=blue,g=gray,r=red,e=green,l=lightblue,y=yellow}

-- q is -1, w is -2, e is -3 and son on
coordCode = "poiuytrewq0123456789"
coordMap = nil

maps = {
"5r0u&r0bd&e0bd&w0bd&q0bd&00bd&10bd&20bd&30bd&40bd&" ..
"e1p&w1p&q1p&01p&11p&21p&31ps&eqp&wqp&qqp&0qp&1qp&2qp&3qp&" ..
"w2p&q2p&02p&12p&22p&wwp&qwp&0wp&1wp&2wp&" ..
"q3u&03u&13u&qeu&0eu&1eu&04u&0ru&",

"ur0u&twu&w1p&y1us&20g&43g&q1p&4wu&00g&11p&e4r&31p&41p&rwu&e0g&e3g&"..
"30g&r0g&61p&01p&weg&teg&23g&6eg&5eg&0eg&yeg&ywrs&51p&t0g&14r&34r&"..
"3wu&r4r&4ebd&2ebd&t3g&qebd&rebd&y3g&64r&5wu&1eg&40g&wwu&ewu&04r&"..
"10g&54r&3ebd&33g&q4r&w4r&r1p&21p&50g&r3g&62pm&03g&63g&60g&e1p&13g&"..
"y4ps&w0g&t1p&q0g&2wu&24r&t4r&53g&y0g&w3g&44r&0wu&q3g&65rm&eeg&1wu&"..
"qwu&6wu&",

"yr3u&2tu&r1u&y0u&e5bd&61u&r4u&yqu&w4u&r3u&2eu&20u&0tu&64u&wwu&w3u&"..
"02u&43u&62u&2wu&r5u&wtu&2ru&6wu&35bd&15bd&0eu&y2u&01u&w5u&yru&4qu&"..
"4ru&ywu&ytu&04u&y4u&60u&y5u&weu&0ru&05u&22u&6tu&rtu&rru&reu&55bd&"..
"25u&23u&0qu&u5bd&40u&75bd&41u&wru&44u&w2u&03u&y1u&r0u&45u&4eu&rqu&"..
"w0u&q5bd&6ru&65u&6qu&4tu&t5bd&24u&0wu&",

"4rtu&63pm&62u&11u&q2u&1qu&22pm&3wpm&42pm&30pm&25u&r0pm&34pm&03u&"..
"qrpm&y1u&5tu&yqu&e5u&qwpm&e2pm&7wu&y2pm&61pm&01pm&41pm&5wpm&7rpm&"..
"12u&65u&55u&ttu&7ebd&3eu&0tpm&50u&eepm&60pm&y4pm&51u&0wpm&4wpm&43u&"..
"reu&20pm&twu&wtu&53u&t4pm&2qpm&00pm&t0pm&40pm&r5u&etu&r1u&72u&"..
"04pm&uqu&75u&w3u&equ&w0pm&yrpm&e4u&1rpm&r4pm&erpm&73pm&24pm&05pm&"..
"ywpm&w4pm&w5u&qqbd&qeu&14pm&6epm&wwu&0qpm&5qu&10u&e3u&e0u&y0pm&31u&"..
"t3u&6qpm&3rpm&wqu&2rpm&52u&0rpm&tqu&6rpm&4eu&trpm&t5u&yepm&e1u&"..
"3qbd&13u&44pm&t1u&r2pm&7tu&45u&02pm&r3u&q1u&71u&54u&64pm&teu&2eu&"..
"3tu&u1u&rwpm&33u&2wpm&74bd&q5u&6wpm&utbd&y3u&23pm&1wu&0epm&4rpm&"..
"15bd&w2pm&wru&t2pm&y5pm&w1pm&5eu&rtu&1eu&2tu&q0u&q4pm&rqpm&35u&ytpm&"..
"4qu&uwu&5ru&6tu&qtu&u4u&70u&weu&uru&21u&rru&u2u&ewpm&ueu&u0pm&7qu&"..
"32u&u3u&1tbd&q3u&u5u&",

"yr4r&w0p&32g&22g&55r&75r&50p&64r&1rp&6qp&02g&q2g&2qp&"..
"0rp&2ep&12g&wwp&4qr&0ep&53r&15rd&wrp&yrp&ywp&72g&4er&"..
"0qp&42g&rwp&6rp&4wr&wqp&e2g&2rp&rqp&w5rm&w2g&u2g&wep&"..
"40p&65r&e0p&54r&w4g&1wp&y0p&yqp&w3g&00p&r0p&63r&y2g&"..
"6wp&0wp&5wr&2wp&60p&ewp&4rr&52g&r3rm&q3p&10p&6ep&74ps&"..
"yep&t2g&20p&73r&5rr&62g&",

"yr5u&44u&51u&wrum&wwum&equ&uqu&1eum&3qu&2rum&5qu&t1u&"..
"eeu&r0u&ttu&rwu&r4u&w2um&04um&6ru&q1um&0qu&u3u&y4u&"..
"24um&ueu&t3u&y2u&qqum&75u&7tu&42u&05u&22um&20um&0rum&"..
"00um&03u&4wu&0wum&62u&qeum&tqu&q3um&31u&t5u&15um&qtum&"..
"35u&r2u&1qum&73u&w0um&y0u&yru&5eu&64u&utu&6wu&5tu&02um&"..
"7qu&53u&3tu&55u&etu&e3u&0eu&71u&ywu&3eu&rru&u1u&33u&"..
"60u&7eu&11um&u5u&1tum&q5um&40u&01u&2wum&0tu&4ru&13um&"..
"w4um&teu&e5u&e1u&",

"4rrr&u2rd&w0rd&t2rd&4wu&42u&uqrd&y2rd&1erd&0wrd&71u&"..
"qerd&e0rd&53u&errd&tqrd&qtrd&0rrd&t0rd&eqrd&werd&y5us&"..
"u5rd&wrrd&62u&rerd&1trd&e1rd&yqrd&r2rd&2trd&yrrd&1rrd&"..
"u1rd&trrd&r1rd&40u&44u&ywrd&u3rd&7eu&r0rd&73u&3trd&"..
"64us&qwrd&y1rd&rtrd&7qu&5qu&ewrd&rwrd&ytrd&uwrd&60u&"..
"51u&5eu&eerd&qqrd&wqrd&ttrd&twrd&wtrd&u4rd&0trd&etrd&"..
"55u&terd&2rrd&urrd&75u&6wu&y3rd&0erd&utrd&uerd&y0rd&"..
"t3rd&y4rd&",

"0rrp&13g&5wu&5qu&q4us&qqg&63e&7qu&6qe&50u&ytp&6wu&65e&"..
"q1g&rer&61u&5re&q3g&rqpm&w3g&12g&11g&73e&6ru&e1g&utes&"..
"62u&03g&53e&5ee&5te&6ee&q0g&74u&yer&64e&10g&q2g&yqbd&"..
"7tp&52e&e5ps&51u&55e&e4ps&7ee&tqbd&uer&e3g&60e&54e&"..
"71u&uqg&e0g&trp&ttp&6tu&70e&75u&e2g&1qg&72e&7ru&1wg&"..
"7wu&rtp&ters&",

"6r4e&70em&73e&3tu&50em&2rus&wrrs&0tg&y0em&2wg&y2e&t0em&"..
"4rls&e0em&43e&5tl&72g&42e&0wg&6tg&yeg&r0em&14e&6wg&"..
"0eg&ywg&63e&qtr&r2e&20em&6res&62g&etp&r1e&r3e&2eg&2tg&"..
"40em&10em&ytg&tty&yrys&weg&rrps&t2e&60em&4tg&4eg&q0em&"..
"00em&wwg&7te&w2e&41e&rwg&rtg&74e&reg&6eg&30em&wtg&4wg&"..
"w0em&1tp&0rps&",

"ureu&wwum&rrum&04um&u5r&75rs&22um&61um&r1um&6rum&62um&"..
"63um&6wum&w1um&0tum&w5um&y5um&4qum&60um&6eum&41um&r2um&"..
"weum&rwum&65um&wrum&2wum&0qum&y1um&40um&ywum&02um&24um&"..
"2rum&y3um&w0um&2eum&21um&64um&44um&43um&42um&w4um&4eum&"..
"2qum&y4um&20um&4tum&r3um&0eum&yeum&yqum&y0um&0rum&0wum&"..
"y2um&rtum&reum&4wum&r4um&rqum&25um&r0um&23um&w3um&wqum&"..
"w2um&00um&6qum&01um&yrum&4rum&03um&",

"0rtr&50r&utg&t1l&72e&3qg&74y&t5p&u5p&5wps&23u&1wls&"..
"63u&e1l&y5p&61l&w1l&43u&w2e&40r&54y&24g&71l&30r&t4y&"..
"64y&w3r&y2e&62e&7tg&e4y&e5p&25g&e0u&t0u&q4g&r0u&22e&"..
"qqg&y0u&uqg&r5p&r2e&wqg&11r&yqg&55p&4qg&10r&rwrd&y3r&"..
"51l&3wrs&w4g&urg&33u&r1l&14g&35p&u0u&42e&7qg&rqg&6qg&"..
"twus&eqg&w5g&tqg&uwg&52e&r3r&32e&7rg&65p&2wrd&75p&4wrd&"..
"41l&34y&u2e&u1l&70r&12g&q1u&2qg&q5p&60r&13u&0wrm&w0u&"..
"ewys&e3r&53u&y4y&44y&q2g&u4y&31l&20r&wwrd&q3r&1qg&q0u&"..
"t3r&73u&45p&r4y&5qg&qwes&ywrd&7eg&6wrd&t2e&7wg&u3r&"..
"15p&e2e&y1l&21l&ueg&",

"ur3r&eel&2rl&3wl&t2l&t1l&52l&e0l&e4l&25l&6ql&q3l&2tl&"..
"yrl&3tl&yqrm&e1l&q1l&q4l&2wl&6rl&eql&qel&e3l&7trd&yel&"..
"61l&q0l&23l&u5l&qtl&63l&21l&qql&twl&ewl&6wl&60l&5rl&"..
"22l&t0l&20l&u1l&qrl&6el&tel&6tl&tql&t3l&62ls&qwl&2ql&"..
"04l&42l&01l&q5l&",

"6rep&61es&50g&w2l&q0g&55l&7rg&1wpm&65l&73l&ewpm&7qg&"..
"01es&q2l&4epm&yqpm&14l&41es&7eg&uels&w5l&twpm&45l&q5l&"..
"t5l&2tpm&60g&11es&repm&1rpm&w4l&71es&t4l&qrpm&05l&51es&"..
"03l&30g&22l&r4l&24l&64l&ytpm&0epm&32l&02l&wqpm&04l&"..
"2qpm&52l&7wg&5rpm&y5l&74l&e5l&42l&e0g&q4l&53l&21es&"..
"13l&t0g&00g&5wpm&y1es&e3l&12l&q1es&34l&44l&y4l&62l&"..
"31es&3wpm&w1es&23l&43l&6tpm&y3l&75l&25l&e1es&72l&6qpm&"..
"r2l&q3l&r3l&trpm&qwpm&r1es&3rpm&t2l&y0g&35l&40g&t1es&"..
"erpm&r0g&70g&w0g&wtpm&7tg&t3l&63l&20g&e4l&r5l&y2l&e2l&"..
"10g&",

"5rwe&t1g&u5g&ere&1tg&2rem&wwem&wrem&53g&tqg&60em&1qg&"..
"u3g&3tg&e5g&qqg&11g&qre&5re&y0em&ueg&02em&5qg&q5g&3re&"..
"etg&1re&73g&5tg&tre&q4e&54e&2wem&42em&6wem&e4e&4wem&"..
"14e&55g&r0em&u1g&r4em&rwem&1eg&44em&75g&t5g&yrem&t4e&"..
"24em&40em&q1g&3qg&ywem&35g&q3g&13g&04em&utg&4rem&33g&"..
"34e&7tg&e3g&20em&64em&31g&00em&uqg&0wem&w2em&rrem&y2em&"..
"e1g&r2em&eeg&15g&w4em&7qg&0rem&71g&y4em&3eg&62em&t3g&"..
"5eg&teg&eqg&w0em&qeg&22em&51g&6rem&ttg&qtg&7eg&",

"1r1e&e5rd&6re&3qe&6we&1ee&wwe&14e&r5rd&tre&25rd&qre&"..
"5ee&wee&wre&4re&uqe&13e&15rd&4we&35rd&ure&t5rd&ree&"..
"yre&1we&7ee&1qe&4qe&55rd&3re&q5rd&45rd&e4e&q4e&3we&"..
"2ee&2we&0re&5re&0qe&7qe&2re&7we&2qe&6qe&5qe&05rd&yee&"..
"wqe&w5rd&65rd&rqe&tqe&yqe&0ee&y5rd&34e&twe&uee&75rd&"..
"7re&1re&eqe&0we&qwe&qqe&ere&rre&eee&u5rd&ewe&qee&uwe&"..
"3ee&",

"6rte&54u&5rus&w1u&1ru&qeg&wwu&y2u&7rus&weg&wru&y0u&"..
"62u&6wu&6ru&eeg&q3u&q5g&24u&4wu&12u&42u&e2u&0qu&ywu&"..
"7wu&ewud&35g&r3u&rwu&2eg&05g&w5g&00u&60u&43u&32u&5wu&"..
"53u&twu&73u&70ud&55g&yeg&13u&52ud&t4ud&33ud&02u&1qud&"..
"q1ud&wtum&4rus&q0u&tru&rrus&yrus&7eg&e1u&6eg&25g&5eg&"..
"y5g&qqu&4eg&65g&3eg&72u&23u&10u&1eg&11u&rqu&41u&74u&"..
"61u&t0u&04u&teg&r5g&w3u&3qu&03u&equ&20u&3ru&7qu&51u&"..
"qru&21u&yqu&15g&t5g&e0u&qwu&y4u&e3u&w2u&e4u&1wu&t3u&"..
"31u&0ru&01u&0wu&r0u&45g&5qu&75g&t1u&22u&y1u&wqu&eru&"..
"64u&14u&44u&y3u&3wu&0eg&e5g&63u&reg&tqu&6qu&r1u&2rus&"..
"r4u&t2u&q4u&r2u&q2u&2qu&2wu&4qu&34u&40u&71u&30u&w0u&"..
"w4u&50u&",

"qr1r&utrm&e3rm&7wrm&50rm&twr&e1rd&4erm&qerm&ywr&3qrm&"..
"2rr&tqrm&qrrm&1rr&eqrm&t0rm&q5rm&r0rm&7qrm&70rm&23rm&"..
"5tr&u3rm&1wrm&0qrm&t1r&6rr&q0rm&0tr&r2rm&22rm&yrr&trrm&"..
"14rm&61r&5rrm&rwr&73rm&7rrm&0erm&5wrm&4rr&e4r&w1rm&"..
"rrr&qtr&e5rm&4tr&w0rm&r4r&q2r&y0r&42rm&53r&e2rm&44rm&"..
"wqrm&21rm&62r&33r&3wrm&u0rm&urrm&qqrm&y1rm&5qrm&20rm&"..
"r1rm&ytrm&2trm&51rm&t5rm&q4r&24r&75rm&w2rm&uwrm&3er&"..
"05rm&e0rm&uerm&35rm&3rr&y5r&u2rm&2wrm&6qr&rer&3trm&"..
"yer&60r&2erm&y2rm&72rm&41rm&4qrm&52rm&ter&w3rm&r5rm&"..
"w5rm&q3rm&71rm&40rm&25rm&32rm&6erm&02rm&t4r&10rm&2qrm&"..
"t2r&1erm&63rm&r3rm&1qrm&etr&31rm&ttrm&01r&34r&0wr&qwr&"..
"15rm&y3rm&ewr&werm&rtr&err&t3r&65rm&00rm&w4r&6tr&yqr&"..
"eers&1tr&u5rm&rqrm&y4rm&11rm&7trm&13rm&04r&0rrm&74rm&",

"7r1y&uwg&e2rd&51g&50rm&2wg&ywg&65rd&6re&trym&1rl&wqg&"..
"rey&rty&6ee&wtl&5ee&yty&q4rd&7rg&2rg&q1g&00pm&4wg&4te&"..
"3te&1tl&wel&24ls&2tg&rry&t1g&6te&yrg&3qg&uty&7wg&e1g&"..
"7qg&42rd&4eg&11g&7eg&tey&erg&5rem&3re&uqg&21g&eeg&q5us&"..
"ury&qwg&qtl&e3ps&3ee&wwg&5te&rwg&25rd&t0um&6wg&0el&"..
"43es&u1g&2qg&w1g&t5rd&7tg&ewg&uey&41g&1wg&wrl&0rlm&"..
"t4rs&01g&yeg&tty&31g&r1g&etg&qrg&1el&3wg&y1g&4rg&qeg&"..
"eqg&64ys&2eg&0tl&",

"yr5l&w3lm&52lm&63lm&0wlm&qtu&e0lm&uqlm&6elm&14lm&1wlm&"..
"rqlm&1tus&04lm&7wlm&utu&23lm&qelm&2elm&q0lm&0qlm&42lm&"..
"wqlm&e3lm&eelm&64lm&4tu&1elm&r4lm&60lm&22lm&ttu&11lm&"..
"q2lm&e2lm&12lm&5tu&uwlm&51lm&43lm&rwlm&t4lm&6wlm&6qlm&"..
"qqlm&y2lm&7elm&54lm&t0lm&41lm&71lm&tqlm&t1lm&welm&10lm&"..
"uelm&53lm&telm&r2lm&etu&t2lm&ytus&0tu&1qlm&50lm&relm&"..
"y3lm&rtu&qwlm&t3lm&2tus&wtu&yqlm&5qlm&13lm&r3lm&34lm&"..
"wwlm&3tu&q4lm&5elm&02lm&4wlm&u0lm&3qlm&6tu&21lm&y4lm&"..
"3elm&0elm&7tu&r1lm&",

"2rwl&7rrd&e1g&0rg&21g&55l&w0p&r5l&rtl&rwg&y5rd&4tl&"..
"wwg&ewg&3qg&y4l&64l&wrg&qwg&e4g&15l&uwg&qrg&0tl&r4rd&"..
"0wlm&w1g&6tl&wqp&wtps&w5l&11g&ttl&e3g&31g&4wg&etg&u5l&"..
"1rg&3tl&45rd&6rl&5wg&24rd&4rl&54l&u4l&20lm&05rd&34l&"..
"url&04l&q0p&q4l&erg&1tl&w4l&rrl&2tl&5trd&utl&ytg&qqlm&"..
"1wlm&74rd&65l&e5g&3wg&eqg&q1g&e0g&7tl&ywg&qtl&25l&t4l&"..
"35l&5rl&75l&01g&trl&t5l&14l&7wg&30g&yrg&2rg&3eg&3rg&"..
"44l&q5l&",

}

editStr = "5r0u&50b&y2b&20b&w4b&y0b&w1b&y4b&24b&02b&52b&q4b&w0b&"..
"q0b&21b&w2b&54b&t4b&51b&64b&y3b&r0b&44b&w3b&r4b&22b&"..
"y1b&t0b&03b&t2b&53b&01b&"

function initMapCode()
    coordMap = {}
    for k = -10,9 do
        coordMap[string.sub(coordCode,k+11,k+11)]=k
    end
end

Map = class()

function Map:init(idx)   
    if coordMap == nil then initMapCode() end
    self.tiles = makeTiles(maps[idx])
end

function Map:hasXY(x,y)
    for tile,v in pairs(self.tiles) do
        if tile.x == x and tile.y == y then return(true) end
    end
    return(false)
end

function makeTiles(mapS)
    tiles = {}
    i = 6  --thr fist few chars is the ball pos
    while i<string.len(mapS) do
        x = coordMap[string.sub(mapS,i,i)]
        y = coordMap[string.sub(mapS,i+1,i+1)]
        c = colorMap[string.sub(mapS,i+2,i+2)]
        t = Tile(x,y,c)
        i = i + 3
        while string.sub(mapS,i,i)~="&" do
            p = string.sub(mapS,i,i)
            if p == "d" then t.dead=true end
            if p == "s" then t.star=true end
            if p == "m" then t.movable =true end
            i = i + 1
        end
        tiles[t]=true
        i = i + 1
    end
    return(tiles)
end

function makeBall(mapIdx)
    mapS = maps[mapIdx]
    i = 1
    x = coordMap[string.sub(mapS,i,i)]
    y = coordMap[string.sub(mapS,i+2,i+2)]
    c = colorMap[string.sub(mapS,i+3,i+3)]
    b = Ball(x,y,c)
    if string.sub(mapS,i+1,i+1) == "l" then b.x = b.x - .25 
    else b.x = b.x + .25 end
    b.targetX = b.x
    b.y = b.y*tileSize
    return b
end

function Map:print(ba)
    bx = math.floor(ba.x+.5)
    if ba.x < bx then lr = "l" else lr = "r" end
    by = math.floor(ba.y/tileSize)
    
    ans = findVal(coordMap,bx) .. lr .. findVal(coordMap,by)
    ans = ans .. findVal(colorMap,ba.color) .. "&"
    
    for tile,v in pairs(self.tiles) do
        ans = ans .. findVal(coordMap,tile.x) .. findVal(coordMap,tile.y)
        ans = ans .. findVal(colorMap,tile.color)
        if tile.dead then ans = ans .. "d" end
        if tile.star then ans = ans .. "s" end
        if tile.movable then ans = ans .. "m" end
        ans = ans .. "&"
        
        if string.len(ans)>50 then 
            ans = '"' .. ans .. '"..'
            print(ans)
            ans = ""
        end
    end
    
    if string.len(ans) > 0 then
        ans = '"' .. ans .. '"'
        print(ans)
    end
end

function findVal(map,val)
    for k,v in pairs(map) do
        if v == val then return(k) end
    end
    return(0)
end

function Map:draw()
    for t,v in pairs(self.tiles) do
        t:draw()
    end    
end
