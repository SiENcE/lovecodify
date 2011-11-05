dofile ("loveCodify.lua")

--[[ ------------------------------------------------------------
                           Main.lua
--]] ------------------------------------------------------------

-- global screen size constants
bottomY = HEIGHT *.21
trackWidth = WIDTH * .9 -- width of the track at the bottom
horizonY = trackWidth * .55 + bottomY
trackHeight = horizonY - bottomY
trackLength = 100 -- in meters

-- main objects
myCar = nil
speed = 0 -- for showing to the user
cars = {}
day = nil
track = nil

-- various global variables
location = 0 -- my location
maxPosition = -1000 -- the location relative to me where the front-most car is
gameStarted = false -- whether the user has started the game
lastCollisionT = -1000 -- last time i collided, for the penalty
rnum = 0
gameTime = 0 -- for reporting to the user
startTime = 0 -- the time at which the game started
accAngle = 0 -- gravity.z threshold for accelerating vs breaking
days = 1 -- which day we're on
carsToPassInit = 185 -- on day 1 we need this many
carsToPass = carsToPassInit -- how many cars to advance to the next day
gameOver = false
maxSpeed = 200
regularSpeed = 85

function setup()
    watch("carsToPass")
    watch("days")
    watch("speed")
    watch("location")
    track = Track()
    day = Day()
    myCar = Car(0,0,0)
    myCar.speed=120
    print("Instructions:")
    print("Angle fwd to accelerate")
    print("Angle back to break")
    print("Keep still to maintain speed")
    print("Arrows to steer")
    print("Touch the screen to start")
end

function draw()
    rectMode(CORNER)
    ellipseMode(RADIUS)
    speed = myCar.speed

    ------------- UPDATE GAME STATE ----------------
    if not gameOver then
        -- move track around
        turnTrack(gameTime,track)
        track:moveToTargetX()
        -- move the day forward in time
        day:updateMode(gameTime)

       accelerating = userInputs() -- start, left, right, brake, etc

        if gameStarted then
            gameTime = ElapsedTime - startTime
            location = location + DeltaTime*myCar.speed/100
            spawnNewCars()
            myCar:updateTireState()
            day:updateFogEnd(myCar.speed)
        end

        -- if we're turning then apply the centrifugal force
        centrifugal = track:centrifugal()
        centrifugal = centrifugal * myCar.speed / 150
        myCar.x = myCar.x + centrifugal
        day:moveX(centrifugal*700)

        collided = checkForCollisions()
        moveCars()
    end

    --------------- DRAW ---------------
    drawBackground()
    myCar:draw(track,day)
    for i,c in ipairs(cars) do
        if c.y > 0 and c.y <= .9*trackLength and c.real then
            c:draw(track,day)
        end
    end
    day:drawFog()

    if gameStarted and not gameOver then
        if accelerating == 1 then
            -- show green arrow forward
            stroke(0, 255, 0, 255)
            drawArrow(vec2(WIDTH*.1,bottomY*.25),90,WIDTH/750)
        elseif accelerating == 2 then
            -- show red arrow back
            stroke(255,0,0,255)
            drawArrow(vec2(WIDTH*.1,bottomY*.75),270,WIDTH/750)
        end
    end

    if collided then
        fill(255, 243, 0, 255)
        ellipse(WIDTH/2,bottomY*.5,bottomY*.25,bottomY*.25)
    end
end

function moveCars()
    maxPosition = -1000
    for i,c in ipairs(cars) do
        change = -DeltaTime*(myCar.speed-c.speed)/1.3
        beforeY = c.y
        c.y = c.y + change

        -- count carsPassed
        if c.real then
            if c.y<0 and beforeY>0 and not day.won then carsToPass = carsToPass - 1 end
            if c.y>0 and beforeY<0 and not day.won then carsToPass = carsToPass + 1 end
        end

        if carsToPass == 0 and not day.won then
            day.won = true
            print("Achievement unlocked: Day", days)
        end

        -- remove cars
        -- avoid collisions from the back by removing cars
        if c.y>0 and beforeY<0 and collidesWithMyCar(c) then
            table.remove(cars,i)
        -- remove cars that are too far
        elseif c.y < -5 * trackLength or c.y > 2 * trackLength then
            table.remove(cars,i)
        else c:updateTireState() end

        maxPosition = math.max(maxPosition,c.y)
    end
end

function userInputs()
    -- handle steering
    if (CurrentTouch.state == BEGAN or CurrentTouch.state == MOVING ) then
        if gameStarted then
            if CurrentTouch.y < bottomY then
                dx = .05
                if day:inSnow() then dx = dx / 2 end
                if CurrentTouch.x > .64 * WIDTH and CurrentTouch.x < .84 *WIDTH then
                    -- go left
                    myCar.x = myCar.x - dx
                elseif CurrentTouch.x > .84 * WIDTH then
                    -- go right
                    myCar.x = myCar.x + dx
                end
            end
        else
            -- start game
            gameStarted = true
            startTime = ElapsedTime
            accAngle = Gravity.z + .002
        end
    end

    -- handle acceleration
    if gameStarted then
        dz = Gravity.z - accAngle
        if dz < -.03 then
            myCar.speed = math.min(maxSpeed,myCar.speed+1)
            return(1)
        elseif dz > .08 then
            myCar.speed = math.max(0,myCar.speed-3)
            return(2)
        end
    end
    return(3)
end

-- turns the track left and right every now and then
lastTurnT = 0
function turnTrack(gameTime,track)
    if gameTime - lastTurnT > 5 then
        track:newTargetX()
        lastTurnT = gameTime
    end
end

function checkForCollisions()
    -- with the walls
    maxX = .75
    if myCar.x > maxX or myCar.x < -maxX then
        if myCar.x < 0 then
            myCar.x = -maxX/1.2
        else
            myCar.x = maxX/1.2
        end
        myCar.speed = math.max(0,myCar.speed-maxSpeed/5)
    end

    -- with other cars
    for i, car in ipairs(cars) do
        if collidesWithMyCar(car) then
            lastCollisionT = ElapsedTime
            break
        end
    end

    -- penalty for colliding for .5 seconds
    if ElapsedTime - lastCollisionT < 1 then
        myCar.speed = regularSpeed / 2
        return(true)
    else
        return(false)
    end
end

-- check if this car collides with my car
function collidesWithMyCar(car)
    if not car.real then return(false) end
    dx = math.abs(myCar.x - car.x)
    dy = car.y - myCar.y
    return(dx < 0.4 and dy > 0 and dy < 4) -- based on car dimensions
end

function drawBackground()
    background(0, 0, 0, 255)

    -- field, track, sky, clouds
    day:draw(track)

    -- botton
    fill(0, 0, 0, 255)
    rect(-5,0,WIDTH+10,bottomY)

    -- the left/right controls
    fill(255, 255, 255, 255)
    stroke(255, 255, 255, 255)
    drawArrow(vec2(WIDTH*.82,bottomY*.5),180,WIDTH/750)
    drawArrow(vec2(WIDTH*0.86,bottomY*.5),0,WIDTH/750)
end

function drawArrow(pos,orient,s)
    pushMatrix()
    resetMatrix()
    pushStyle()
    translate(pos.x,pos.y)
    scale(s)
    strokeWidth(13)
    lineCapMode(PROJECT)
    rotate(orient)
    line(0, 0, 70,0)
    line(73, 0, 50, 25)
    line(73, 0, 50, -25)
    popStyle()
    popMatrix()
end

-- why? because I was trying to get around the bug
-- with sounds vs random and in the end I just didn't
-- use sound
function random()
    return(math.random())
end

--[[ ------------------------------------------------------------
                           Track.lua

       Represents the track. Knows which way the horizon is pointing,
       and how to draw tracks (both straight and curved)

       Note on coordinates in this class: x is in pixels relative
       to the middle of the screen and y is in pixels in absolute
       terms (from the bottom of the screen)
--]] ------------------------------------------------------------

Track = class()

DIRTH = 2 -- threshold at which tracks become straight, a couple of pixels from Width/2

function Track:init()
    self.horizonX = 0 -- which it's pointing now
    self.horizonTargetX = 0 -- where eventually it will point

    -- the coordinates of the track at the bottom
    bottomXR = trackWidth/2
    bottomXL = -bottomXR
    self.bottomL = vec2(bottomXL,bottomY)
    self.bottomR = vec2(bottomXR,bottomY)

    -- these are calculated based on horizonX when updated
    self.horizonL = nil -- coords of the track at the horizon
    self.horizonR = nil
    self.centerL = nil -- center of curvature of the tracks
    self.centerR = nil
    self.rL = 0 -- radius of curvature of the tracks
    self.rR = 0
end

-- UPDATING FUNCTIONS

-- call this function to change the targetX to a new random position
function Track:newTargetX()
    rand = random()
    if rand < 1/3 then self.horizonTargetX = -trackWidth / 2
    elseif rand < 2/3 then self.horizonTargetX = trackWidth / 2
    else self.horizonTargetX = 0 end
end

-- call this function to move the horizonX closer to the target
function Track:moveToTargetX()
    dH = math.min(10,math.abs(self.horizonX-self.horizonTargetX))

    if self.horizonTargetX < self.horizonX then
        self:setHorizon(self.horizonX-dH)
    elseif self.horizonTargetX > self.horizonX then
        self:setHorizon(self.horizonX+dH)
    end
end

-- x in pixels relative to the middle of the screen. negative is to the left
function Track:setHorizon(x)
    self.horizonX = x

    if self.horizonX < -DIRTH then
        -- we're turning left

        -- left track
        self.rL = .275 * trackWidth^2 / math.abs(self.horizonX)
        self.horizonL = vec2(self.horizonX,horizonY)
        self.centerL = circleCenter(self.bottomL,self.horizonL,self.rL,1,-1)

        -- right track
        self.rR = 8 * self.rL
        adj = -self.horizonX * WIDTH/trackWidth*.009 -- due to numerical error?
        self.horizonR = vec2(self.horizonX,horizonY+adj)
        self.centerR = circleCenter(self.bottomR,self.horizonR,self.rR,-1,-1)
    elseif self.horizonX > DIRTH then
        -- we're turning right

        -- right track
        self.rR = .275 * trackWidth^2 / math.abs(self.horizonX)
        self.horizonR = vec2(self.horizonX,horizonY)
        self.centerR = circleCenter(self.bottomR,self.horizonR,self.rR,1,1)

        -- left track
        self.rL = 8 * self.rR
        adj = self.horizonX * WIDTH/trackWidth*.009 -- due to numerical error?
        self.horizonL = vec2(self.horizonX,horizonY+adj)
        self.centerL = circleCenter(self.bottomL,self.horizonL,self.rL,-1,1)
    end
end

-- calculates the center of a circle that passes through bottom abd horizon
-- both of which are vec2s and pf radius r, returns a vec2
-- ugly math ahead
function circleCenter(bottom,horizon,r,mult1,mult2)
    m = -(bottom.x-horizon.x)/(bottom.y-horizon.y)
    b = (bottom.y+horizon.y-m*(bottom.x+horizon.x))/2
    c1 = (1+m^2)
    c2 = -(bottom.x+horizon.x)*c1
    c3 = horizon.x^2 + (b-horizon.y)^2 - r^2
    centerX = (-c2 + mult2 * math.sqrt(c2^2-4*c1*c3))/(2*c1)
    centerY = mult1*math.sqrt(r^2-(centerX-bottom.x)^2)+bottom.y
    return(vec2(centerX,centerY))
end

-- GETTER FUNCTIONS

-- the centrifugal force on my car and clouds
function Track:centrifugal()
    return (-self.horizonX / (trackWidth/2) * .01)
end

-- x coord of left track in pixels relative to Width/2
-- y in metters
function Track:leftAt(y)
    return(self:atHelper(y,self.rL,self.centerL,-1))
end

-- x coord of right track in pixels relative to Width/2
-- y in metters
function Track:rightAt(y)
    return(self:atHelper(y,self.rR,self.centerR,1))
end

function Track:atHelper(y,r,center,mult)
    s = metersToPixels(y)
    ys = s + bottomY
    if self.horizonX < -DIRTH then
        -- turning left
        xs = math.sqrt(r^2 - (ys - center.y)^2) + center.x
        xs = xs - adj*2*s/trackHeight -- numerical adjustment
    elseif self.horizonX > DIRTH then
        -- turning right
        xs = -math.sqrt(r^2 - (ys - center.y)^2) + center.x
        xs = xs + adj*2*s/trackHeight -- numerical adjustment
    else
        -- going straight
        xs = mult*(1-s/trackHeight) * trackWidth/2
    end
    return(xs)
end

-- tracks y in meter (0,trackLength) and returns y in pixels relative to the bottom
-- note that it's not a linear relationship due to perpective
function metersToPixels(y)
    s=y/trackLength
    s = (1-s)^2.5
    return((1-s)*trackHeight)
end

function Track:draw()
    pushStyle()
    pushMatrix()
    resetMatrix()

    lineCapMode(PROJECT)
    translate(WIDTH/2,0)
    stroke(183, 183, 183, 255)

    if math.abs(self.horizonX) <= DIRTH then
        -- we're going straight
        strokeWidth(5)
        line(self.bottomL.x,self.bottomL.y,self.horizonX,horizonY)
        line(self.bottomR.x,self.bottomR.y,self.horizonX,horizonY)
    else
        -- we're turning
        strokeWidth(3)
        noFill()
        ellipse(self.centerL.x,self.centerL.y,self.rL,self.rL)
        ellipse(self.centerR.x,self.centerR.y,self.rR,self.rR)
    end

    popStyle()
    popMatrix()
end

--[[ ------------------------------------------------------------
                           Day.lua
--]] ------------------------------------------------------------

Day = class()

function Day:init()
    self.mode = 1 -- day, night, snow, etc
    self.lastModeT = 0 -- last time we changed modes
    self.clouds = {}
    self.won = false -- whether we passed all cars for this day
    self.fogEnd = .5 -- for fog animation
    self:makeClouds()
end

function Day:makeClouds()
    for i = 0, 5 do
        minY = horizonY + HEIGHT / 15
        maxY = HEIGHT - HEIGHT / 20
        y = minY + random()*(maxY-minY)
        cloud = Cloud(random()*WIDTH,y)
        table.insert(self.clouds,cloud)
    end
end

function Day:inSnow()
    return(modes[self.mode].snow)
end

-- moves the day mode forward
function Day:updateMode(gameTime)
    if gameTime - self.lastModeT > modes[self.mode].length then
        if self.mode == numModes then
            if carsToPass > 0 then
                print("GAME OVER")
                gameOver = true -- global variable
            else
                carsToPass = carsToPassInit + 40 * days
                days = days + 1
                self.won = false
            end
        end
        self.mode = self.mode%numModes+1
        self.lastModeT = gameTime
    end
end

-- moves the clounds around
function Day:moveX(dx)
    for i,cloud in ipairs(self.clouds) do
        cloud:moveX(dx)
        -- handle a clound disappearing at the edges
        if cloud.position.x < -200 or cloud.position.x > WIDTH + 200 then
            table.remove(self.clouds,i)
            -- make a new one
            minY = horizonY + HEIGHT / 15
            maxY = HEIGHT - HEIGHT / 20
            y = minY + random()*(maxY-minY)
            x = random()*WIDTH/8
            if dx>0 then x = -x else x = x + WIDTH end
            cloud = Cloud(x,y)
            table.insert(self.clouds,cloud)
        end
    end
end

-- needs track because we need to draw track in between the field and the sky
function Day:draw(track)
    -- green field
    strokeWidth(0)
    fill(modes[self.mode].field)
    rect(-5, bottomY, WIDTH+10, horizonY)

    -- track
    track:draw()

    -- sky
    strokeWidth(0)
    fill(modes[self.mode].sky)
    rect(-5, horizonY, WIDTH+10, HEIGHT)

    -- sunset
    sunsetW = (HEIGHT-horizonY)*.02
    if modes[self.mode].sunseta ~= nil then
        fill(modes[self.mode].sunseta)
        rect(-5,horizonY,WIDTH+10,sunsetW+1)
    end
    if modes[self.mode].sunsetb ~= nil then
        fill(modes[self.mode].sunsetb)
        rect(-5,horizonY+sunsetW,WIDTH+10,sunsetW+1)
    end
    if modes[self.mode].sunsetc ~= nil then
        fill(modes[self.mode].sunsetc)
        rect(-5,horizonY+sunsetW*2,WIDTH+10,sunsetW+1)
    end

    -- clouds
    for i,cloud in ipairs(self.clouds) do
        cloud:draw(modes[self.mode].cloud1,modes[self.mode].cloud2)
    end
end

function Day:updateFogEnd(speed)
    self.fogEnd = self.fogEnd - speed/20000
    if self.fogEnd < .5 then self.fogEnd = .6 end
end

function Day:drawFog()
    strokeWidth(0)
    if modes[self.mode].fog then
        fill(74,74,74,255)
        rect(-5,bottomY+(horizonY-bottomY)*self.fogEnd,WIDTH+10,HEIGHT)
    end
end

--[[ ------------------------------------------------------------
                           Car.lua
--]] ------------------------------------------------------------

dayCarColors = {
    color(255, 0, 0, 255),
    color(0, 35, 255, 255),
    color(11, 255, 0, 255),
    color(255, 245, 0, 255)
}

nightCarColors = {
    color(255, 0, 0, 255),
    color(255, 0, 188, 255),
    color(255, 0, 188, 255),
    color(255, 0, 0, 255)
}

Car = class()

function Car:init(x,y,color)
    self.x = x -- between -1 and 1
    self.y = y -- from 0 to trackLength in meters
    self.color = color
    self.speed = 85
    self.real = true -- unreal cars help with spawning
    self.tireState = true -- for tire animation
    self.tireStateHelper = 0
end

function Car:updateTireState()
    self.tireStateHelper = self.tireStateHelper + self.speed / 60
    if self.tireStateHelper > 5 then
        self.tireStateHelper = 0
        self.tireState = not self.tireState
    end
end

function Car:draw(track,day)
    -- coords of the track at this y
    leftX = track:leftAt(self.y)
    rightX = track:rightAt(self.y)
    
    -- my coord at this y
    x = ((1+self.x)*rightX + (1-self.x)*leftX)/2

    s = metersToPixels(self.y) -- implemented in the track class
    self:drawHelper(x,s,1-s/trackHeight,self.color,self.tireState,day)
end

-- x relative to middle of the screen in pixels, y relative to the bottom of the track
-- scale relative to a car at the bottom of the screen
-- tireState is true or false, for animation
function Car:drawHelper(x,y,s,colorIdx,tireState,day)
    pushMatrix()
    pushStyle()
    translate(WIDTH/2+x,bottomY+y)
    scale(trackWidth*s/90,trackHeight*s/108)

    if colorIdx == 0 then -- hack for my car
        thisColor = color(190,190,190,255)
    elseif modes[day.mode].rearlights then
        thisColor = nightCarColors[colorIdx]
    else
        thisColor = dayCarColors[colorIdx]
    end

    fill(thisColor)
    stroke(thisColor)
    strokeWidth(2)

    if not modes[day.mode].rearlights or colorIdx == 0 then
        -- regular car
        rect(-4,1,8,7) -- body horizontal
        rect(-2,0,4,12) -- body vertical
        rect(-6,8,12,3) -- top wing
        rect(-6,8,3,4) -- left wing
        rect(3,8,3,4) -- right wing
        for i = 0,7 do
            if (tireState and i%2==0) or (i%2==1 and not tireState) then
                startX = -8
            else
                startX = -6
            end
            rect(startX,i,3,2)
            rect(startX+11,i,3,2)
        end
    else
        -- rear lights
        rect(2,0,5,4)
        rect(-6,0,5,4)
    end
    popMatrix()
    popStyle()
end

function spawnNewCars()
    if maxPosition < 65 then -- space the cars apart
        rand1 = random()
        if rand1 < 0.7 then
            -- spawn one car
            rand2 = random()
            if rand2 < 1/3 then x = -.5
            elseif rand2 < 2/3 then x = 0
            else x = .5 end
            newCar = Car(x,.9*trackLength,randColor())
            table.insert(cars,newCar)
        else
            newCar = Car(0,.9*trackLength,randColor())
            newCar.real = false
            table.insert(cars,newCar)
        end
    end
end

-- used above
function randColor()
    ncolors = table.maxn(dayCarColors)
    idx = math.ceil(random()*ncolors)
    return(idx)
end

--[[ ------------------------------------------------------------
                           Cloud.lua
--]] ------------------------------------------------------------
Cloud = class()

function Cloud:init(x,y)
    -- you can accept and set parameters here
    self.shapes = {}
    self.position = vec2(x,y)

    -- Generate random cloud
    numCircles = 4
    spacing = 20

    for i = 1,numCircles do
        x = i * spacing - ((numCircles/2)*spacing)
        y = (random() - 0.5) * 20
        rad = spacing*random()+spacing
        table.insert(self.shapes, {x=x, y=y, r=rad})
    end

    self.width = numCircles * spacing + spacing
end

function Cloud:moveX(dx)
    self.position.x = self.position.x + dx
end

function Cloud:draw(c1,c2)
    pushStyle()
    pushMatrix()

    translate(self.position.x, self.position.y)

    -- noStroke()
    strokeWidth(-1)
    fill(c2)

    for i,s in ipairs(self.shapes) do
        ellipse(s.x, s.y - 5, s.r)
    end

    fill(c1)

    for i,s in ipairs(self.shapes) do
        ellipse(s.x, s.y + 5, s.r)
    end

    popMatrix()
    popStyle()
end

--[[ ------------------------------------------------------------
                           DayModes.lua
--]] ------------------------------------------------------------

modes = {
    { -- morning
        length = 14,
        field = color(0,68,0,255),
        sky = color(24,26,167,255),
        sunseta = nil,
        sunsetb = nil,
        sunsetc = nil,
        cloud1 = color(255,255,255,255),
        cloud2 = color(167,190,221,255),
        rearlights = false,
        snow = false,
        fog = false
    },

    { -- day1
        length = 17,
        field = color(0,68,0,255),
        sky = color(35,38,170,255),
        sunseta = nil,
        sunsetb = nil,
        sunsetc = nil,
        cloud1 = color(255, 255, 255, 255),
        cloud2 = color(167,190,221,255),
        rearlights = false,
        snow = false,
        fog = false
    },

    { -- day2
        length = 17,
        field = color(0,68,0,255),
        sky = color(45,50,184,255),
        sunseta = nil,
        sunsetb = nil,
        sunsetc = nil,
        cloud1 = color(255,255,255,255),
        cloud2 = color(167,190,221,255),
        rearlights = false,
        snow = false,
        fog = false
    },

    { -- snow
        length = 34,
        field = color(255,255,255,255),
        sky = color(45,50,184,255),
        sunseta = nil,
        sunsetb = nil,
        sunsetc = nil,
        cloud1 = color(255,255,255,255),
        cloud2 = color(167,190,221,255),
        rearlights = false,
        snow = true,
        fog = false
    },

    { -- afternoon
        length = 4,
        field = color(20,60,0,255),
        sky = color(24,26,167,255),
        sunseta = nil,
        sunsetb = nil,
        sunsetc = nil,
        cloud1 = color(255,255,255,255),
        cloud2 = color(167,190,221,255),
        rearlights = false,
        snow = false,
        fog = false
    },

    { -- sunset1
        length = 4,
        field = color(20,60,0,255),
        sky = color(24,26,167,255),
        sunseta = color(104,25,154,255),
        sunsetb = color(51,26,163,255),
        cloud1 = color(255,255,255,255),
        cloud2 = color(167,190,221,255),
        sunsetc = nil,
        rearlights = false,
        snow = false,
        fog = false
    },

    { -- sunset2
        length = 4,
        field = color(20,60,0,255),
        sky = color(51,26,163,255),
        sunseta = color(151,25,122,255),
        sunsetb = color(104,25,154,255),
        sunsetc = nil,
        cloud1 = color(255, 255, 255, 255),
        cloud2 = color(226, 220, 199, 255),
        rearlights = false,
        snow = false,
        fog = false
    },

    { -- sunset3
        length = 4,
        field = color(20,60,0,255),
        sky = color(51,26,163,255),
        sunseta = color(167,26,26,255),
        sunsetb = color(151,25,122,255),
        sunsetc = color(104,25,154,255),
        cloud1 = color(255,255,255,255),
        cloud2 = color(212, 202, 169, 255),
        rearlights = false,
        snow = false,
        fog = false
    },

    { -- sunset4
        length = 4,
        field = color(48,56,0,255),
        sky = color(104,25,154,255),
        sunseta = color(163,57,21,255),
        sunsetb = color(167,26,26,255),
        sunsetc = color(151,25,122,255),
        cloud1 = color(230, 230, 230, 255),
        cloud2 = color(193, 168, 107, 255),
        rearlights = false,
        snow = false,
        fog = false
    },

    { -- sunset5
        length = 4,
        field = color(48,56,0,255),
        sky = color(151,25,122,255),
        sunseta = color(181,83,40,255),
        sunsetb = color(163,57,21,255),
        sunsetc = color(167,26,26,255),
        cloud1 = color(204, 204, 204, 255),
        cloud2 = color(251,228,187,255),
        rearlights = false,
        snow = false,
        fog = false
    },

    { -- sunset6
        length = 4,
        field = color(48,56,0,255),
        sky = color(167,26,26,255),
        sunseta = color(162,98,33,255),
        sunsetb = color(181,83,40,255),
        sunsetc = color(163,57,21,255),
        cloud1 = color(179, 179, 179, 255),
        cloud2 = color(255,194,104,255),
        rearlights = false,
        snow = false,
        fog = false
    },

    { -- sunset7
        length = 4,
        field = color(48,56,0,255),
        sky = color(163,57,21,255),
        sunseta = color(134,134,29,255),
        sunsetb = color(162,98,33,255),
        sunsetc = color(181,83,40,255),
        cloud1 = color(156, 156, 156, 255),
        cloud2 = color(254,157,133,255),
        rearlights = false,
        snow = false,
        fog = false
    },

    { -- night1
        length = 34,
        field = color(0,0,0,255),
        sky = color(74,74,74,255),
        sunseta = nil,
        sunsetb = nil,
        sunsetc = nil,
        cloud1 = color(127, 127, 127, 255),
        cloud2 = color(207, 207, 207, 255),
        rearlights = true,
        snow = false,
        fog = false
    },

    { -- fog
        length = 34,
        field = color(74,74,74,255),
        sky = color(74,74,74,255),
        sunseta = nil,
        sunsetb = nil,
        sunsetc = nil,
        cloud1 = color(255,255,255,255),
        cloud2 = color(167,190,221,255),
        rearlights = true,
        snow = false,
        fog = true
    },

    { -- night2
        length = 17,
        field = color(0,0,0,255),
        sky = color(74,74,74,255),
        sunseta = nil,
        sunsetb = nil,
        sunsetc = nil,
        cloud1 = color(127,127,127,255),
        cloud2 = color(207,207,207,255),
        rearlights = true,
        snow = false,
        fog = false
    },

    { -- sunrise
        length = 17,
        field = color(0,0,0,255),
        sky = color(111,111,111,255),
        sunseta = nil,
        sunsetb = nil,
        sunsetc = nil,
        cloud1 = color(159, 159, 159, 255),
        cloud2 = color(200, 200, 200, 255),
        rearlights = false,
        snow = false,
        fog = false
    }
}

numModes = table.maxn(modes)
