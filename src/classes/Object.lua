local Object = {}
Object.__index = Object

function Object.new(position, velocity, size)
    local self = setmetatable({}, Object)

    self.position = position
    self.velocity = velocity
    self.size = size

    return self
end

function Object:inverseXVelocity(multiplier)
    self.velocity.x = self.velocity.x * -multiplier
end

function Object:getNextPosition()
    return self.position + self.velocity
end

function Object:unload()
    local pos = self.position
    local size = self.size

    if (size) then
        return pos.x, pos.y, size.x, size.y
    else
        return pos.x, pos.y
    end
end

return Object