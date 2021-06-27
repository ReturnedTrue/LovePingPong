local Vector2 = require("classes/Vector2")
local Object = require("classes/Object")
local Player = require("classes/Player")

local WINDOW_SIZE = Vector2.new(love.graphics.getDimensions())
local PADDLE_SIZE = Vector2.new(WINDOW_SIZE.x * 0.025, WINDOW_SIZE.y * 0.1)
local LINE_WIDTH = WINDOW_SIZE.x * 0.01

local ball = Object.new(
    Vector2.new(), 
    Vector2.new()
)

local player1 = Player.new(
    0, 
    Object.new(
        Vector2.new(LINE_WIDTH, (WINDOW_SIZE.y / 2) - PADDLE_SIZE.y), 
        Vector2.new(),
        PADDLE_SIZE
    )
)

local player2 = Player.new(
    0, 
    Object.new(
        Vector2.new(WINDOW_SIZE.x - (PADDLE_SIZE.x + LINE_WIDTH), (WINDOW_SIZE.x / 2) - PADDLE_SIZE.y), 
        Vector2.new(),
        PADDLE_SIZE
    )
)

local keyVelocities = {
    p1 = {
        w = Vector2.new(0, -5),
        s = Vector2.new(0, 5)
    },

    p2 = {
        up = Vector2.new(0, -5),
        down = Vector2.new(0, 5)
    }
}


function love.keypressed(key)
    local p1Velocity = keyVelocities.p1[key]
    local p2Velocity = keyVelocities.p2[key]

    if (p1Velocity) then
        player1.paddle.velocity = player1.paddle.velocity + p1Velocity
    elseif (p2Velocity) then
        player2.paddle.velocity = player2.paddle.velocity + p2Velocity 
    end
end

function love.keyreleased(key)
    local p1Velocity = keyVelocities.p1[key]
    local p2Velocity = keyVelocities.p2[key]

    if (p1Velocity) then
        player1.paddle.velocity = player1.paddle.velocity - p1Velocity
    elseif (p2Velocity) then
        player2.paddle.velocity = player2.paddle.velocity - p2Velocity 
    end
end

function love.update()
    local p1Next = player1.paddle:getNextPosition()
    local p2Next = player2.paddle:getNextPosition()

    if (p1Next.y > 0 and WINDOW_SIZE.y > (p1Next.y + PADDLE_SIZE.y)) then
        player1.paddle.position = p1Next
    end

    if (p2Next.y > 0 and WINDOW_SIZE.y > (p2Next.y + PADDLE_SIZE.y)) then
        player2.paddle.position = p2Next
    end
end

function love.draw()
    love.graphics.rectangle("fill", player1.paddle:unload())
    love.graphics.rectangle("fill", player2.paddle:unload())
end

