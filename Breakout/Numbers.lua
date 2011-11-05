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
	end
end
