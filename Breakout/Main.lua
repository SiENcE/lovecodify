-- got it from here
-- credits to voiceoftreason
-- http://twolivesleft.com/Codea/Talk/discussion/comment/46
-- https://gist.github.com/1328664
if dofile ~= nil then
	dofile ("loveCodify.lua")
	dofile ("Breakout/Game object classes.lua")
	dofile ("Breakout/Levels.lua")
	dofile ("Breakout/Numbers.lua")
end

-------------------------
-- Main game functions --
-------------------------

bat = nil
ball = nil
blocks = {}
score = 0
lives = 3
ballIsMoving = false
gameover = false
won = false
level = 1
maxlevel = table.maxn(levels)

-- Use this function to perform your initial setup
function setup()
	ball = Ball()
	ball.vel.x = math.random(-3,3)
	bat = Bat()
	makeBlocks()
	print("Tap the bat to lanch the ball.")
	print("Tap the far right side of the screen to move right, far left side to move left.")
	print("When the game is over tap the middle of the screen to restart.")
end

-- create table of blocks from level array
function makeBlocks()
	for i = 1, 6 do
		c = getColourForRow(i)
		for j = 1, 10 do
			if levels[level][i][j] > 0 then
				table.insert(blocks, Block(30 + (j * 62), HEIGHT - (i * 32 + 35), c))
			end
		end
	end
end

-- get colour for current row
function getColourForRow(row)
	colChanger = row * 35
	if level % 4 == 1 then
		c = color(colChanger,0,255,255)
	elseif level % 4 == 2 then
		c = color(255,colChanger,0,255)
	elseif level % 4 == 3 then
		c = color(255,0,colChanger,255)
	else
		c = color(0,255,colChanger,255)
	end
	return c
end

-- Stop ball and put it back on bat
function resetBall()
	ballIsMoving = false
	ball.pos.x = bat.pos.x
	ball.pos.y = 41
end

-- Reset game to original state
function resetGame()
	score = 0
	lives = 3
	level = 1
	blocks = {}
	makeBlocks()
	gameOver = false
	won = false
end

-- Level up
function nextLevel()
	score = score + 100 * lives * level
	--ball.vel.y = ball.vel.y + 0.5
	resetBall()
	if level < maxlevel then
		level = level + 1
		makeBlocks()
	else
		won = true
	end
end

-- Lose a life
function loseLife()
	resetBall()
	lives = lives - 1
	if lives == 0 then
		gameover = true
	end
end

-- This function gets called once every frame
function draw()
	background(0, 0, 0, 255)
	noSmooth()
	-- Handle touches
	handleTouch()
	-- Update the ball
	if ballIsMoving then
		if ball:update() == false then
			loseLife()
		end
	else
		ball.pos.x = bat.pos.x
	end
	-- Check collision with the bat
	if bat:collide(ball) == false then
		-- Check collision with the blocks - no need to do this if ball has hit bat. 
		-- Still does a lot of unecessary checks
		for i = 1, table.maxn(blocks) do
			if blocks[i]:collide(ball) then
				table.remove(blocks, i)
				score = score + 100
				if table.maxn(blocks) == 0 then
					nextLevel()
				end
				break
			end
		end
	end
	-- Draw game objects
	bat:draw()
	ball:draw()
	for i = 1, table.maxn(blocks) do
		blocks[i]:draw()
	end
	-- Draw score and lives
	stroke(255, 255, 255, 255)
	strokeWidth(2)
	number(10, HEIGHT - 10, score, 10)
	number(WIDTH - 30, HEIGHT - 10, "x"..lives, 8)
	noStroke()
	fill(253, 255, 0, 255)
	ellipse(WIDTH - 50, HEIGHT - 19, 20)
	-- Draw win/lose screen
	if gameover then
		lose(350,400)
	elseif won then
		win(340,400)
	end
end

function handleTouch()
	if CurrentTouch.state == BEGAN or
		CurrentTouch.state == MOVING then
		if gameover == false and won == false then
			-- If bat is touched launch ball
			if CurrentTouch.x < bat:right() + 10 and
				CurrentTouch.x > bat:left() - 10 and
				CurrentTouch.y < bat:top() + 20 and
				CurrentTouch.y > bat:bottom() then
				if ballIsMoving == false then
					ballIsMoving = true
				end
			-- If left/right of screen is touched move bat
			elseif CurrentTouch.x < 130 then
				if bat.pos.x > 20 then
					bat.pos.x = bat.pos.x - 5
				end
			elseif CurrentTouch.x > WIDTH - 130 then
				if bat.pos.x < WIDTH - 20 then
					bat.pos.x = bat.pos.x + 5
				end
			end
		elseif gameover == true or won == true then
			-- If centre of screen is touched restart game
			if CurrentTouch.y > 300 and CurrentTouch.y < 448 and
			CurrentTouch.x > 130 and CurrentTouch.x < WIDTH - 130 then
				resetGame()
			end
		end
	end
end

-- Write lose on the screen
function lose(x, y)
	strokeWidth(3)
	line(x, y, x, y - 40)
	line(x, y - 40, x + 20, y - 40)
	x = x + 30
	line(x, y, x, y - 40)
	line(x, y - 40, x + 20, y - 40)
	line(x + 20, y - 40, x + 20, y)
	line(x + 20, y, x, y)
	x = x + 30
	line(x + 20, y, x, y)
	line(x, y, x, y - 20)
	line(x, y - 20, x + 20, y - 20)
	line(x + 20, y - 20, x + 20, y - 40)
	line(x + 20, y - 40, x, y - 40)
	x = x + 30
	line(x + 20, y, x, y)
	line(x, y, x, y - 40)
	line(x, y - 40, x + 20, y - 40)
	line(x, y - 20, x + 20, y - 20)
end

-- Write win on the screen
function win(x, y)
	strokeWidth(3)
	line(x, y, x, y - 40)
	line(x, y - 40, x + 40, y - 40)
	line(x + 40, y - 40, x + 40, y)
	line(x + 20, y - 40, x + 20, y - 15)
	x = x + 45
	line(x + 10, y, x + 10, y - 40)
	x = x + 25
	line(x, y - 40, x, y)
	line(x, y, x + 25, y)
	line(x + 25, y, x + 25, y - 40)
end
