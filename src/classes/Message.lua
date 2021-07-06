local Vector2 = require("classes/Vector2")

local Message = {}
Message.__index = Message

function Message.new(text, font, centered)
    local self = setmetatable({}, Message)

    self.text = text
    self.font = font
    self.isCentered = centered

    self.position = Vector2.new()
    self.rotation = 0
    self.scaleFactor = Vector2.new(1, 1)
    
    if (centered) then
        self:_center()
    else
        self.offset = Vector2.new()
    end

    return self
end

function Message:_center()
    self.offset = Vector2.new(
        math.floor(self.font:getWidth(self.text) / 2),
        math.floor(self.font:getHeight() / 2)
    )
end

function Message:updateText(text)
    self.text = text

    if (self.isCentered) then
        self:_center()
    end
end

function Message:setPosition(vector)
    self.position = vector
    return self
end

function Message:setRotation(r)
    self.rotation = r
    return self
end

function Message:setScale(vector)
    self.scaleFactor = vector
    return self
end

function Message:unload()
    return self.text, self.font, self.position.x, self.position.y, self.rotation, self.scaleFactor.x, self.scaleFactor.y, self.offset.x, self.offset.y
end

return Message