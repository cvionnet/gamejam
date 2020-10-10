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


local gameState = ""            -- menu / game / gameover / victory

local imgFog = love.graphics.newImage("images/map/fog.png")

-- UI
local imgParchment = love.graphics.newImage("images/ui/parchment.png")
local imgBulletTime = love.graphics.newImage("images/ui/bullettime.png")

local imgVillageHealth = love.graphics.newImage("images/ui/village.png")
local imgVillageFire = love.graphics.newImage("images/ui/village_fire.png")

local imgPlayerHealth100 = love.graphics.newImage("images/player/health/hero_head_health1.png")
local imgPlayerHealth80 = love.graphics.newImage("images/player/health/hero_head_health2.png")
local imgPlayerHealth60 = love.graphics.newImage("images/player/health/hero_head_health3.png")
local imgPlayerHealth40 = love.graphics.newImage("images/player/health/hero_head_health4.png")
local imgPlayerHealth20 = love.graphics.newImage("images/player/health/hero_head_health5.png")


local lstMonsters = {}

local bulletTimeMode = false
local bulletTimer = BULLET_TIME_SLOW_FACTOR
local bulletTimeLength = 0

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
    elseif gameState == "game" then
        map_Obj:update(dt)
        player_Obj:update(dt)

        ActivateBulletTime(dt)

        groupUI:update(dt)

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
    end
end


function love.draw()
    if gameState == "menu" then
        drawMenu()
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
        love.graphics.print("GAME OVER", fontWarning, X_SCREENSIZE/2, Y_SCREENSIZE/2)
    elseif gameState == "victory" then
        love.graphics.print("VICTORY", fontWarning, X_SCREENSIZE/2, Y_SCREENSIZE/2)
    end
end


function love.keypressed(key)
    if gameState == "menu" then
        MenuKeyboardCommands(key)
    elseif gameState == "game" then
        -- Check if the player have to change side (left, right, up, down)
        player_Obj:SwitchSidePosition(key)
    end


    if DEBUG_MODE then
        if key == "escape" then
            love.event.quit()
        end

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
    --music_Obj:AddMusic(musicTechno)

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

    music_Obj:PlayMusic(1)

    -- Load the UI
    LoadUI()

    map_Obj:InitAnimation()

    player_Obj:InitPlayer(0, Y_SCREENSIZE/2)

    monster_Obj:InitMonster(MONSTER_LIFE, "right", 1, "")
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

            for i = 1, #lstMonsters do
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

    -- Mode bullet time OFF
    else
        for i = 1, #lstMonsters do
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


function CheckforGameOver()
    if player_Obj.life <= 0 or player_Obj.villageLife <= 0 then
        gameState = "gameover"
    end
end

function CheckforVictory()
    local monsterDeadNumber = 0

    for key, monster in pairs(lstMonsters) do
        if monster.life <= 0 then
            monsterDeadNumber = monsterDeadNumber + 1
        end
    end

    if monsterDeadNumber == #lstMonsters then
        gameState = "victory"
    end
end

--------------------------------------------------------------------------------------------------------

function drawFog()
    local fg_r, fg_g, fg_b, fg_a = love.graphics.getColor()
    love.graphics.setColor(fg_r, fg_g, fg_b, 0.3)
    love.graphics.draw(imgFog, 1 , 1)
    love.graphics.setColor(fg_r, fg_g, fg_b, fg_a)
end


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
