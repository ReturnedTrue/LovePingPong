local Vector2 = {}
Vector2.__index = Vector2

function Vector2.new(x, y)
    local self = setmetatable({}, Vector2)

    self.x = x or 0
    self.y = y or 0

    return self
end

function Vector2:unload()
    return self.x, self.y
end

function Vector2:__add(secondVector)
    return Vector2.new(
        self.x + secondVector.x,
        self.y + secondVector.y
    )
end

function Vector2:__sub(secondVector)
    return Vector2.new(
        self.x - secondVector.x,
        self.y - secondVector.y
    )
end

function Vector2:__mul(secondVector)
    return Vector2.new(
        self.x * secondVector.x,
        self.y * secondVector.y
    )
end

return Vector2