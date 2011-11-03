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
		love.graphics.setBackgroundColor( red, red, red, 1)
	elseif (red.r and red.g and red.b) then
		love.graphics.setBackgroundColor( red.r, red.g, red.b)
	end
end

function ellipse(x,y,width,heigt)
	love.graphics.circle( fillMode, x, y, width/2 )
--	love.graphics.setColor(255,255,255,255)
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
	lineCapsMode = mode
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

function rectMode(mode)
	rectangleMode=mode
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
		--TODO: lastPosition check
		--CurrentTouch.state = BEGAN

		-- get Mouse position as Touch position
		-- publish globally
		CurrentTouch.x = love.mouse.getX()
		CurrentTouch.y = love.mouse.getY()
		CurrentTouch.state = MOVING
		
		-- publish to touched callback
		local touch = {}
		touch.x = CurrentTouch.x
		touch.y = CurrentTouch.y
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

	-- print FPS
	love.graphics.setColor(255,0,0,255)
	love.graphics.print( "FPS: ", WIDTH-65, 14)
	love.graphics.print( love.timer.getFPS( ), WIDTH-35, 14)

	-- print Gravity
	love.graphics.print( "GravityX: ", WIDTH-92, 34)
	love.graphics.print( Gravity.x, WIDTH-35, 34)
	love.graphics.print( "GravityY: ", WIDTH-92, 54)
	love.graphics.print( Gravity.y, WIDTH-35, 54)
	-- in love we have to reset the color after drawing
	love.graphics.setColor(255,255,255,255)
end

-- initial before main is called
WIDTH=love.graphics.getWidth()
HEIGHT=love.graphics.getHeight()
