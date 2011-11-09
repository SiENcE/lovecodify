--[[
LoveCodify is a Wrapper Class to run Codify/Codea Scripts with Love2D
Copyright (c) 2010 Florian^SiENcE^schattenkind.net

Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

You can use the http://love2d.org/ runtime to code Codify Apps on MacOSX/Linux/Windows.
Beware, it's unfinished, but samples are running.

Just include the this in your Codify project:
dofile ("loveCodify.lua")
]]--

------------------------
-- loveCodify SETTINGS
------------------------
if MIRROR == nil then
    MIRROR = true
end
if LOVECODIFYHUD == nil then
	LOVECODIFYHUD = true
end

-------------------
-- Drawing
-------------------
spriteList = {}

iparameterList = {}
parameterList = {}
iwatchList = {}
watchList = {}

BEGAN = 1
MOVING = 2
ENDED = 3

CurrentTouch = {}
CurrentTouch.x = 0
CurrentTouch.y = 0
--  CurrentTouch.prevX
--  CurrentTouch.prevY
--  CurrentTouch.deltaX
--  CurrentTouch.deltaY
--  CurrentTouch.id
CurrentTouch.state = BEGAN
--  CurrentTouch.tapCount

Gravity = {}
Gravity.x = 0
Gravity.y = 0
Gravity.z = 0

-- Fill Modes - line | fill
fillMode="line"

-- Rectangle Modes
CENTER = 1
RADIUS = 2
CORNER = 3
CORNERS = 4
rectangleMode = CORNER

ROUND = 1
SQUARE = 2
PROJECT = 3
-- LineCap Modes
lineCapsMode = ROUND

-- Ellipse Modes
ellipMode = RADIUS

-- TODO: hack
ElapsedTime = 0
DeltaTime = 0

-- class.lua
-- Compatible with Lua 5.1 (not 5.0).
function class(base, init)
	local c = {}    -- a new class instance
	if not init and type(base) == 'function' then
		init = base
		base = nil
	elseif type(base) == 'table' then
		-- our new class is a shallow copy of the base class!
		for i,v in pairs(base) do
			c[i] = v
		end
		c._base = base
	end
	-- the class will be the metatable for all its objects,
	-- and they will look up their methods in it.
	c.__index = c

	-- expose a constructor which can be called by <classname>(<args>)
	local mt = {}
	mt.__call = function(class_tbl, ...)
		local obj = {}
		setmetatable(obj,c)
		if class_tbl.init then
			class_tbl.init(obj,...)
		else 
			-- make sure that any stuff from the base class is initialized!
			if base and base.init then
				base.init(obj, ...)
			end
		end
		return obj
	end
	c.init = init
	c.is_a = function(self, klass)
		local m = getmetatable(self)
		while m do 
			if m == klass then return true end
			m = m._base
		end
		return false
	end
	setmetatable(c, mt)
	return c
end

-------------------
-- Graphics
-------------------

function color(r,g,b,a)
	local color = {}
	color.r=r
	color.g=g
	color.b=b
	color.a=a
	return color
end

function background(red,green,blue,alpha)
--alpha is ignored
	if (red and green and blue) then
		love.graphics.setBackgroundColor( red, green, blue)
	elseif (type(red) == "number" and type(green) == "number") then
		love.graphics.setBackgroundColor( red, red, red, green)
	elseif (type(red) == "number") then
		love.graphics.setBackgroundColor( red, red, red, 255)
	elseif (red.r and red.g and red.b) then
		love.graphics.setBackgroundColor( red.r, red.g, red.b)
	end
end

function ellipse( x, y, width, height)
	if width == height then
		love.graphics.circle( fillMode, x, y, (width+height)/4, 50 )
	elseif height == nil then
		love.graphics.circle( fillMode, x, y, width/2, 50 )
	else
		ellipse2( x, y, width/2, height/2 )
	end
end

-- Love2d does not have a ellipse function, so we have todo it by ourself
-- TODO: the ellipse is not filled right now
-- a & b are axis-radius
function ellipse2(x,y,a,b) --,stp,rot)
	local stp=50	-- Step is # of line segments (more is "better")
	local rot=0	-- Rotation in degrees
	local n,m=math,rad,al,sa,ca,sb,cb,ox,oy,x1,y1,ast
	m = math; rad = m.pi/180; ast = rad * 360/stp;
	sb = m.sin(-rot * rad); cb = m.cos(-rot * rad)
	for n = 0, stp, 1 do
		ox = x1; oy = y1;
		sa = m.sin(ast*n) * b; ca = m.cos(ast*n) * a
		x1 = x + ca * cb - sa * sb
		y1 = y + ca * sb + sa * cb
		if (n > 0) then line(ox,oy,x1,y1); end
	end
end

function line(x1,y1,x2,y2)
--number width
--The width of the line.
--LineStyle style ("smooth")
--The LineStyle to use.
	if (x1==x2 and y1==y2) then
		love.graphics.point(x1, y1)
	else
		love.graphics.line( x1, y1, x2, y2)
	end
end

function rect(x,y,width,height)
	love.graphics.rectangle(fillMode,x,y,width,height)
	-- in love we have to reset the color after drawing
	_resetColor()
end

-- Load & Register Sprite and Draw it
function sprite(filename,x,y,width,height) 
	if spriteList[filename] == nil then
		spriteList[filename] = love.graphics.newImage(filename:gsub("\:","/") .. ".png")
	end
	sprite_draw(spriteList[filename], x, y, width, height )
end

-- Draws a Sprite (Mirror it first)
function sprite_draw( image, x, y, width, height )
	-- reset Color before drawing, otherwise the sprites will be colored
	-- because sadly Codify does not support coloring of sprites
	local r, g, b, a = love.graphics.getColor()
    
	_resetColor()

	_mirrorScreenBegin(image:getWidth(), image:getHeight())

	love.graphics.draw( image, x, y )

	-- restore coordinate system
	_mirrorScreenEnd()

	-- reset last Color
	love.graphics.setColor(r, g, b, a)
	
    -- TODO implement width and height image scale
end

function _resetColor() 
	love.graphics.setColor(255,255,255,255)
end

function _mirrorScreenBegin(width, height)
	if MIRROR == true then
		-- save coordinate system
		love.graphics.push()

		-- rotate around the center of the screen by angle radians
		love.graphics.translate(WIDTH/2, HEIGHT/2)
		-- mirror screen on x-axis
		love.graphics.scale(1, -1)

		width = width or 0
		height = height or 0
		love.graphics.translate(-WIDTH/2 - width/2, -HEIGHT/2 - height/2)
	end
end

function _mirrorScreenEnd()
	if MIRROR == true then
		-- save coordinate system
		love.graphics.pop()
	end 
end

-------------------
-- Transform
-------------------
function translate(dx, dy)
	love.graphics.translate( dx, dy )
end

function rotate(angle)
	love.graphics.rotate( angle )
end

-- TODO: add scale(amount)
function scale(sx, sy)
	love.graphics.scale( sx, sy )
end

-------------------
-- Vector
-------------------
require ("vector")

-------------------
-- Transform Management
-------------------
function pushMatrix()
	love.graphics.push()
end

function popMatrix()
	love.graphics.pop()
end

function resetMatrix()
	-- TODO
end

-------------------
-- Style Management
-------------------
function popStyle()
	-- TODO
end

function pushStyle()
	-- TODO
end

function resetStyle()
	-- TODO
end

-------------------
-- Sound
-------------------
function sound(name)
	-- TODO
end

-------------------
-- Style
-------------------
function ellipseMode(mode)
	ellipMode = mode
end

-- fills elipse & rect
function fill(red,green,blue,alpha)
	if (red and green and blue and alpha) then
		love.graphics.setColor( red, green, blue, alpha)
	elseif (red and green and blue) then
		love.graphics.setColor( red, green, blue, 255)
	elseif (type(red) == "number" and type(green) == "number") then
		love.graphics.setColor( red, red, red, green)
	elseif (type(red) == "number") then
		love.graphics.setColor( red, red, red, 255)
	elseif (red.r and red.g and red.b and red.a) then
		love.graphics.setColor( red.r, red.g, red.b, red.a)
	end
	fillMode = "fill"
end

function lineCapMode(mode)
	lineCapsMode = mode
end

function noSmooth()
	-- TODO
end

function noFill()
	fillMode = "line"
end

function noStroke()
end

function noTint()
	-- TODO
	love.graphics.setColor(255,255,255,255)
end

function rectMode(mode)
	rectangleMode=mode
end

function smooth()
	-- TODO
end

function stroke(red,green,blue,alpha)
	if (red and green and blue and alpha) then
		love.graphics.setColor( red, green, blue, alpha)
	elseif (red and green and blue) then
		love.graphics.setColor( red, green, blue, 255)
	elseif (type(red) == "number" and type(green) == "number") then
		love.graphics.setColor( red, red, red, green)
	elseif (type(red) == "number") then
		love.graphics.setColor( red, red, red, 255)
	elseif (red.r and red.g and red.b and red.a) then
		love.graphics.setColor( red.r, red.g, red.b, red.a)
	end
end

function strokeWidth(width)
	love.graphics.setLineWidth( width )
end

function tint(red,green,blue,alpha)
	if (red and green and blue and alpha) then
		love.graphics.setColor( red, green, blue, alpha)
	elseif (red and green and blue) then
		love.graphics.setColor( red, green, blue, 255)
	elseif (type(red) == "number" and type(green) == "number") then
		love.graphics.setColor( red, red, red, green)
	elseif (type(red) == "number") then
		love.graphics.setColor( red, red, red, 255)
	elseif (red.r and red.g and red.b and red.a) then
		love.graphics.setColor( red.r, red.g, red.b, red.a)
	end
end

-------------------
-- Parameters
-------------------
function iparameter(name,mini,maxi,initial)
	if initial ~= nil then
		_G[name] = initial
		iparameterList[name] = initial
	else
		_G[name] = mini
		iparameterList[name] = mini
	end
end

function parameter(name,mini,maxi,initial)
	if initial ~= nil then
		_G[name] = initial
		parameterList[name] = initial
	else
		_G[name] = mini
		parameterList[name] = mini
	end
end

function watch(name)
	watchList[name] = 0
end

function iwatch(name)
	iwatchList[name] = 0
end

-------------------
-- Touch
-------------------
-- already done in love.update(dt)

-------------------
-- Math
-------------------
function rsqrt(value)
  return math.pow(value, -0.5);
end

-------------------
-- love functions
-------------------
function love.load()
	setup()
end

-- TODO: wrong, never set to BEGAN again
function love.mousepressed(x, y, button)
	if button == "l" then
		CurrentTouch.state = BEGAN
	end
end

function love.mousereleased(x, y, button)
	if button == "l" then
		CurrentTouch.state = ENDED
	end
end

function love.update(dt)
	-- Use sleep to cap FPS at 30
	if dt < 1/30 then
		love.timer.sleep(1000 * (1/30 - dt))
	end
	
	-- use Mouse for Touch interaction
	if love.mouse.isDown("l") then
		-- get Mouse position as Touch position
		-- publish globally
		if CurrentTouch.x ~= love.mouse.getX() or CurrentTouch.y ~= love.mouse.getY() then
			CurrentTouch.x = love.mouse.getX()
			CurrentTouch.y = HEIGHT - love.mouse.getY()
			CurrentTouch.state = MOVING
		end
		
		-- publish to touched callback
		local touch = {}
		touch.x = CurrentTouch.x
		touch.y = CurrentTouch.y
		touch.id = 1 -- TODO: What does ID this mean?
        
		if touched then touched(touch) end
	end

	-- use Up,Down,Left,Right Keys to change Gravity
	if love.keyboard.isDown("up") then
		Gravity.y = Gravity.y + 0.01
	elseif love.keyboard.isDown("down") then
		Gravity.y = Gravity.y - 0.01
	elseif love.keyboard.isDown("left") then
		Gravity.x = Gravity.x + 0.01
	elseif love.keyboard.isDown("right") then
		Gravity.x = Gravity.x - 0.01
	elseif love.keyboard.isDown("pageup") then
		Gravity.z = Gravity.z + 0.01
	elseif love.keyboard.isDown("pagedown") then
		Gravity.z = Gravity.z - 0.01
	end

	-- set Time Values
	DeltaTime = love.timer.getDelta()
	ElapsedTime = love.timer.getTime()
end

function love.draw()
	_mirrorScreenBegin()
	draw()
	_mirrorScreenEnd()

    if (LOVECODIFYHUD) then
	love.graphics.setColor( 125, 125, 125)
	love.graphics.print( "iparameter", 5, 14)
	local i=2
	for k,v in pairs(iparameterList) do
		iparameterList[k]=_G[k]
		love.graphics.print( k, 5, 14*i)
		love.graphics.print( tostring(v), 80, 14*i)
		i=i+1
	end

	love.graphics.print( "parameter", 5, 200+14)
	i=2
	for k,v in pairs(parameterList) do
		parameterList[k]=_G[k]
		love.graphics.print( k, 5, 200+14*i)
		love.graphics.print( tostring(v), 80, 200+14*i)
		i=i+1
	end

	love.graphics.print( "watch", 5, 400+14)
	i=2
	for k,v in pairs(watchList) do
		watchList[k]=_G[k]
		love.graphics.print( k, 5, 400+14*i)
		love.graphics.print( tostring(watchList[k]), 80, 400+14*i)
		i=i+1
	end

	love.graphics.print( "iwatch", 5, 600+14)
	i=2
	for k,v in pairs(iwatchList) do
		iwatchList[k]=_G[k]
		love.graphics.print( k, 5, 600+14*i)
		love.graphics.print( tostring(iwatchList[k]), 80, 600+14*i)
		i=i+1
	end

	-- print FPS
	love.graphics.setColor(255,0,0,255)
	love.graphics.print( "FPS: ", WIDTH-65, 14)
	love.graphics.print( love.timer.getFPS( ), WIDTH-35, 14)

	-- print Gravity
	love.graphics.print( "GravityX: ", WIDTH-92, 34)
	love.graphics.print( Gravity.x, WIDTH-35, 34)
	love.graphics.print( "GravityY: ", WIDTH-92, 54)
	love.graphics.print( Gravity.y, WIDTH-35, 54)
	love.graphics.print( "GravityZ: ", WIDTH-92, 74)
	love.graphics.print( Gravity.z, WIDTH-35, 74)
    end -- if (LOVECODIFYHUD)
    
	-- in love we have to reset the color after drawing
	_resetColor()
end

-- initial before main is called
WIDTH=love.graphics.getWidth()
HEIGHT=love.graphics.getHeight()
