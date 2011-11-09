-- got it from here
-- credits to blissapp
-- http://twolivesleft.com/Codify/Talk/discussion/33/my-first-prog-moire-toy
-- https://gist.github.com/1326466
if dofile ~= nil then
	dofile ("loveCodify.lua")
end

--simple moire toy in Lua for iPad Codify
--blissapp
--public domain
flip=true
hIncrement=0
wIncrement=0
touchX=WIDTH/2
touchY=HEIGHT/2
init=true

function setup()
	iparameter("MIN_LINES",0,1000,0)
	iparameter("MAX_LINES",0,1000,500)
	iparameter("numLines",0,MAX_LINES,MAX_LINES)
	iparameter("width",1,20,3)
	iparameter("speed",1,100,2)
	iparameter("lineCap",0,2,0)
	iparameter("strobe",0,1,0)
end

function changeNumLines(speed)
	if(numLines>MAX_LINES) then
		flip=false
	end

	if (numLines<MIN_LINES) then
		flip=true
	end

	if (flip) then
		numLines = numLines + speed
	else
		numLines = numLines - speed
	end
end

function drawSegment(xpos, ypos,xflip,yflip)
	for y=0,numLines do
		line(xpos, ypos +(y*hIncrement)*yflip,xpos+((numLines-y)*wIncrement)*xflip,ypos)
	end
end

function drawStar(hincr, wincr, xposn, yposn)
	hIncrement = hincr
	wIncrement = wincr

	drawSegment(xposn, yposn,1,1)
	drawSegment(xposn, yposn,1,-1)
	drawSegment(xposn, yposn,-1,1)
	drawSegment(xposn, yposn,-1,-1)
end

function touched(touch)
	init=false
end

function draw()
	if (init) then
	else
		touchX=CurrentTouch.x
		touchY=CurrentTouch.y
	end

	changeNumLines(speed)

	background(141, 171, 201, 255)

	-- circle fill
	stroke(0, 0, 0, 255)

	-- line colour
	if(strobe==1) then
		fill(math.random(255),math.random(255),math.random(255),100)
	else
		fill(54, 231, 52, 104)
	end

	ellipse(touchX,touchY,WIDTH*1.1,HEIGHT*1.1)
	strokeWidth(width)
	if width < 4 then
		noSmooth()
	else
		smooth()
	end

	noSmooth()


	lineCapMode(lineCap)
	-- line(x1,y1,x2,y2)

	drawStar(HEIGHT/ numLines*2 , WIDTH / numLines*2, touchX, touchY)
end
