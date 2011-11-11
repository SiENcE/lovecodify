-- Magic Gems by @juaxix
-- LGPL Juan Belón Pérez
-- http://videojuegos.ser3d.es
-- 11/2011
if dofile ~= nil then
	dofile ("loveCodify.lua")
	dofile ("Gems/Board.lua")
	dofile ("Gems/Gem.lua")
	dofile ("Gems/Bar.lua")
	dofile ("Gems/Magic.lua")
end

function setup()
	maxGemsRow = 7
	maxGemsCol = 7
	currentLvl = 1
	score	= 0
	curGemColor= 4
	maxGemColor= 8
	gemsCleared= 0
	board	= Board()
	bar	= Bar()
	magic	= Magic(66)
	casting	= false
end

function draw()
	background(47, 145, 216, 255)
	board:draw()
	bar:draw()
	-- level and score numbers
	noSmooth()
	stroke(255, 255, 255, 255)
	strokeWidth(2)
	sprite("Small World:Treasure",16, HEIGHT - 16)
	number(42, HEIGHT - 6, score, 10)
	sprite("Small World:Sign",WIDTH-33,HEIGHT - 29,60)
	number(WIDTH - 47, HEIGHT - 10,"L"..currentLvl, 8)
	if casting then
		magic:draw()
	end
end

function touched(touch)
	if touch.state == ENDED then
		if touch.x<99 or touch.x>696 then
			casting = false
			return nil
		end
		if touch.y>610 then
			bar:touched(touch)
			casting = false
		elseif touch.x>75 and touch.y>53 and touch.x<696 and touch.y<555 then
			casting = true
			board:touched(touch)
		end
	end
end

-----------------------------------
-- Functions for drawing numbers --
-----------------------------------


-- Draw a number. x, y is top left
function number(x, y, n, w)
	l = string.len(n)
	for i = 1, l do
		drawDigit(x + ((i - 1) * (w * 1.5)), y, string.sub(n, i, i), w)
	end
end

-- Draw a single digit
function drawDigit(x, y, n, w)
h = 2 * w
if string.match(n, "1") then
line(x + (w / 2), y, x + (w / 2), y - h)
elseif string.match(n, "2") then
line(x, y, x + w, y)
line(x + w, y, x + w, y - (h / 2))
line(x + w, y - (h / 2), x, y - (h / 2))
line(x, y - (h / 2), x, y - h)
line(x, y - h, x + w, y - h)
elseif string.match(n, "3") then
line(x, y, x + w, y)
line(x + w, y, x + w, y - h)
line(x + w, y - h, x, y - h)
line(x, y - (h / 2), x + w, y - (h / 2))
elseif string.match(n, "4") then
line(x, y, x, y - (h / 2))
line(x, y - (h / 2), x + w, y - (h / 2))
line(x + w, y, x + w, y - h)
elseif string.match(n, "5") then
line(x + w, y, x, y)
line(x, y, x, y - (h / 2))
line(x, y - (h / 2), x + w, y - (h / 2))
line(x + w, y - (h / 2), x + w, y - h)
line(x + w, y - h, x, y - h)
elseif string.match(n, "6") then
line(x + w, y, x, y)
line(x, y, x, y - h)
line(x, y - h, x + w, y - h)
line(x + w, y - h, x + w, y - (h / 2))
line(x + w, y - (h / 2), x, y - (h / 2))
elseif string.match(n, "7") then
line(x, y, x + w, y)
line(x + w, y, x + w, y - h)
elseif string.match(n, "8") then
line(x, y, x + w, y)
line(x + w, y, x + w, y - h)
line(x + w, y - h, x, y - h)
line(x, y - h, x, y)
line(x, y - (h / 2), x + w, y - (h / 2))
elseif string.match(n, "9") then
line(x + w, y - (h / 2), x, y - (h / 2))
line(x, y - (h / 2), x, y)
line(x, y, x + w, y)
line(x + w, y, x + w, y - h)
line(x + w, y - h, x, y - h)
elseif string.match(n, "0") then
line(x, y, x + w, y)
line(x + w, y, x + w, y - h)
line(x + w, y - h, x, y - h)
line(x, y - h, x, y)
elseif string.match(n, "x") then
line(x, y - (w / 3), x + w, y - (h + 1))
line(x + w, y - (w / 3), x, y - (h + 1))
elseif string.match(n,"L") then
line(x - (w/6), y, x - (w/6), y - h)
line(x + w, y - h, x, y - h)
elseif string.match(n, "-") then
line(x, y - (h/2), x+w, y -(h/2))
end
end

