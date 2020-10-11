io.stdout:setvbuf('no')                                         -- Display console trace during execution
love.graphics.setDefaultFilter("nearest")                       -- For pixel art (set scaling filters interpolation - https://love2d.org/wiki/FilterMode)
if arg[#arg] == "-debug" then require("mobdebug").start() end   -- To debug step by step in ZeroBraneStudio
--------------------------------------------------------------------------------------------------------

local MAP = require("map_logic")
local PLAYER = require("player_logic")
local MONSTER = require("monster_logic")
local MUSIC = require("music_manager")
local GUI = require("ui_manager")

require("menu_logic")
require("param")


local gameState = ""            -- menu / intro / game / gameover / victory

local fogX = 1       -- Horizontal position of the fog (for scrolling)

local lstMonsters = {}

local bulletTimeMode = false
local bulletTimer = BULLET_TIME_SLOW_FACTOR
local bulletTimeLength = 0

local textEffect = {}
--local initTextFinished = false
local textAllDisplayed = false
local textDisplayNext = false
local indexText = 1

--------------------------------------------------------------------------------------------------------

function love.load()
    math.randomseed(love.timer.getTime())
    love.window.setMode(768, 768) --, {fullscreen=false, vsync=true})
    --love.keyboard.setKeyRepeat(true)

    X_SCREENSIZE = love.graphics.getWidth()
    Y_SCREENSIZE = love.graphics.getHeight()

    InitGame()
end


function love.update(dt)
    if gameState == "menu" then
        updateMenu(dt)
    elseif gameState == "intro" then
        updateIntroduction(dt)
        updateTextEffect(dt)
    elseif gameState == "game" then
        map_Obj:update(dt)
        player_Obj:update(dt)

        -- Bullet time + monster update
        ActivateBulletTime(dt)

        groupUI:update(dt)
        FogInfiniteScrolling(dt)

        -- Create a maximum of 2 monsters
        if #lstMonsters < 2 then
            CheckforSecondMonster()
        end

        -- Camera shake
        if camShake.shake then
            updateCamShake(dt)
        end

        CheckforGameOver()
        CheckforVictory()
    elseif gameState == "victory" or gameState == "gameover" then
        updateTextEffect(dt)
    end
end


function love.draw()
    if gameState == "menu" then
        drawMenu()
    elseif gameState == "intro" then
        drawIntroduction()
    elseif gameState == "game" then
        -- Camera shake
        if camShake.shake then drawCamShake() end

        map_Obj:draw()      -- draw map
        player_Obj:draw()   -- draw the player

        -- Draw enemies and bullets
        for key, monster in pairs(lstMonsters) do
            monster:draw()
        end

        drawFog()   -- draw Fog
        drawUI()    -- draw UI

        if DEBUG_MODE then
            love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), X_SCREENSIZE - 100, 10)
        end
    elseif gameState == "gameover" then
        drawGameOver()
    elseif gameState == "victory" then
        drawVictory()
    end
end


function love.keypressed(key)
    if gameState == "menu" then
        MenuKeyboardCommands(key)
    elseif gameState == "game" then
        -- Check if the player have to change side (left, right, up, down)
        player_Obj:SwitchSidePosition(key)
    elseif gameState == "intro" or gameState == "victory" or gameState == "gameover" then
        if key == "space" then
            -- All the text has been displayed, go to next text
            if textAllDisplayed then
                textDisplayNext = true
            end

            -- Display all the text
            if textEffect.text ~= nil then
                textEffect.position = string.len(textEffect.text)
                textAllDisplayed = true
            end
        end
    end


    if DEBUG_MODE then
        if key == "escape" then
            love.event.quit()
        end

        -- Display Victory screen
        if key == "v" then InitVictory() end
        -- Display Gameover screen
        if key == "g" then InitGameOver() end

        -- Create enemies on the 1st monster
        if key == "t" then
            for i = 1, 20 do
                monster_Obj:CreateEnemy()
            end
        end

        -- Activate / desactivate bullet time mode
        if key == "b" then
            if bulletTimeMode then
                bulletTimeMode = false
            else
                bulletTimeMode = true
            end
        end

        -- force 2nd monster to appear
        if key == "m" then
            --local newPosition = monster_Obj:GetNextSidePosition_MultipleMonsters()
            tempmonster_Obj = MONSTER.NewMonster(2, map_Obj)
            tempmonster_Obj:InitMonster(MONSTER_LIFE, "", #lstMonsters, monster_Obj.mapSidePosition)
            table.insert(lstMonsters, tempmonster_Obj)
        end

        -- Force monster position
        if key == "x" then
            monster_Obj:SetSidePosition("left")
            monster_Obj.status = "warning"
        end
    end
end

--------------------------------------------------------------------------------------------------------

function InitGame()
    -- Pre-create all objects
    map_Obj = MAP.NewMap()
    player_Obj = PLAYER.NewPlayer(map_Obj, VILLAGE_LIFE, PLAYER_LIFE)
    monster_Obj = MONSTER.NewMonster(1, map_Obj)
    monster_Obj2 = MONSTER.NewMonster(2, map_Obj)
    music_Obj = MUSIC.NewMusic()

    -- Pre-load musics
    music_Obj:AddMusic(musicBattle)
    music_Obj:AddMusic(musicIntro)
    music_Obj:AddMusic(musicMenu)
    music_Obj:AddMusic(musicVictory)
    music_Obj:AddMusic(musicGameover)

    -- pass menu screen
    if DEBUG_PASS_MENU then
        InitMap()
    else
        EnterMenu()
        gameState = "menu"
    end
end


function InitMap()
    bulletTimeLength = BULLET_TIME_LENGTH

    music_Obj:StopMusic(2)  -- intro
    music_Obj:PlayMusic(1)  -- game

    -- Load the UI
    LoadUI()

    map_Obj:InitAnimation()

    player_Obj:InitPlayer(0, Y_SCREENSIZE/2)

    monster_Obj:InitMonster(MONSTER_LIFE, "right", 1, "")       -- 3rd parameter : how many times the monster will appear
    table.insert(lstMonsters, monster_Obj)

    gameState = "game"
end

--------------------------------------------------------------------------------------------------------

-- Draw player, village ... status
function drawUI()
    -- Background image
    love.graphics.draw(imgParchment, 1, 1, 0, 4, 2.5)

    -- Player status
    if player_Obj.life <= PLAYER_LIFE and player_Obj.life >= PLAYER_LIFE*.8 then
        love.graphics.draw(imgPlayerHealth100, 27, 15)
    elseif player_Obj.life < PLAYER_LIFE*.8 and player_Obj.life >= PLAYER_LIFE*.6 then
        love.graphics.draw(imgPlayerHealth80, 27, 15)
    elseif player_Obj.life < PLAYER_LIFE*.6 and player_Obj.life >= PLAYER_LIFE*.4 then
        love.graphics.draw(imgPlayerHealth60, 27, 15)
    elseif player_Obj.life < PLAYER_LIFE*.4 and player_Obj.life >= PLAYER_LIFE*.2 then
        love.graphics.draw(imgPlayerHealth40, 27, 15)
    elseif player_Obj.life <= PLAYER_LIFE*.2 then
        love.graphics.draw(imgPlayerHealth20, 27, 15)
    end

    -- Village status  (draw fire above when the enemy hit the village)
    love.graphics.draw(imgVillageHealth, 70, 15)
    love.graphics.draw(imgVillageFire, 70, 15, 0, 1-(player_Obj.villageLife / VILLAGE_LIFE), 1)

    -- Bullet Time
    love.graphics.draw(imgBulletTime, 27, 50, 0, 2, 2)
    groupUI:draw()
end


-- Display progressbars
function LoadUI()
    groupUI = GUI.NewGroup()

    -- Player bullet time
    uiPlayerBulletTime = GUI.NewProgressBar(45, 50, 1, 1, BULLET_TIME_LENGTH)
    uiPlayerBulletTime:setImages("images/ui/bullettime_bar_orange.png", "images/ui/bullettime_bar_green.png")

    groupUI:addElement(uiPlayerBulletTime)
end

--------------------------------------------------------------------------------------------------------

-- Check if we add a 2nd monster
function CheckforSecondMonster()
    local monsterPercentLife = (monster_Obj.life * 100) / MONSTER_LIFE      -- Percentage of life the 1st mosnter still have

    -- Check the status to be sure that the 1st monster has already take his new position  (to avoid to have 2 monster face to face)
    if monsterPercentLife <= MONSTER_PERCENT_APPEAR_2ND_MONSTER and monster_Obj.status == "coming" then
        -- Create the second monster
        monster_Obj2:InitMonster(MONSTER_LIFE, "", 2, monster_Obj.mapSidePosition)
        table.insert(lstMonsters, monster_Obj2)
    end
end


function ActivateBulletTime(dt)
    -- Mode bullet time ON
    if bulletTimeMode and bulletTimeLength > 0 then
        bulletTimer = bulletTimer - BULLET_TIME_SPEED * dt

        if bulletTimer < 0 then
            bulletTimer = 0.5

            -- UI - Decrease bullet time power used
            bulletTimeLength = bulletTimeLength - BULLET_TIME_LOSS_SPEED * dt
            uiPlayerBulletTime:setValue(bulletTimeLength)   --uiPlayerBulletTime.value - 1)

            updateMonster(dt)
        end

    -- Mode bullet time OFF
    else
        updateMonster(dt)
    end
end


function updateMonster(dt)
    for i = 1, #lstMonsters do
        --print("Monster"..tostring(i).." life : "..tostring(lstMonsters[i].life))
        -- If the moster is not dead
        if lstMonsters[i].life > 0 then
            -- If there is 2 monster, need to send the position of the other monster
            -- 2 monsters, send position of 2nd monster
            if #lstMonsters > 1 and i == 1 then
                lstMonsters[i]:update(dt, player_Obj, #lstMonsters, lstMonsters[i+1].mapSidePosition)
            -- 2 monsters, send position of 1st monster
            elseif #lstMonsters > 1 and i == 2 then
                lstMonsters[i]:update(dt, player_Obj, #lstMonsters, lstMonsters[i-1].mapSidePosition)
            -- Only one monster
            else
                lstMonsters[i]:update(dt, player_Obj, 1, "")
            end
        end
    end
end

--------------------------------------------------------------------------------------------------------

function InitIntroduction()
    music_Obj:StopMusic(3)  -- menu
    music_Obj:PlayMusic(2)  -- intro

    player_Obj:InitPlayer(0, Y_SCREENSIZE/2)
    player_Obj:PlayAnimation("idle")

    gameState = "intro"

    indexText = 1
    InitTextEffect(lstIntroductionText_FR[indexText])
end


function drawIntroduction()
    -- Draw the player or enemy picture, depending of sentences
    if indexText == 3 or indexText == 9 or indexText == 11 then
        love.graphics.draw(imgQuestionMark, X_SCREENSIZE - 150, Y_SCREENSIZE/2, 0, 4, 4)
    else
        player_Obj:draw()
    end

    drawTextEffect()
end


function updateIntroduction(dt)
    player_Obj:updateAnimation(dt)
end


-- Display next text or reset game
function ActionIntroduction()
    -- Load next text
    if textAllDisplayed and textDisplayNext and indexText <= #lstIntroductionText_FR then
        indexText = indexText + 1
        InitTextEffect(lstIntroductionText_FR[indexText])
    -- All texts have been displayed
    elseif indexText > #lstIntroductionText_FR then
        -- Start the game
        InitMap()
    end
end

--------------------------------------------------------------------------------------------------------

function CheckforGameOver()
    if player_Obj.life <= 0 or player_Obj.villageLife <= 0 then
        InitGameOver()
    end
end


function InitGameOver()
    music_Obj:StopMusic(1)  -- game
    music_Obj:PlayMusic(5)  -- gameover

    gameState = "gameover"

    indexText = 1
    InitTextEffect(lstGameoverText_FR[indexText])
end


function drawGameOver()
    love.graphics.print(gameoverText_FR, fontEndgame, 350, 200)
    love.graphics.draw(imgGameover_Head, 0, 120, 0, 2, 2)

    drawTextEffect()
end


-- Display next text or reset game
function ActionGameOver()
    -- Load next text
    if textAllDisplayed and textDisplayNext and indexText <= #lstGameoverText_FR then
        indexText = indexText + 1
        InitTextEffect(lstGameoverText_FR[indexText])
    -- All texts have been displayed
    elseif indexText > #lstGameoverText_FR then
        music_Obj:StopMusic(5)  -- gameover

        sndGameEnemy_Appear:play()
        -- Wait the sound finished
        while sndGameEnemy_Appear:isPlaying() do
        end

        -- Reload the game
        InitGame()
    end
end

--------------------------------------------------------------------------------------------------------

function CheckforVictory()
    local monsterDeadNumber = 0

    for key, monster in pairs(lstMonsters) do
        if monster.life <= 0 then
            monsterDeadNumber = monsterDeadNumber + 1
        end
    end

    if monsterDeadNumber == #lstMonsters then
        InitVictory()
    end
end


function InitVictory()
    music_Obj:StopMusic(1)  -- game
    music_Obj:PlayMusic(4)  -- victory

    gameState = "victory"

    indexText = 1
    InitTextEffect(lstVictoryText_FR[indexText])
end


function drawVictory()
    love.graphics.print(victoryText_FR, fontEndgame, 350, 200)
    love.graphics.draw(imgVictory_Head, 0, 120, 0, 2, 2)

    drawTextEffect()
end


-- Display next text or reset game
function ActionVictory()
    -- Load next text
    if textAllDisplayed and textDisplayNext and indexText <= #lstVictoryText_FR then
        indexText = indexText + 1
        InitTextEffect(lstVictoryText_FR[indexText])
    -- All texts have been displayed
    elseif indexText > #lstVictoryText_FR then
        music_Obj:StopMusic(4)  -- victory

        sndBraaamInverse:play()
        -- Wait the sound finished
        while sndBraaamInverse:isPlaying() do
        end

        -- Reload the game
        InitGame()
    end
end

--------------------------------------------------------------------------------------------------------

function InitTextEffect(pText)
    textEffect = {}
    textEffect.text = pText
    textEffect.position = 1
    textEffect.timer = 0
    textEffect.speed = TEXT_SPEED

    textAllDisplayed = false
    textDisplayNext = false
end


function drawTextEffect()
    if textEffect.text ~= nil then
        local partText = string.sub(textEffect.text, 1, textEffect.position)
        love.graphics.printf(partText, fontDialog, 50, 500, X_SCREENSIZE - 50) --, "center")
    end

    -- Display the "next" button
    if textAllDisplayed then
        love.graphics.draw(imgButtonNext, X_SCREENSIZE-100, Y_SCREENSIZE-150, 0, 4, 4)
    end
end


function updateTextEffect(dt)
    if textEffect.text ~= nil then
        if textEffect.position < string.len(textEffect.text) then   -- stop the increment of position if all the text is displayed
            textEffect.timer = textEffect.timer + dt
            if textEffect.timer >= textEffect.speed then
                textEffect.position = textEffect.position + 1
                textEffect.timer = 0
            end
        else
            -- the current text is all displayed
            textAllDisplayed = true
        end
    end

    -- Display next text or reset game
    if gameState == "intro" then ActionIntroduction() end
    if gameState == "victory" then ActionVictory() end
    if gameState == "gameover" then ActionGameOver() end
end

--------------------------------------------------------------------------------------------------------

function drawFog()
    local fg_r, fg_g, fg_b, fg_a = love.graphics.getColor()
    love.graphics.setColor(fg_r, fg_g, fg_b, 0.3)
    love.graphics.draw(imgFog2, 1, 1)       -- fix fox

    love.graphics.setColor(fg_r, fg_g, fg_b, 0.1)
    love.graphics.draw(imgFog, fogX, 1)     -- scrolling fog
    if fogX < 1 then
        love.graphics.draw(imgFog, fogX + imgFog:getWidth() , 1)
    end

    love.graphics.setColor(fg_r, fg_g, fg_b, fg_a)
end


function FogInfiniteScrolling(dt)
    fogX = fogX - FOG_SCROLLINGSPEED * dt
    if fogX <= (0 - imgFog:getWidth()) then
        fogX = 1
    end
end

--------------------------------------------------------------------------------------------------------

function drawCamShake(dt)
    -- Backup graphics parameters
    --love.graphics.push()

    love.graphics.translate(math.random(-camShake.shakeOffset, camShake.shakeOffset), math.random(-camShake.shakeOffset, camShake.shakeOffset))

    -- Restore graphics parameters
    --love.graphics.pop()
end

function updateCamShake(dt)
    camShake.shakeTimer = camShake.shakeTimer - 1*dt
    if camShake.shakeTimer <= 0 then
        camShake.shake = false      -- stop the shake
    end
end
