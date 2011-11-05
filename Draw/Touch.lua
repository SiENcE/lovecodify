Touches = class()

function Touches:init()
    -- you can accept and set parameters here
    self.touches = {}
end

function Touches:add(t)
    table.insert(self.touches, {t})
end

function Touches:expand(t)
    table.insert(self.touches[#self.touches],t)
end

function Touches:draw()
    local last
    if #self.touches > 0 then
        for i,v in ipairs(self.touches) do
            last = v[1]
            for j,w in ipairs(v) do
                line(last.x,last.y,w.x,w.y)
                last = w
            end
        end
    end
end
