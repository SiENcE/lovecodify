-- Magic class
-- LGPL Juan Belón Pérez
-- videojuegos.ser3d.es
-- 2011

Magic = class()

function Magic:init(ps)
self.ps = ps
self.p = {}
for i=0,ps do
self.p[i]= {x=math.random(WIDTH*10)/10,
y=math.random(HEIGHT*10)/10, ox=0.0, oy=0.0, vx=math.random(20)-10,
vy=math.random(20)-10}
end
self.color = color(223, 255, 0, 255)
end

function Magic:draw()
 local p = self.p
 noSmooth()

 --background(10,10,20)
 fill(255,0,0)
 stroke(self.color)
 strokeWidth(3)

 for i=0,self.ps do
 p[i].ox= p[i].x
 p[i].oy= p[i].y
 p[i].x = p[i].x + p[i].vx
 p[i].y = p[i].y + p[i].vy
 
 if p[i].x<0 then
 p[i].x=0
 p[i].vx= -p[i].vx
 end

 if p[i].y<0 then
 p[i].y=0
 p[i].vy= -p[i].vy
 end

 if p[i].x>WIDTH then
 p[i].x=WIDTH
 p[i].vx= -p[i].vx
 end

 if p[i].y>HEIGHT then
 p[i].y=HEIGHT
 p[i].vy= -p[i].vy
 end

 p[i].vx = p[i].vx*0.98
 p[i].vy = p[i].vy*0.98

 line(p[i].ox, p[i].oy, p[i].x, p[i].y)
 end
end

function Magic:touched(t)
 local a = 5
 local p = self.p
 for i=0,self.ps do
 local d= (p[i].x-t.x)*(p[i].x-t.x) + (p[i].y-t.y)*(p[i].y-t.y)
 d= math.sqrt(d)
 p[i].vx = p[i].vx - a/d*(p[i].x-t.x)
 p[i].vy = p[i].vy - a/d*(p[i].y-t.y)
 end
end
