-- got it from here
-- credits to Ipda41001
-- http://twolivesleft.com/Codea/Talk/discussion/78/vec2-example
dofile ("loveCodify.lua")

function setup()
    x1 = 123
    y1 = 234
    x2 = 67
    y2 = 345
    v1 = vec2(x1,y1)
    v2 = vec2(x2,y2)
    d1 = v1:dist(v2)
    l1 = v1:len()
    nv1 = v1:normalize()
    ra1 = v1:rotate( math.rad(-20))
end

function draw()
    background(0, 0, 0, 0)
    stroke(212, 255, 0, 255)
    fill(255, 0, 0, 255)
    ellipse(v1.x,v1.y,50,50)
    fill(28, 48, 245, 255)
    ellipse(v2.x,v2.y,50,50)
    stroke(211, 255, 0, 255)
    strokeWidth(5)
    noFill()
    line(v2.x,v2.y,v2.x + d1,v2.y)
    line(v2.x,v2.y,v2.x,v2.y + d1)
    stroke(6, 252, 40, 255)
    line(10,10,l1 + 10, 10)
    ellipse(nv1.x * 300, nv1.y * 300,50,50)
    stroke(255, 0, 0, 255)
    ellipse(ra1.x,ra1.y,50,50)
end
