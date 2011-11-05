---------------
-- Bat Class --
---------------

Bat = class()

function Bat:init()
	self.pos = vec2(350, 20)
	self.size = vec2(85, 20)
end

function Bat:draw()
	fill(167, 170, 186, 255)
	noStroke()
	rectMode(CENTER)
	ellipse(self.pos.x - self.size.x / 2 + 5, self.pos.y, 24)
	ellipse(self.pos.x + self.size.x / 2 - 5, self.pos.y, 24)
	rect(self.pos.x, self.pos.y, self.size.x, self.size.y)
end

function Bat:collide(ball)
	if ball:left() <= self:right() and
		ball:right() >= self:left() and
		ball:top() >= self:bottom() and
		ball:bottom() <= self:top() then
		sound(SOUND_JUMP)
		ball.vel.y = -ball.vel.y
		-- change the x velocity depending on where the ball hit the bat
		ball.pos.y = self:top() + ball.radius
		pos = ball.pos.x - self.pos.x
		ball.vel.x = pos / 10
		return true
	end
	return false
end

function Bat:left()
	return self.pos.x - self.size.x / 2
end

function Bat:right()
	return self.pos.x + self.size.x / 2
end

function Bat:top()
	return self.pos.y + self.size.y / 2
end

function Bat:bottom()
	return self.pos.y - self.size.y / 2
end


----------------
-- Ball Class --
----------------

Ball = class()

function Ball:init()
	self.pos = vec2(WIDTH / 2, 41)
	self.radius = 10
	self.vel = vec2(0, 7)
end

function Ball:draw()
	fill(253, 255, 0, 255)
	noStroke()
	ellipse(self.pos.x, self.pos.y, 2 * self.radius)
end

function Ball:update()
	self.pos = self.pos + self.vel
	if (self.pos.x + self.radius) >= WIDTH then
		self.pos.x = WIDTH - self.radius
		self.vel.x = -self.vel.x
		sound(SOUND_JUMP)
	elseif (self.pos.x - self.radius) <= 0 then
		self.pos.x = self.radius
		self.vel.x = -self.vel.x
		sound(SOUND_JUMP)
	elseif (self.pos.y + self.radius) >= HEIGHT then
		self.pos.y = HEIGHT - self.radius
		self.vel.y = -self.vel.y
		sound(SOUND_JUMP)
	elseif (self.pos.y - self.radius) <= 0 then
		self.pos.y = self.radius
		self.vel.y = -self.vel.y
		sound(SOUND_EXPLODE)
		return false
	end
	return true
end

function Ball:left()
	return self.pos.x - self.radius
end

function Ball:right()
	return self.pos.x + self.radius
end

function Ball:top()
	return self.pos.y + self.radius
end

function Ball:bottom()
	return self.pos.y - self.radius
end


-----------------
-- Block Class --
-----------------

Block = class()

function Block:init(x, y, col)
	self.pos = vec2(x, y)
	self.size = vec2(60,30)
	self.colour = col
end

function Block:draw()
	fill(self.colour)
	noStroke()
	rectMode(CENTER)
	rect(self.pos.x, self.pos.y, self.size.x, self.size.y)
end

function Block:collide(ball)
	if ball:left() <= self:right() and
		ball:right() >= self:left() and
		ball:top() >= self:bottom() and
		ball:bottom() <= self:top() then
		sound(SOUND_BLIT)
		if ball.pos.y <= self:top() and ball.pos.y >= self:bottom() then
			ball.vel.x = -ball.vel.x
		else
			ball.vel.y = -ball.vel.y
		end
		return true
	end
	return false
end

function Block:left()
	return self.pos.x - self.size.x / 2
end

function Block:right()
	return self.pos.x + self.size.x / 2
end

function Block:top()
	return self.pos.y + self.size.y / 2
end

function Block:bottom()
	return self.pos.y - self.size.y / 2
end
