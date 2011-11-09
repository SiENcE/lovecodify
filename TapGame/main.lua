-- http://twolivesleft.com/Codea/Talk/discussion/94/try-my-little-game-%3A-taptap...
-- http://pastebin.com/fu8eRLqE
if dofile ~= nil then
	dofile ("loveCodify.lua")
end

-------------------------
-- Main game functions --
-------------------------

board="........................."
mk=-1
score=0
bests=0
-- Use this function to perform your initial setup
function setup()
    iwatch("bests")
    iwatch("score")
    print("Tap blue diamonds and try to do the best score...")
end
-- This function gets called once every frame
function draw()
    background(109, 49, 210, 255)
    for i=0,5 do
        dt=74+i*120
        stroke(221, 126, 68, 255)
        strokeWidth(3)
        line(dt,74,dt,674)
        line(74,dt,674,dt)
    end
    for i=0,24 do
        sx=134+(i%5)*120
        sy=164+math.floor(i/5)*120
        pc=string.sub(board,i+1,i+1)
        if pc=="A" then
            sprite("Planet Cute:Gem Blue",sx,sy)
        end
        if pc=="B" then
            sprite("Planet Cute:Gem Orange",sx,sy)
        end
    end
    ck=math.floor(ElapsedTime)
    if ck~=mk then
        mk=ck
        if string.find(board,"A") then
            score = math.max(0,score - 50)
        end
        nb=math.random(1,math.min(25,1+math.floor(ElapsedTime/25)))
        board="........................."
        for i=1,nb do
            ps=math.random(1,25)
            while ps>0 do
                if string.sub(board,ps,ps)=="." then
                    if math.random(0,1)==1 then
                        pc="A"
                    else
                        pc="B"
                    end
                    board=string.sub(board,1,ps-1)..pc..string.sub(board,ps+1,25)
                    ps=0
                else
                    ps = ps + 1
                end
            end
        end
        --print(board)
    end
    if CurrentTouch.state==BEGAN then
        if  CurrentTouch.x>74 and CurrentTouch.x<674 and 
            CurrentTouch.y>74 and CurrentTouch.y<674 then
            ps=math.floor((CurrentTouch.y-74)/120)*5+
               math.floor((CurrentTouch.x-74)/120)+1
            pc=string.sub(board,ps,ps)
            if pc=="A" then
                score = score + 10
            end
            if pc=="B" then
                score = math.max(0,score - 100)
            end
            if pc~="." then
                board=string.sub(board,1,ps-1)
                    .."."..string.sub(board,ps+1,25)
                if score>bests then
                    bests=score
                end
            end
        end
    end
end
