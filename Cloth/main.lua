if dofile ~= nil then
	dofile ("loveCodify.lua")
end

part_list = {}
const_list = {}
time = 0
num_parts = 0
num_const = 0

-- Use this function to perform your initial setup
function setup()
    print("Tilt your device to make the cloth move")

    i = 0
    for y=0,10 do
        for x=0,10 do
            part_list[i] = insertparticle(120+x*40, 600-(y*40))
            i = i + 1
        end
    end

    w = 11
    h = 9

    i = 0
    for y=0,9 do
        for x=0,9 do
            const_list[i] = insertconstraint(y*w+x, y*w+(x+1))
            i = i + 1
            const_list[i] = insertconstraint((y+1)*w+x, y*w+x)
            i = i + 1

            const_list[i] = insertconstraint((y+1)*w+x, y*w+(x+1))
            i = i + 1
        end
    end

    for x=0,9 do
        y = 10
        const_list[i] = insertconstraint(y*w+x, y*w+(x+1))
        i = i + 1
    end
    for y=0,9 do
        x = 10
        const_list[i] = insertconstraint((y+1)*w+x, y*w+x)
        i = i + 1
    end

    
    
end

-- This function gets called once every frame
function draw()
    noSmooth()
    
    background(10,10,20)
    fill(255,0,0)
    stroke(218, 27, 27, 255)
    strokeWidth(1)

    dt = DeltaTime
    time = time + dt

    fx = math.sin(time)*4
    fy = math.cos(time*1.5)*2

    --applyglobalforce(fx,-6 + fy)
    applyglobalforce(Gravity.x*10, Gravity.y*10)

    integrate(dt)

    satisfyconstraints()

    for i=0,num_const-1 do
        line(part_list[const_list[i].p1].x,
             part_list[const_list[i].p1].y,
             part_list[const_list[i].p2].x,
             part_list[const_list[i].p2].y)
    end
end

function integrate(dt)
    for i=0,num_parts-1 do
        x = part_list[i].x
        y = part_list[i].y
        vx = part_list[i].x - part_list[i].ox
        vy = part_list[i].y - part_list[i].oy

        part_list[i].x = part_list[i].x + vx + part_list[i].fx * dt
        part_list[i].y = part_list[i].y + vy + part_list[i].fy * dt

        part_list[i].ox = x
        part_list[i].oy = y

        part_list[i].fx = 0
        part_list[i].fy = 0
    end

    for x=0, 10 do
        part_list[x].x = part_list[x].orx
        part_list[x].y = part_list[x].ory
    end
end

function satisfyconstraints()
    for x=0, 10 do
        part_list[x].x = part_list[x].orx
        part_list[x].y = part_list[x].ory
    end

    for i=0,num_const-1 do
        dx = part_list[const_list[i].p2].x - part_list[const_list[i].p1].x
        dy = part_list[const_list[i].p2].y - part_list[const_list[i].p1].y

        l = rsqrt(dx*dx + dy*dy)
        diff = (1/l - const_list[i].d) * l

        part_list[const_list[i].p1].x = part_list[const_list[i].p1].x + (dx * 0.5) * diff
        part_list[const_list[i].p1].y = part_list[const_list[i].p1].y + (dy * 0.5) * diff
        part_list[const_list[i].p2].x = part_list[const_list[i].p2].x - (dx * 0.5) * diff
        part_list[const_list[i].p2].y = part_list[const_list[i].p2].y - (dy * 0.5) * diff


    end

for x=0, 10 do
        part_list[x].x = part_list[x].orx
        part_list[x].y = part_list[x].ory
    end
end

function applyglobalforce(fx, fy)
    for i=0,num_parts-1 do
        part_list[i].fx = fx
        part_list[i].fy = fy
    end
end

function insertparticle(_x,_y)
    num_parts = num_parts + 1
    return {x=_x,y=_y,ox=_x,oy=_y,fx=0,fy=0,orx=_x,ory=_y}
end

function insertconstraint(_p1,_p2)
    num_const = num_const + 1
    return {p1=_p1, p2=_p2, d=partdistance(_p1,_p2)}
end

function partdistance(p1,p2)
    x = part_list[p2].x - part_list[p1].x
    y = part_list[p2].y - part_list[p1].y
    return math.sqrt(x*x+y*y)
end

