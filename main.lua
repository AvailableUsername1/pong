push = require "push"
Class = require "class"
require "Ball"
require "Paddle"

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()
    math.randomseed(os.time())
    love.window.setTitle("Pong")
    love.graphics.setDefaultFilter("nearest", "nearest")

    smallFont = love.graphics.newFont("font.ttf", 8)
    love.graphics.setFont(smallFont)

    largeFont = love.graphics.newFont("font.ttf", 16)
    scoreFont = love.graphics.newFont("font.ttf", 32)

    player1Score = 0
    player2Score = 0

    servingPlayer = 1

    player1 = Paddle(15, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 20, VIRTUAL_HEIGHT - 50, 5, 20)

    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    gameState = "start"

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })
end

function love.update(dt)
    if gameState == "serve" then
        ball.dy = math.random(-50,50)
        if servingPlayer == 1 then
            ball.dx = math.random(140,200)
        elseif servingPlayer == 2 then
            ball.dx = -math.random(140,200)
        end
    elseif gameState == "play" then

        -- collision with player 1
        if ball:collides(player1) then
            ball.x = ball.x + 5
            ball.dx = -ball.dx * 1.03
            sounds.paddle_hit:play()

            if ball.dy <= 0 then
                ball.dy = math.random(-150, -10)
            else
                ball.dy = math.random(10, 150)
            end
        end
        
        -- with player 2
        if ball:collides(player2) then
            ball.x = ball.x - 5
            ball.dx = -ball.dx * 1.03
            sounds.paddle_hit:play()

            if ball.dy <= 0 then
                ball.dy = math.random(-150, -10)
            else
                ball.dy = math.random(10, 150)
            end
        end

        -- wall collision
        if ball.y <= 0 then
            ball.y = 1
            ball.dy = -ball.dy
            sounds.wall_hit:play()
        elseif ball.y >= VIRTUAL_HEIGHT - ball.height then
            ball.y = VIRTUAL_HEIGHT - 5
            ball.dy = -ball.dy
            sounds.wall_hit:play()
        end

        -- scoring against player 1
        if ball.x < -4 then
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds.score:play()
            if player2Score == 10 then
                gameState = "done"
                winner = 2
            else
                ball:reset()
                gameState = "serve"
            end
        end

        -- scoring against player 2
        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds.score:play()
            if player1Score == 10 then
                gameState = "done"
                winner = 1
            else
                ball:reset()
                gameState = "serve"
            end
        end
    end

        
    -- movement for player 1
    if love.keyboard.isDown("w") then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown("s") then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    --uncomment this and comment AI movement if you have 2 players
    --[[
    if love.keyboard.isDown("up") then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown("down") then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end
    ]]

    --AI movement for player 2
    if player2.y > ball.y then
        player2.y = player2.y - PADDLE_SPEED * dt
    elseif player2.y + player2.height < ball.y then
        player2.y = player2.y + PADDLE_SPEED * dt
    end

    player1:update(dt)
    player2:update(dt)
    if gameState == 'play' then
        ball:update(dt)
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "enter" or key == 'return' then
        if gameState == "start" then
            gameState = "serve"
        elseif gameState == "serve" then
            gameState = "play"
        elseif gameState == "done" then
            player1Score = 0
            player2Score = 0
            ball:reset()
            if winner == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
            gameState = "serve"
        end
    end
end

function love.resize(w, h)
    push:resize(w,h)
end

function love.draw()
    push:apply("start")
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    love.graphics.setFont(smallFont)
    if gameState == "start" then
        love.graphics.printf("Hello Pong!", 0, 10, VIRTUAL_WIDTH, "center")
        love.graphics.printf("Press Enter To Start!", 0, 20, VIRTUAL_WIDTH, "center")
    elseif gameState == "serve" then
        if servingPlayer == 1 then
            love.graphics.printf("Player's 1 turn to serve!", 0, 10, VIRTUAL_WIDTH, "center")
        elseif servingPlayer == 2 then
            love.graphics.printf("Player's 2 turn to serve!", 0, 10, VIRTUAL_WIDTH, "center")
        end
        love.graphics.printf("Press enter to serve!", 0, 20, VIRTUAL_WIDTH, "center")
    elseif gameState == "done" then
        love.graphics.setFont(largeFont)
        love.graphics.printf("Winner is player "..winner..".", 0, 10, VIRTUAL_WIDTH, "center")
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press enter to restart the game.", 0, 30, VIRTUAL_WIDTH, "center")
    end

    displayScore()
    player1:render()
    player2:render()
    ball:render()
    displayFPS()
    
    push:apply("end")
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255/255, 0, 255/255)
    love.graphics.print("FPS: "..tostring(love.timer.getFPS()), 10, 10)
end

function displayScore()
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end