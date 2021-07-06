local Vector2 = require("classes/Vector2")
local Object = require("classes/Object")
local Player = require("classes/Player")
local Message = require("classes/Message")

local WINDOW_SIZE = Vector2.new(love.graphics.getDimensions())
local PADDLE_SIZE = Vector2.new(WINDOW_SIZE.x * 0.01, WINDOW_SIZE.y * 0.15)

local LINE_WIDTH = WINDOW_SIZE.x * 0.005
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
local playerNames = {"Player one", "Player two"}

local keyVelocities = {
    w = {player1, Vector2.new(0, -5)},
    s = {player1, Vector2.new(0, 5)},

    up = {player2, Vector2.new(0, -5)},
    down = {player2, Vector2.new(0, 5)},
}

local state = {
    started = false,
    paused = false
}

local loaded = {
    fonts = {},
    messages = {},
}

local function spawnBall(rightSide)
    ball.position = Vector2.new(WINDOW_SIZE.x / 2, WINDOW_SIZE.y / 2)

    local newVelocity = Vector2.new(
        math.random(2, 3),
        math.random(2, 3)
    )

    if (rightSide) then
        newVelocity.x = -newVelocity.x
    end

    if (math.random(1, 2) == 1) then
        newVelocity.y = -newVelocity.y
    end

    ball.velocity = newVelocity
end

local function updatePlayerScore(playerNumber, type, value)
    local player = players[playerNumber]
    local name = playerNames[playerNumber]
    local message = loaded.messages["p" .. playerNumber .. "Score"]

    if (type == "set") then
        player.score = value
    elseif (type == "increment") then
        player.score = player.score + value
    end

    message:updateText(("%s: %d"):format(name, player.score))
end

function love.load()    
    love.window.setTitle("Ping Pong")

    loaded.fonts = {
        large = love.graphics.newFont("fonts/Android101/Android101.ttf", 24),
        medium = love.graphics.newFont("fonts/Android101/Android101.ttf", 16)
    }

    loaded.messages = {
        start = Message.new("Press enter to start the game", loaded.fonts.large, true)
            :setPosition(Vector2.new(WINDOW_SIZE.x / 2, WINDOW_SIZE.y / 2)),

        controls = Message.new("Controls:\nW, S - Player one\nUp, Down - Player two\nP - Pause\nR - Reset", loaded.fonts.medium, true)
            :setPosition(Vector2.new(WINDOW_SIZE.x / 2, WINDOW_SIZE.y * 0.6)),

        paused = Message.new("PAUSED", loaded.fonts.large, false)
            :setPosition(Vector2.new(0, WINDOW_SIZE.y * 0.925)),

        fps = Message.new("0 FPS", loaded.fonts.medium, false),

        p1Score = Message.new("Player one: 0", loaded.fonts.medium, true)
            :setPosition(Vector2.new(WINDOW_SIZE.x * 0.25, WINDOW_SIZE.y * 0.1)),

        p2Score = Message.new("Player two: 0", loaded.fonts.medium, true)
            :setPosition(Vector2.new(WINDOW_SIZE.x * 0.75, WINDOW_SIZE.y * 0.1)),
    }

    spawnBall()
end

function love.update()  
    if (not (love.window.hasFocus() and state.started)) then
        return
    elseif (state.paused) then
        return
    end
    
    local fpsText = ("%d FPS"):format(love.timer.getFPS())
    loaded.messages.fps:updateText(fpsText)

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
            updatePlayerScore(2, "increment", 1)
            spawnBall(false)
        end
    end

    if ((ball.position.x + BALL_RADIUS) >= player2.paddle.position.x) then
        local fullY = player2.paddle.position.y + PADDLE_SIZE.y

        if (ball.position.y >= player2.paddle.position.y and fullY >= ball.position.y) then
            ball:inverseXVelocity(1.1)
        else 
            updatePlayerScore(1, "increment", 1)
            spawnBall(true)
        end
    end
end

function love.draw()
    if (not state.started) then
        love.graphics.print(loaded.messages.start:unload())   
        love.graphics.print(loaded.messages.controls:unload())
        return
    end

    love.graphics.setColor(1, 1, 1)

    if (state.paused) then
        love.graphics.print(loaded.messages.paused:unload())
    end

    love.graphics.print(loaded.messages.fps:unload())
    love.graphics.print(loaded.messages.p1Score:unload())
    love.graphics.print(loaded.messages.p2Score:unload())

    for _, player in ipairs(players) do
        love.graphics.rectangle("fill", player.paddle:unload())
    end

    local middleX = (WINDOW_SIZE.x / 2) - LINE_WIDTH

    love.graphics.setLineWidth(LINE_WIDTH)
    love.graphics.line(middleX, 0, middleX, WINDOW_SIZE.y)
    love.graphics.circle("fill", middleX, WINDOW_SIZE.y / 2, WINDOW_SIZE.x * 0.05)

    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("fill", ball:unload())
end

function love.keypressed(key)
    if (key == "return" and (not state.started)) then
        state.started = true
        return
    elseif (key == "p") then
        state.paused = not state.paused
    elseif (key == "r") then
        updatePlayerScore(1, "set", 0)
        updatePlayerScore(2, "set", 0)

        spawnBall(math.random(1, 2) == 1)
    end

    local velocityData = keyVelocities[key]

    if (velocityData) then
        local player = velocityData[1]

        player.paddle.velocity = player.paddle.velocity + velocityData[2]
    end
end

function love.keyreleased(key)
    local velocityData = keyVelocities[key]

    if (velocityData) then
        local player = velocityData[1]

        player.paddle.velocity = player.paddle.velocity - velocityData[2]
    end
end