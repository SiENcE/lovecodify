if dofile ~= nil then
	dofile ("loveCodify.lua")
end

function setup()
	fpstimer=0
	gridpoint={}
	for a=1,39 do
		gridpoint[a]={}
		for b=1,29 do
			gridpoint[a][b]={x=20*a,y=20*b,xorig=20*a,
			yorig=20*b,direction=0,velocity=0,dir2=0,vel2=0}
		end
	end
end

function update(dt)
	fpstimer=fpstimer+dt
	if fpstimer>1/75 then
		fpstimer=fpstimer-1/75
		for a=1,39 do
			for b=1,29 do
				if CurrentTouch.state == MOVING then
					gridpoint[a][b].direction=
					math.atan2( CurrentTouch.y - gridpoint[a][b].y, CurrentTouch.x - gridpoint[a][b].x )
					gridpoint[a][b].velocity=
					500/math.sqrt(( CurrentTouch.y - gridpoint[a][b].y )^2 + ( CurrentTouch.x - gridpoint[a][b].x)^2 )
					if gridpoint[a][b].velocity>10 then gridpoint[a][b].velocity=10 end
				end
				
				gridpoint[a][b].dir2=math.atan2(gridpoint[a][b].yorig-gridpoint[a][b].y,gridpoint[a][b].xorig-gridpoint[a][b].x)
				gridpoint[a][b].vel2=math.sqrt((gridpoint[a][b].yorig-gridpoint[a][b].y)^2+(gridpoint[a][b].xorig-gridpoint[a][b].x)^2)*0.1
				
				if CurrentTouch.state == MOVING then
					gridpoint[a][b].x=gridpoint[a][b].x+gridpoint[a][b].velocity*math.cos(gridpoint[a][b].direction)+gridpoint[a][b].vel2*math.cos(gridpoint[a][b].dir2)
					gridpoint[a][b].y=gridpoint[a][b].y+gridpoint[a][b].velocity*math.sin(gridpoint[a][b].direction)+gridpoint[a][b].vel2*math.sin(gridpoint[a][b].dir2)
				else
					gridpoint[a][b].x=gridpoint[a][b].x+gridpoint[a][b].vel2*math.cos(gridpoint[a][b].dir2)
					gridpoint[a][b].y=gridpoint[a][b].y+gridpoint[a][b].vel2*math.sin(gridpoint[a][b].dir2)
				end
			end
		end
	end
end

function draw()
	update(1)
	fill(100,100,100,100)
	for a=1,39 do
		for b=1,29 do
			ellipse(gridpoint[a][b].x,gridpoint[a][b].y,4)
		end
	end
	
	for a=1,38 do
		for b=1,28 do
			tint(100,100,100+155*(gridpoint[a][b].velocity/10),100+155*(gridpoint[a][b].velocity/10))
			line(gridpoint[a][b].x,gridpoint[a][b].y,gridpoint[a+1][b].x,gridpoint[a+1][b].y)
			line(gridpoint[a][b].x,gridpoint[a][b].y,gridpoint[a][b+1].x,gridpoint[a][b+1].y)
		end
	end
end
