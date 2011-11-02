-- got it from here
-- credits to ruilov
-- http://twolivesleft.com/Codify/Talk/discussion/20/my-first-app-pigs-in-clover
-- https://gist.github.com/1330422
dofile ("loveCodify.lua") 

backgroundC = color(0, 0, 0, 255)
time = 0
won = false

-- open is the angle of the openning. top is where the hole is (top or bottom)
circles = {
    { radius = 75, top = true },
    { radius = 150, top = false },
    { radius = 225, top = true },
    --{ radius = 300, top = false },
}

balls = {
    { x = 300, y = 300, speedX = 0, speedY = 0, radius = 10 },
    { x = -300, y = -300, speedX = 0, speedY = 0, radius = 10 },
    { x = -300, y = 300, speedX = 0, speedY = 0, radius = 10 },
    { x = 300, y = -300, speedX = 0, speedY = 0, radius = 10 }
}

function setup()
    watch("time")
end

-- This function gets called once every frame
function draw()
    if not won then
        -- check if won now
        time = ElapsedTime
        allBallsIn = true
        for i,ball in ipairs(balls) do
            if math.sqrt(ball.x^2+ball.y^2) > 75 then
                allBallsIn = false
            end
        end
        if allBallsIn then
            print("YOU WON!")
            won = true
        end
    end
    
    ellipseMode(RADIUS)
    pushMatrix()
    translate(WIDTH/2, HEIGHT/2)
    background(backgroundC)
    
    drawWalls()
    
    fill(70, 111, 75, 255)
    stroke(168, 165, 165, 255)
    strokeWidth(1)
    
    collideStuff()
    
    -- update ball speeds
    for i,ball in ipairs(balls) do
        if not ball.collided then
            ball.speedX = ball.speedX + Gravity.x/2
            ball.speedY = ball.speedY + Gravity.y/2
        end
    end
    
    -- collide after updating speeds so for example we dont go through walls
    collideStuff()
    
    for i, ball in ipairs(balls) do
         -- friction
        ball.speedX = ball.speedX * .98
        ball.speedY = ball.speedY * .98
        --print(ball.speedY)
        -- move and pain
        ball.x = ball.x + ball.speedX
        ball.y = ball.y + ball.speedY
        ellipse(ball.x, ball.y, ball.radius, ball.radius)
    end
    
    -- hacks to make sure things dont cross boundaries
    for i,ball in ipairs(balls) do
        dc = math.sqrt(ball.x^2+ball.y^2)
        for ci, circle in ipairs(circles) do
            if dc > circle.radius-ball.radius+2
                and dc < circle.radius+ball.radius-2 and math.abs(ball.x)>20 then
                    if ball.x > 0 then ball.x = 20
                    else ball.x = -20 end
            end
        end
    end
    
    popMatrix()
end

-- collides each ball with other balls, circles and outter walls.
-- roughly works but still bugs abound
function collideStuff()
    nballs = table.maxn(balls)
    for i = 1,nballs do
        b = balls[i]
        b.collided = false
        newX = b.x + b.speedX
        newY = b.y + b.speedY
        
        -- collide with other balls
        for j = i+1,nballs do
            b2 = balls[j]
            newX2 = b2.x + b2.speedX
            newY2 = b2.y + b2.speedY
            newD = math.sqrt((newX-newX2)^2 + (newY-newY2)^2)
            if newD+1<b.radius+b2.radius then
                -- b1 and b2 collide
                b.speedX,b2.speedX = b2.speedX,b.speedX
                b.speedY,b2.speedY = b2.speedY,b.speedY
                newX = b.x + b.speedX
                newY = b.y + b.speedY
                b.collided = true
                b2.collided = true
                if math.sqrt(b.speedX^2+b.speedY^2) > 2 then
                    sound(SOUND_HIT, 5)
                end
            end
        end
        
        -- collide with outter walls
        minX = -WIDTH/2+b.radius-2
        maxX = -minX
        if newX<minX or newX>maxX then
            b.speedX = -b.speedX
            b.collided = true
            if math.sqrt(b.speedX^2+b.speedY^2) > 2 then
                sound(SOUND_HIT,8)
            end
        end
        
        minY = -HEIGHT/2+b.radius-2
        maxY = -minY
        if newY<minY or newY>maxY then
            b.speedY = -b.speedY
            b.collided = true
            if math.sqrt(b.speedX^2+b.speedY^2) > 2 then
                sound(SOUND_HIT,8)
            end
        end
        
        -- collide with circles
        for ci,circle in ipairs(circles) do
            oldInside = b.x^2+b.y^2<circle.radius^2
            
            if oldInside then
                collision = newX^2+newY^2>(circle.radius-b.radius+2)^2
            else
                collision = newX^2+newY^2<(circle.radius+b.radius-2)^2
            end
            
            if collision then
                -- this ball might be colliding with the circle , unless it's at the openning
                if math.abs(b.x)>25-b.radius/2 or
                    not ( (circle.top and b.y>0) or ((not circle.top) and b.y<0) ) then
                    -- reflect the speed vector around the position vector
                    posv = vec2(b.x,b.y)
                    speedv = vec2(b.speedX,b.speedY)
                    speedvNew = reflect(speedv,posv)
                    if math.sqrt(b.speedX^2+b.speedY^2) > 2 then
                        sound(SOUND_HIT,8)
                    end
                    b.speedX = -speedvNew.x
                    b.speedY = -speedvNew.y
                    b.collided = true
                end
            end
        end
    end
end

-- reflects vec1 around vec2
function reflect(vec1, vec2)
    -- (ans-vec1) dot vec2 = 0 and ans+vec1 = scalar * p
    -- solve these equations
    scalar = vec1:dot(vec2)*2 / vec2:dot(vec2)
    answer = vec2 * scalar - vec1
    return(answer)
end

function drawWalls()
    noFill()
    stroke(255, 255, 255, 255)
    strokeWidth(1)
    for i, circle in ipairs(circles) do
        ellipse(0, 0, circle.radius, circle.radius)
    end
    
    -- make the opennings
    fill(backgroundC)
    stroke(backgroundC)
    strokeWidth(0)
    for i, circle in ipairs(circles) do
        if circle.top then
            ellipse(0, circle.radius-13, 25, 25)
        else
            ellipse(0, -circle.radius+13, 25, 25)
        end
    end
end

