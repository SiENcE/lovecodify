if dofile ~= nil then
	dofile ("loveCodify.lua")
	dofile ("Abduction/person.lua")
	dofile ("Abduction/ship.lua")
	dofile ("Abduction/streamingLines.lua")
end

-- Main code

-- Use this function to perform your initial setup
function setup()
    ships   = {}
    persons = {}
    time    = 0
    seedSpd = 0.6 -- people generation speed
    bgLines = StreamingLines()
    bgLines.spawnRate = 1
    saves   = 0
    score   = 0
    maxpers = 3
    print("Use the UFO to get people to a safe planet")
end

function generatePerson()
    local l= math.random(1,3)
    local x,y,a = 0,0,0
    if l == 1 then
        -- left
        x = (WIDTH/2)-math.random(111,123)
        y = math.random(111,123)
        a = 45
    elseif l == 2 then
        -- right
        x = (WIDTH/2) + math.random(179,217)
        y = math.random(111,123)
        a = 315
    else
        -- center
        x = math.random((WIDTH/2)-11,(WIDTH/2)+11)
        y = math.random(200,223)
    end
    local person = Person(x,y,a)
    table.insert(persons,person)
    sound(SOUND_EXPLODE)
end

function updatePersons()
    for i,person in ipairs(persons) do
        local ship = ships[person.shipId]
        if person.state == PERSON_SHIP then
             -- move the person with the ship
            if ship == nil then
                person.state = PERSON_FALL
            else
                person.x = ship.x - 6
                person.y = ship.y - 23
                if math.abs(person.x - (WIDTH/2) -6)<66 and 
                    math.abs(person.y-(HEIGHT-133))<33
                then
                    person.state = PERSON_SAFE
                    person.timeToGo = 6
                    sound(SOUND_HIT)
                end
            end
        elseif person.state == PERSON_SAFE then
            person.timeToGo = person.timeToGo - 1/32
            if person.timeToGo<=0 then
                person.state = PERSON_BYE
                person.timeToGo = 3
                score = score + person.points
                sound(SOUND_PICKUP)
                saves = saves + 1
            end
        elseif person.state == PERSON_BYE then
            person.timeToGo = person.timeToGo - 1/32
            if person.timeToGo<=0 then
                table.remove(persons, i)
            end
        elseif person.state == PERSON_BORN then
            person.timeToGo = person.timeToGo - 1/32
            if person.timeToGo<=0 then
                person.state = PERSON_LOST
            end
        elseif person.state == PERSON_LEVI then
            local goDown = false
            if ship == nil then
                goDown = true
            elseif ship.isFiring then
                if not(math.abs(ship.x - person.x)<23)  then
                    goDown = true
                end
            else
                goDown = true
            end
            if goDown then
                person.state = PERSON_FALL
                person.y = person.y - 1.2 
            end
        elseif person.state == PERSON_FALL then
            person.y = person.y - 1
            if person.y < 111 then
                if person.x > ((WIDTH/2)+ 222) or
                   person.x < ((WIDTH/2)- 222) then
                    -- die
                    person.state = PERSON_KILL
                    person.timeToGo = 2.3
                    score = score - person.points
                    saves = saves - 1
                    sound(SOUND_SHOOT)
                else
                    person.state = PERSON_LOST
                end
            end
        elseif person.state == PERSON_KILL then
            person.timeToGo = person.timeToGo - 1/32
            if person.timeToGo<=0 then
                table.remove(persons,i)
            end
        end
    end -- for persons
end

function checkAbduction(k,ship)
    for i,person in ipairs(persons) do
        if person.state == PERSON_LOST or person.state == PERSON_LEVI or 
           person.state == PERSON_FALL 
        then
         if math.abs(ship.x - person.x)<23 and person.y<(HEIGHT/2)+33 then
            --print ("abduction")
            person.shipId = k
            person.y = person.y + 0.6
            if person.angle ~= 0 then
                person.angle = 0
            end
            person.state = PERSON_LEVI --levitation
            if math.abs(ship.y - person.y)<23 then
                person.state = PERSON_SHIP
                sound(SOUND_BLIT)
            end
         end
        end
    end
end

-- This function gets called once every frame
function draw()
    for k,ship in pairs(ships) do
     if ship.isFiring==true then
        checkAbduction(k,ship) 
     end
    end
    updatePersons()
    if time <= 0 and table.maxn(persons)<maxpers then
        time = seedSpd * 100
        if table.maxn(persons)<3 then
            generatePerson()
        end
    else
        time = time - seedSpd
    end
    background(0, 0, 0, 255)
    bgLines:update()
    bgLines:draw()
    -- planet
    ellipse(WIDTH/2,0,HEIGHT/2,HEIGHT/2)
    sprite("SpaceCute:Planet", WIDTH/2, HEIGHT - 200)
    for i,p in ipairs(persons) do
        p:draw()
    end
    for k,ship in pairs(ships) do
        ship:draw()
    end
    noSmooth()
    stroke(255, 255, 255, 255)
    strokeWidth(2)
    number(6, HEIGHT - 6, score, 10)
    sprite("Planet Cute:Star",WIDTH-45,HEIGHT - 10,60)
    number(WIDTH - 33, HEIGHT - 10, "x"..saves, 8)
end

function touched(touch)
   -- if touch.tapCount ~= 1 then return nil end
    if ships[touch.id]==nil then
        ships[touch.id] = Ship(WIDTH/2,HEIGHT-111)
    end
    if touch.x>23 and touch.x< WIDTH - 23 then
        ships[touch.id].x = touch.x
    end
    if touch.y >279 then
        ships[touch.id].y = touch.y
    else
        ships[touch.id].y = 279
    end
    if touch.state == BEGAN or touch.state == MOVING  then
        if touch.y < 444 then
            ships[touch.id].isFiring = true
        else
            ships[touch.id].isFiring = false
        end
    elseif touch.state == ENDED then 
        --ships[touch.id].isFiring = false
        ships[touch.id] = nil
    end
    --print (touch.y)
    
end

-----------------------------------
-- Functions for drawing numbers --
-----------------------------------


-- Draw a number. x, y is top left
function number(x, y, n, w)
    l = string.len(n)
    for i = 1, l do
        drawDigit(x + ((i - 1) * (w * 1.5)), y, string.sub(n, i, i), w)
    end
end

-- Draw a single digit
function drawDigit(x, y, n, w)
    h = 2 * w
    if string.match(n, "1") then
        line(x + (w / 2), y, x + (w / 2), y - h)
    elseif string.match(n, "2") then
        line(x, y, x + w, y)
        line(x + w, y, x + w, y - (h / 2))
        line(x + w, y - (h / 2), x, y - (h / 2))
        line(x, y - (h / 2), x, y - h)
        line(x, y - h, x + w, y - h)
    elseif string.match(n, "3") then
        line(x, y, x + w, y)
        line(x + w, y, x + w, y - h)
        line(x + w, y - h, x, y - h)
        line(x, y - (h / 2), x + w, y - (h / 2))
    elseif string.match(n, "4") then
        line(x, y, x, y - (h / 2))
        line(x, y - (h / 2), x + w, y - (h / 2))
        line(x + w, y, x + w, y - h)
    elseif string.match(n, "5") then
        line(x + w, y, x, y)
        line(x, y, x, y - (h / 2))
        line(x, y - (h / 2), x + w, y - (h / 2))
        line(x + w, y - (h / 2), x + w, y - h)
        line(x + w, y - h, x, y - h)
    elseif string.match(n, "6") then
        line(x + w, y, x, y)
        line(x, y, x, y - h)
        line(x, y - h, x + w, y - h)
        line(x + w, y - h, x + w, y - (h / 2))
        line(x + w, y - (h / 2), x, y - (h / 2))
    elseif string.match(n, "7") then
        line(x, y, x + w, y)
        line(x + w, y, x + w, y - h)
    elseif string.match(n, "8") then
        line(x, y, x + w, y)
        line(x + w, y, x + w, y - h)
        line(x + w, y - h, x, y - h)
        line(x, y - h, x, y)
        line(x, y - (h / 2), x + w, y - (h / 2))
    elseif string.match(n, "9") then
        line(x + w, y - (h / 2), x, y - (h / 2))
        line(x, y - (h / 2), x, y)
        line(x, y, x + w, y)
        line(x + w, y, x + w, y - h)
        line(x + w, y - h, x, y - h)
    elseif string.match(n, "0") then
        line(x, y, x + w, y)
        line(x + w, y, x + w, y - h)
        line(x + w, y - h, x, y - h)
        line(x, y - h, x, y)
    elseif string.match(n, "x") then
        line(x, y - (w / 3), x + w, y - (h + 1))
        line(x + w, y - (w / 3), x, y - (h + 1))
    end
end



