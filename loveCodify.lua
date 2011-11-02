-- LoveCodify is a Wrapper Class to run Codify/Codea Scripts with Love2D
-- by Florian^SiENcE^schattenkind.net
--
-- You can use the http://love2d.org/ runtime to code Codify Apps on MacOSX/Linux/Windows.
-- Beware, it's unfinished, but samples are running.
--
-- Just include the this in your Codify project:
-- dofile ("loveCodify.lua")

-------------------
-- Drawing
-------------------

iparameterList = {}
parameterList = {}

CurrentTouch = {}
CurrentTouch.x = 0
CurrentTouch.y = 0

Gravity = {}
Gravity.x = 0
Gravity.y = 0

--fill
--Draw filled shape.
--line
--Draw outlined shape.
fillMode="line"

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
		love.graphics.setBackgroundColor( red, red, red, 1)
	elseif (red.r and red.g and red.b) then
		love.graphics.setBackgroundColor( red.r, red.g, red.b)
	end
end

function ellipse(x,y,width,heigt)
	love.graphics.circle( fillMode, x, y, width/2 )
	love.graphics.setColor(255,255,255,255)
end

function line(x1,y1,x2,y2)
--number width
--The width of the line.
--LineStyle style ("smooth")
--The LineStyle to use.
	
	--fix for codify, love2d does not paint a line if values are the same
	if (x1==x2 and y1==y2) then
		love.graphics.line( x1, y1, x2+1, y2+1)
	else
		love.graphics.line( x1, y1, x2, y2)
	end
	-- in love we have to reset the color after drawing
	love.graphics.setColor(255,255,255,255)
end

function rect(x,y,width,height)
	love.graphics.rectangle(fillMode,x,y,width,height)
	-- in love we have to reset the color after drawing
	love.graphics.setColor(255,255,255,255)
end

function sprite(filename,x,y,width,height)
	image = love.graphics.newImage( filename )
	love.graphics.draw( image, x, y, 0, 0, 0, 0, 0 )
end

-------------------
-- Transform
-------------------
function translate(dx, dy)
	love.graphics.translate( dx, dy )
end

function rotate()
end

-------------------
-- Transform Management
-------------------
function pushMatrix()
	love.graphics.push()
end

function popMatrix()
	love.graphics.pop()
end

-------------------
-- Sound
-------------------
function sound(name)
end

-------------------
-- Style
-------------------
function ellipseMode(mode)
end

-- fills elipse & rect
function fill(red,green,blue,alpha)
	if (red and green and blue and alpha) then
		love.graphics.setColor( red, green, blue, alpha)
	elseif (red and green and blue) then
		love.graphics.setColor( red, green, blue, 1)
	elseif (type(red) == "number" and type(green) == "number") then
		love.graphics.setColor( red, red, red, green)
	elseif (type(red) == "number") then
		love.graphics.setColor( red, red, red, 1)
	elseif (red.r and red.g and red.b and red.a) then
		love.graphics.setColor( red.r, red.g, red.b, red.a)
	end
	fillMode = "fill"
end

function lineCapMode(mode)
-- ROUND | SQUARE | PROJECT
end

function noSmooth()
end
function noFill()
	fillmode = "line"
end
function noStroke()
end
function noTint()
end

function smooth()
end

function stroke(red,green,blue,alpha)
	if (red and green and blue and alpha) then
		love.graphics.setColor( red, green, blue, alpha)
	elseif (red and green and blue) then
		love.graphics.setColor( red, green, blue, 1)
	elseif (type(red) == "number" and type(green) == "number") then
		love.graphics.setColor( red, red, red, green)
	elseif (type(red) == "number") then
		love.graphics.setColor( red, red, red, 1)
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
		love.graphics.setColor( red, green, blue, 1)
	elseif (type(red) == "number" and type(green) == "number") then
		love.graphics.setColor( red, red, red, green)
	elseif (type(red) == "number") then
		love.graphics.setColor( red, red, red, 1)
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

function watch()
end

-------------------
-- Touch
-------------------
-- already done in love.update(dt)

-------------------
-- love functions
-------------------
function love.load()
	setup()
end

function love.update(dt)
	if love.mouse.isDown("l") then
		-- get Mouse position as Touch position
		-- publish globally
		CurrentTouch.x = love.mouse.getX()
		CurrentTouch.y = love.mouse.getY()
		
		-- publish to touched callback
		local touch = {}
		touch.x = CurrentTouch.x
		touch.y = CurrentTouch.y
		if touched then touched(touch) end
	end

	if love.mouse.isDown("r") then
		Gravity.x = Gravity.x + 0.01
		Gravity.y = Gravity.y + 0.01
	end
end

function love.draw()
	draw()

	love.graphics.setColor( 125, 125, 125)
	love.graphics.print( "iparameter", 5, 14)
	local i=2
	for k,v in pairs(iparameterList) do
		iparameterList[k]=_G[k]
		love.graphics.print( k, 5, 14*i)
		love.graphics.print( tostring(v), 80, 14*i)
		i=i+1
	end
	
	love.graphics.print( "parameter", 5, 300+14)
	i=2
	for k,v in pairs(parameterList) do
		parameterList[k]=_G[k]
		love.graphics.print( k, 5, 300+14*i)
		love.graphics.print( tostring(v), 80, 300+14*i)
		i=i+1
	end
	
	-- in love we have to reset the color after drawing
	love.graphics.setColor(255,255,255,255)
end

-- initial before main is called
WIDTH=love.graphics.getWidth()
HEIGHT=love.graphics.getHeight()
