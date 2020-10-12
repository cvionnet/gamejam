
require("param")

local menuTween = {}
local menuId = 0
local menuLoaded = false
local menuActive = false
local menuState = ""

--local imgPlayerHead = love.graphics.newImage("images/player/hero_head.png")
local imgPlayerHead = {}
local framePlayerHead = 1


--------------------------------------------------------------------------------------------------------

function drawMenu()
    if menuState == "menu" then
        -- Draw the menu
        for i = 1, #menuTween do
            -- Get x using tween animation
            local x = menuTween[i].ease(menuTween[i].time, menuTween[i].startPosition, menuTween[i].distance, menuTween[i].duration)
            love.graphics.print(menuTween[i].text, fontMenu, x, menuTween[i].y)
            menuTween[i].x = x
        end

        -- Draw the >
        if menuLoaded then
            love.graphics.print(">", fontMenu, menuTween[menuId].x - 25, menuTween[menuId].y)
        end

        -- Draw the flags
        local flagPositionX = menuTween[1].x + 210
        if LANGUAGE == "FR" then
            love.graphics.draw(imgFlagFR, flagPositionX, menuTween[1].y)
            --love.graphics.setColor(0.7,0.7,0.7,0.7)
            --love.graphics.rectangle("line", flagPositionX - 2, menuTween[1].y - 2, imgFlagFR:getWidth() + 4, imgFlagFR:getHeight() + 4)

            love.graphics.setColor(1,1,1,0.25)
            love.graphics.draw(imgFlagEN, flagPositionX + imgFlagFR:getWidth() + 10, menuTween[1].y)
            love.graphics.setColor(1,1,1,1)
        elseif LANGUAGE == "EN" then
            love.graphics.setColor(1,1,1,0.25)
            love.graphics.draw(imgFlagFR, flagPositionX, menuTween[1].y)
            love.graphics.setColor(1,1,1,1)
            --love.graphics.setColor(0.7,0.7,0.7,0.7)
            --love.graphics.rectangle("line", flagPositionX - 2, menuTween[1].y - 2, imgFlagFR:getWidth() + 4, imgFlagFR:getHeight() + 4)

            love.graphics.draw(imgFlagEN, flagPositionX + imgFlagFR:getWidth() + 10, menuTween[1].y)
        end
    end

    -- Hero head
    love.graphics.draw(imgPlayerHead[math.floor(framePlayerHead)], 0, 340, 0, 2, 2)

    -- Title
    love.graphics.print(TITLE, fontTitle, 20, 120, math.rad(-5))
    love.graphics.print(SUB_TITLE, fontSubTitle, 450, 190)
end


function updateMenu(dt)
    -- For tween animation
    menuLoaded = true
    for i = 1, #menuTween do
        -- When the animation is finished
        if menuTween[i].time < menuTween[i].duration then
            menuTween[i].time = menuTween[i].time + dt
            menuLoaded = false
        end
    end

    -- Save player menu selection
    if menuLoaded and menuActive == false and menuState == "menu" then
        menuState = menuTween[menuId].menuState
    end

    -- Player head animation
    PlayHeadAnimation(dt)

    -- Actions to do from the menu
    ActionMenu()
end

--------------------------------------------------------------------------------------------------------

function LoadHeadAnimation(pImageName, pImageNumber)
    for i = 1, pImageNumber do
        imgPlayerHead[i] = love.graphics.newImage("images/player/head/"..pImageName..tostring(i)..".png")
    end
end


function PlayHeadAnimation(dt)
    framePlayerHead = framePlayerHead + FRAME_PER_SECOND_HEAD * dt
    if framePlayerHead > #imgPlayerHead+1 then
        framePlayerHead = 1
    end
end

--------------------------------------------------------------------------------------------------------

function MenuKeyboardCommands(key)
    if key == "return" then
        if menuState == "menu" and menuLoaded then
            love.audio.play(sndMenuSelect)
            ExitMenu()
        end
    end

    if menuState == "menu" and menuLoaded then
        if key == "down" then
            love.audio.play(sndMenuUpDown)
            menuId = menuId + 1
            if menuId > #menuTween then
                menuId = 1
            end
        end
        if key == "up" then
            love.audio.play(sndMenuUpDown)
            menuId = menuId - 1
            if menuId <= 0 then
                menuId = #menuTween
            end
        end
        if key == "right" and LANGUAGE == "FR" then
            LANGUAGE = "EN"
            EnterMenu()
        elseif key == "left" and LANGUAGE == "EN" then
            LANGUAGE = "FR"
            EnterMenu()
        end
    end
end


function ActionMenu()
    if menuState == "newgame" then
        music_Obj:StopMusic(3)  -- menu
        InitIntroduction()
    end
    if menuState == "howto" then
        --music_Obj:StopMusic(3)  -- menu
        InitHowTo()
    end
    if menuState == "quit" then
        music_Obj:StopMusic(3)  -- menu
        love.event.quit()
    end
end
--------------------------------------------------------------------------------------------------------

function EnterMenu()
    music_Obj:StopMusic(4)  -- victory
    music_Obj:StopMusic(5)  -- gameover
    music_Obj:PlayMusic(3)  -- menu

    LoadHeadAnimation("hero_head", 6)

    menuState = "menu"
    menuId = 1
    menuLoaded = false
    menuActive = true
    menuTween = {}

    menuTween[1] = {}
    menuTween[1].startPosition = -100
    menuTween[1].distance = 500
    if LANGUAGE == "FR" then menuTween[1].text = menu1_FR
    elseif LANGUAGE == "EN" then menuTween[1].text = menu1_EN end
    menuTween[1].menuState = "newgame"

    menuTween[2] = {}
    menuTween[2].startPosition = -200
    menuTween[2].distance = 600
    if LANGUAGE == "FR" then menuTween[2].text = menu2_FR
    elseif LANGUAGE == "EN" then menuTween[2].text = menu2_EN end
    menuTween[2].menuState = "howto"

    menuTween[3] = {}
    menuTween[3].startPosition = -300
    menuTween[3].distance = 700
    if LANGUAGE == "FR" then menuTween[3].text = menu3_FR
    elseif LANGUAGE == "EN" then menuTween[3].text = menu3_EN end
    menuTween[3].menuState = "quit"

    for i = 1, #menuTween do
        menuTween[i].time = 0
        menuTween[i].duration = 2
        menuTween[i].ease = easeOutSin
        menuTween[i].x = menuTween[i].startPosition + menuTween[i].distance

        if i == 1 then
            menuTween[i].y = X_SCREENSIZE/2
        else
            menuTween[i].y = menuTween[i-1].y + 60
        end
    end
end


function ExitMenu()
    menuActive = false

    for i = 1, #menuTween do
        menuTween[i].time = 0
        menuTween[i].startPosition = menuTween[i].x
        menuTween[i].distance = 450
        menuTween[i].duration = 1
        menuTween[i].ease = easeInExpo
    end

    -- The menu selected leave faster
    menuTween[menuId].time = 0.2
end

--------------------------------------------------------------------------------------------------------

function easeOutSin(t, b, c, d)
    return c * math.sin(t/d * (math.pi/2)) + b
end

function easeInExpo(t, b, c, d)
    return c * math.pow( 2, 10 * (t/d - 1) ) + b
end

--------------------------------------------------------------------------------------------------------
