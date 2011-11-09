-- Classic 3d wireframe cube demo in LUA
-- based on version for PSP by Nils - ventoline.com
-- modified for Codea - Tom Bortels November 2011
-- got it from here: https://gist.github.com/1334810
if dofile ~= nil then
	dofile ("loveCodify.lua")
end

function setup() 
--focal length to determine perspective scaling
focalLength = 300

-- here we set up a function to make an object with 
-- x, y and z properties to represent a 3D point.  
make3DPoint = function(x,y,z)
   local point = {}
   point.x = x
   point.y = y
   point.z = z
   return point
   end

-- similarly set up a function to make an object with 
-- x and y properties to represent a 2D point.
make2DPoint = function(x, y)
   local point = {}
   point.x = x+240
   point.y = y+131
   return point
   end

-- conversion function for changing an array of 3D points to an
-- array of 2D points which is to be returned.
Transform3DPointsTo2DPoints = function(points, axisRotations)
   -- the array to hold transformed 2D points - the 3D points
   -- from the point array which are here rotated and scaled
   --to generate a point as it would appear on the screen
   local TransformedPointsArray = {}
   -- Math calcs for angles - sin and cos for each (trig)
   -- this will be the only time sin or cos is used for the
   -- entire portion of calculating all rotations
   local sx = math.sin(axisRotations.x)
   local cx = math.cos(axisRotations.x)
   local sy = math.sin(axisRotations.y)
   local cy = math.cos(axisRotations.y)
   local sz = math.sin(axisRotations.z)
   local cz = math.cos(axisRotations.z)
   
   -- a couple of variables to be used in the looping
   -- of all the points in the transform process
   local x,y,z, xy,xz, yx,yz, zx,zy, scaleRatio

   -- loop through all the points in your object/scene/space
   -- whatever - those points passed - so each is transformed
   local i = table.getn(points)
   while (i >0) do
      --apply Math to making transformations
      -- based on rotations
      -- assign variables for the current x, y and z
      x = points[i].x
      y = points[i].y
      z = points[i].z

      -- perform the rotations around each axis
      -- rotation around x
      xy = cx*y - sx*z
      xz = sx*y + cx*z
      -- rotation around y
      yz = cy*xz - sy*x
      yx = sy*xz + cy*x
      -- rotation around z
      zx = cz*yx - sz*xy
      zy = sz*yx + cz*xy

      -- now determine perspective scaling factor
      -- yz was the last calculated z value so its the
      -- final value for z depth
      scaleRatio = focalLength/(focalLength + yz)
      -- assign the new x and y
      x = zx*scaleRatio
      y = zy*scaleRatio
      -- create transformed 2D point with the calculated values
      -- adding it to the array holding all 2D points
      TransformedPointsArray[i] = make2DPoint(x, y)
   i = i -1
   end
   -- after looping return the array of points as they
   -- exist after the rotation and scaling
   return TransformedPointsArray
end

-- the points array contains all the points in the 3D
-- scene.  These 8 make a square on the screen.
pointsArray = {
make3DPoint(-50,-50,-50),
make3DPoint(50,-50,-50),
make3DPoint(50,-50,50),
make3DPoint(-50,-50,50),
make3DPoint(-50,50,-50),
make3DPoint(50,50,-50),
make3DPoint(50,50,50),
make3DPoint(-50,50,50),
}

   -- initial decays of 3D cube
   userX = - 0.01
   userY =  0.01
   cubeAxisRotations = make3DPoint(0,0,0)
end -- init()

function draw()
   cubeAxisRotations.y = cubeAxisRotations.y + userY
   cubeAxisRotations.x = cubeAxisRotations.x + userX
   -- create a new array to contain the 2D x and y positions of the
   -- points in the pointsArray as they would exist on the screen
   local sp = Transform3DPointsTo2DPoints(pointsArray, cubeAxisRotations)
   -- clear the scene
   background(0, 0, 0, 255)
   scale(2)
   strokeWidth(5)
   -- draw the lines needed to make the square
   -- top
   stroke(0, 255, 0, 255) -- green
   line(sp[1].x, sp[1].y, sp[2].x, sp[2].y)
   line(sp[2].x, sp[2].y, sp[3].x, sp[3].y)
   line(sp[3].x, sp[3].y, sp[4].x, sp[4].y)
   line(sp[4].x, sp[4].y, sp[1].x, sp[1].y)
   -- bottom
   stroke(255, 0, 0, 255) -- red
   line(sp[5].x, sp[5].y, sp[6].x, sp[6].y)
   line(sp[6].x, sp[6].y, sp[7].x, sp[7].y)
   line(sp[7].x, sp[7].y, sp[8].x, sp[8].y)
   line(sp[8].x, sp[8].y, sp[5].x, sp[5].y)
   -- connecting bottom and top
   stroke(255, 255, 255, 255) -- white
   line(sp[1].x, sp[1].y, sp[5].x, sp[5].y)
   line(sp[2].x, sp[2].y, sp[6].x, sp[6].y)
   stroke(0, 0, 255, 255) -- blue
   line(sp[3].x, sp[3].y, sp[7].x, sp[7].y)
   line(sp[4].x, sp[4].y, sp[8].x, sp[8].y)
end
