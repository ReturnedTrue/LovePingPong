local Player = {}
Player.__index = Player

function Player.new(score, paddle)
    local self = setmetatable({}, Player)

    self.score = score
    self.paddle = paddle

    return self
end

return Player