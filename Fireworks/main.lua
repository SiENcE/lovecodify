-- got it from here
-- credits to Robert Rainthorpe & blissapp
-- http://twolivesleft.com/Codify/Talk/discussion/34/my-first-lua-script-fireworks
-- https://gist.github.com/1326513
dofile ("loveCodify.lua")

debris_list = {}

iparameter("clumps",1,20,4)
clumps= 4

iparameter("points",1,1000,250)
points = 2500

clump_factor = clumps / points

iparameter("maxvel",1,100,10)
maxvel= 10

iparameter("maxcycles",1,1500,750)
maxcycles=750

parameter("gdiv",0.1,5,1.5)
gdiv = 1.5

function add_debris(ox,oy)
	local vel=math.random() * maxvel
	local angle = math.random() * 2 * math.pi
	return {x = ox or 0, y = oy or 0, dx = vel * math.cos(angle),
	dy=vel*math.sin(angle),active=true, cycles=math.random(1,maxcycles)}
end

function neworigin()
	return math.random() * WIDTH, math.random() * HEIGHT
end

function setup()
	go()
end

function go()
	ox, oy = neworigin()
	for i= 1, points do
		if math.random() < clump_factor then ox, oy = neworigin() end
		debris_list[i]=add_debris(ox,oy)
	end
	print("Boom")
	sound(SOUND_EXPLODE)
end

function draw()
	clump_factor=clumps/points

	strokeWidth(3)
	background(10,10,20)
	local done = true
	for i, debris in ipairs(debris_list) do
		stroke (255*math.random(),255*math.random(),255*math.random(), 255 - (debris.cycles / maxcycles) * 255)
		if debris.active then
			done=false
			line(debris.x,debris.y, debris.x, debris.y)
			debris.x = debris.x + debris.dx
			debris.y = debris.y + debris.dy
			debris.dy = debris.dy + Gravity.y / gdiv
			debris.cycles = debris.cycles + 1
			if debris.cycles > maxcycles or
				debris.x > WIDTH or
				debris.x < 0 or
				debris.y > HEIGHT then
				debris.active = false
			end
		end
	end
	if done then
		print("ooooh")
		go()
	end
end
