io.stdout:setvbuf('no')                                         -- Display console trace during execution
love.graphics.setDefaultFilter("nearest")                       -- For pixel art (set scaling filters interpolation - https://love2d.org/wiki/FilterMode)
if arg[#arg] == "-debug" then require("mobdebug").start() end   -- To debug step by step in ZeroBraneStudio
--------------------------------------------------------------------------------------------------------

local player = {}

local lstSprites = {}

local FRAME_PER_SECOND = 24
local GRAVITY = .9
local STOP_PLAYER = .5  --.01

--------------------------------------------------------------------------------------------------------

function love.load()
    xScreenSize = love.graphics.getWidth()
    yScreenSize = love.graphics.getHeight()

    InitGame()
end

function love.update(dt)
    for i = 1, #lstSprites do
        lstSprites[i].Move()
        lstSprites[i].PlayAnimation(dt)
    end

    if math.abs(player.vx) < 1 and math.abs(player.vy) < 1 then
        player.frame = 1
    end

    -- Movements
    CheckInputs(dt)
end

function love.draw()
    for i = 1, #lstSprites do
        local image = lstSprites[i].images[math.floor(lstSprites[i].frame)]
        love.graphics.draw(image, lstSprites[i].x, lstSprites[i].y, 0, lstSprites[i].flip, 1, lstSprites[i].w/2, lstSprites[i].h-6)
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end

    if key == "space" then
        InitGame()
    end
end

--------------------------------------------------------------------------------------------------------

function InitGame()
    lstSprites = {}
    player = CreateSprite("p1_walk", 11, xScreenSize/2, yScreenSize/2)
end

--------------------------------------------------------------------------------------------------------

function CreateSprite(pImageName, pImageNumber, pX, pY)
    local mySprite = {}
    mySprite.images = {}
    mySprite.frame = 1
    mySprite.flip = 1
    mySprite.x = pX
    mySprite.y = pY
    mySprite.vx = 0
    mySprite.vy = 0
    mySprite.vmax = 7

    -- Load animation sprites
    for i = 1, pImageNumber do
        mySprite.images[i] = love.graphics.newImage("images/"..pImageName..tostring(i)..".png")
    end

    mySprite.w = mySprite.images[1]:getWidth()
    mySprite.h = mySprite.images[1]:getHeight()

    table.insert(lstSprites, mySprite)


    function mySprite.PlayAnimation(dt)
        mySprite.frame = mySprite.frame + FRAME_PER_SECOND * dt
        if mySprite.frame > #mySprite.images then
            mySprite.frame = 1
        end
    end


    function mySprite.Move()
        -- Apply velocity (=friction)  - 10% each time
        mySprite.vx = mySprite.vx * GRAVITY
        mySprite.vy = mySprite.vy * GRAVITY
        if math.abs(mySprite.vx) < STOP_PLAYER then mySprite.vx = 0 end
        if math.abs(mySprite.vy) < STOP_PLAYER then mySprite.vy = 0 end

        -- Move the sprite and apply velocity
        mySprite.x = mySprite.x + mySprite.vx
        mySprite.y = mySprite.y + mySprite.vy
    end

    return mySprite
end

--------------------------------------------------------------------------------------------------------

-- Check keyboard inputs
function CheckInputs(dt)
    if love.keyboard.isDown("right") then
        if math.abs(player.vx) <= player.vmax then
            player.vx = player.vx + 1
        end
        player.flip = 1
    end
    if love.keyboard.isDown("left") then
        if math.abs(player.vx) <= player.vmax then
            player.vx = player.vx - 1
        end
        player.flip = -1
    end
    if love.keyboard.isDown("up") then
        if math.abs(player.vy) <= player.vmax then
            player.vy = player.vy - 1
        end
    end
    if love.keyboard.isDown("down") then
        if math.abs(player.vy) <= player.vmax then
            player.vy = player.vy + 1
        end
    end
end