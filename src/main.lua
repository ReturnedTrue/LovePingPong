local Vector2 = require("classes/Vector2")
local Object = require("classes/Object")
local Player = require("classes/Player")

local WINDOW_SIZE = Vector2.new(love.graphics.getDimensions())
local PADDLE_SIZE = Vector2.new(WINDOW_SIZE.x * 0.01, WINDOW_SIZE.y * 0.1)

local LINE_WIDTH = WINDOW_SIZE.x * 0.01
local BALL_RADIUS = WINDOW_SIZE.x * 0.025

local ball = Object.new(
    Vector2.new(), 
    Vector2.new(),
    Vector2.new(BALL_RADIUS, 100)
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

local players = {player1, player2}

local keyVelocities = {
    w = {1, Vector2.new(0, -5)},
    s = {1, Vector2.new(0, 5)},

    up = {2, Vector2.new(0, -5)},
    down = {2, Vector2.new(0, 5)},
}

local gameStarted = false

local function spawnBall(rightSide)
    ball.position = Vector2.new(WINDOW_SIZE.x / 2, WINDOW_SIZE.y / 2)

    local newVelocity = Vector2.new(
        math.random(2, 4),
        math.random(1, 3)
    )

    if (rightSide) then
        newVelocity.x = -newVelocity.x
    end

    ball.velocity = newVelocity
end

function love.load()    
    love.window.setTitle("Ping Pong")


    spawnBall()
end

function love.keypressed(key)
    if (key == "return" and (not gameStarted)) then
        gameStarted = true
        return
    end

    local velocityData = keyVelocities[key]

    if (velocityData) then
        local player = players[velocityData[1]]

        player.paddle.velocity = player.paddle.velocity + velocityData[2]
    end
end

function love.keyreleased(key)
    local velocityData = keyVelocities[key]

    if (velocityData) then
        local player = players[velocityData[1]]

        player.paddle.velocity = player.paddle.velocity - velocityData[2]
    end
end

function love.update()  
    if (not (love.window.hasFocus() or gameStarted)) then
        return
    end
    
    ball.position = ball:getNextPosition()

    if (BALL_RADIUS >= ball.position.y or (BALL_RADIUS + ball.position.y) >= WINDOW_SIZE.y) then
        ball.velocity.y = -ball.velocity.y
    end
    
    for i = 1, 2 do
        local player = players[i]
        local nextPosition = player.paddle:getNextPosition()
        local nextY = nextPosition.y

        if (nextY > 0 and WINDOW_SIZE.y > (nextY + PADDLE_SIZE.y)) then
            player.paddle.position = nextPosition
        end
    end

    if (player1.paddle.position.x >= (ball.position.x - BALL_RADIUS - PADDLE_SIZE.x)) then
        local fullY = player1.paddle.position.y + PADDLE_SIZE.y

        if (ball.position.y >= player1.paddle.position.y and fullY >= ball.position.y) then
            ball:inverseXVelocity(1.1)
        else
            player2:addPoint()
            spawnBall(false)
        end
    end

    if ((ball.position.x + BALL_RADIUS) >= player2.paddle.position.x) then
        local fullY = player2.paddle.position.y + PADDLE_SIZE.y

        if (ball.position.y >= player2.paddle.position.y and fullY >= ball.position.y) then
            ball:inverseXVelocity(1.1)
        else 
            player1:addPoint()
            spawnBall(true)
        end
    end
end

function love.draw()
    if (not gameStarted) then
        love.graphics.print("Press enter to start the game", WINDOW_SIZE.x / 2, WINDOW_SIZE.y / 2)
        return
    end

    love.graphics.setColor(1, 1, 1)

    local fps = love.timer.getFPS()
    love.graphics.print(("%d FPS"):format(fps))

    for _, player in ipairs(players) do
        love.graphics.rectangle("fill", player.paddle:unload())
    end

    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("fill", ball:unload())
end

