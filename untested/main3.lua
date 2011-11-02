--Codify_bzone_retro_background
dofile ("loveCodify.lua")

-- Use this function to perform your initial setup
function setup()
	print("Hello World!")
	background(0,0,0,0)
	--stroke(255, 255, 0, 135)
	stroke(59)
	strokeWidth(10)
	peaks = {}
	sdeg = 1
	sheight = 2
	edeg = 3
	eheight = 4
	parameter("oclock",0,12)
	parameter("aim",0,30)
	peaks[1] = {}
	peaks[1][sdeg] = 0
	peaks[1][sheight] = 0
	peaks[1][edeg] = 1.2
	peaks[1][eheight] = 6
	peaks[2] = {}
	peaks[2][sdeg] = 1.2
	peaks[2][sheight] = 6
	peaks[2][edeg] = 1.6
	peaks[2][eheight] = 0
	peaks[3] = {}
	peaks[3][sdeg] = 1.2
	peaks[3][sheight] = 6
	peaks[3][edeg] = 3.2
	peaks[3][eheight] = 0
	peaks[4] = {}
	peaks[4][sdeg] = 2
	peaks[4][sheight] = 3.5
	peaks[4][edeg] = 3.5
	peaks[4][eheight] = 6
	peaks[5] = {}
	peaks[5][sdeg] = 3.5
	peaks[5][sheight] = 6
	peaks[5][edeg] = 4.5
	peaks[5][eheight] = 3.5
	peaks[6] = {}
	peaks[6][sdeg] = 3.5
	peaks[6][sheight] = 6
	peaks[6][edeg] = 8
	peaks[6][eheight] = 0
	peaks[7] = {}
	peaks[7][sdeg] = 4.5
	peaks[7][sheight] = 3.5
	peaks[7][edeg] = 7
	peaks[7][eheight] = 0
	numpeaks = 7
end

-- This function gets called once every frame
function draw()
	background(0,0,0,0)
	stroke(0, 255, 0, 135)
	strokeWidth(3)
	line(0, HEIGHT / 2, WIDTH, HEIGHT / 2)
	curdegree = (oclock * 30) + aim
	for i = 1, numpeaks do
		asd = math.fmod(360+(peaks[i][sdeg] - curdegree + 10),360)
		esd = math.fmod(360+(peaks[i][edeg] - curdegree + 10),360)
		sd = WIDTH * asd / 20
		ed = WIDTH * esd / 20
		sh = (HEIGHT / 2) + ((peaks[i][sheight] / 100) * HEIGHT)
		eh = (HEIGHT / 2) + ((peaks[i][eheight] / 100) * HEIGHT)
		if asd < 25 and esd < 25 then
			line(sd, sh, ed, eh)
		end
	end
end
