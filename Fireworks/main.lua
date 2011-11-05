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
maxvel= 7 -- tuned by my beautiful assistant

iparameter("maxcycles",1,1500,750)
maxcycles=750

parameter("gdiv",0.1,5,1.5)
gdiv = 1.5

function add_debris(_ox,_oy,_col)
	local vel=math.random() * maxvel
	local angle = math.random() * 2 * math.pi
	return {x = _ox or 0, y = _oy or 0, dx = vel * math.cos(angle),
	dy=vel*math.sin(angle),active=true, cycles=math.random(1,maxcycles), ox = _ox, oy = _oy, col = _col
	}
end

function neworigin()
	return math.random() * WIDTH, math.random() * HEIGHT, { 255*math.random(),255*math.random(),255*math.random() }
end

function setup()
	go()
end

function go()
	clump_factor=clumps/points

	local ox, oy, col = neworigin()
	for i= 1, points do
		if math.random() < clump_factor then ox, oy, col = neworigin() end
		debris_list[i]=add_debris(ox,oy, col)
	end
	sound(SOUND_EXPLODE)
	strokeWidth(2)
	noSmooth()
	background(10,10,20)
end

function draw()
	
	local done = true
	for i, debris in ipairs(debris_list) do
		stroke (debris.col[1],debris.col[2],debris.col[3], 255 - (debris.cycles / maxcycles) * 255)
		if debris.active then
			done=false
			local ox = debris.x
			local oy = debris.y
			debris.x = debris.x + debris.dx
			debris.y = debris.y + debris.dy
			debris.dy = debris.dy + Gravity.y / gdiv
			line(ox,oy, debris.x, debris.y)
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
		go()
	end
end
