io.stdout:setvbuf('no')                                         -- Display console trace during execution
love.graphics.setDefaultFilter("nearest")                       -- For pixel art (set scaling filters interpolation - https://love2d.org/wiki/FilterMode)
if arg[#arg] == "-debug" then require("mobdebug").start() end   -- To debug step by step in ZeroBraneStudio
--------------------------------------------------------------------------------------------------------

local MAP = require("map_logic")
local PLAYER = require("player_logic")
local MONSTER = require("monster_logic")
require("param")


local gameState = ""            -- game / gameover / victory

local lstMonsters = {}

local bulletTimeMode = false
local bulletTimer = 0.5

--------------------------------------------------------------------------------------------------------

function love.load()
    math.randomseed(love.timer.getTime())
    love.window.setMode(768, 768, {fullscreen=false, vsync=true})
    --love.keyboard.setKeyRepeat(true)

    xScreenSize = love.graphics.getWidth()
    yScreenSize = love.graphics.getHeight()

    InitGame()
end


function love.update(dt)
    if gameState == "game" then
        player_Obj:update(dt)

        ActivateBulletTime(dt)

        -- Create a maximum of 2 monsters
        if #lstMonsters < 2 then
            CheckforSecondMonster()
        end

        CheckforGameOver()
        CheckforVictory()
    end
end


function love.draw()
    if gameState == "game" then
        map_Obj:draw()

        for key, monster in pairs(lstMonsters) do
            monster:draw()
        end

        player_Obj:draw()

        if DEBUG_MODE then
            love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
        end
    elseif gameState == "gameover" then
        love.graphics.print("GAME OVER", fontBig, xScreenSize/2, yScreenSize/2)
    elseif gameState == "victory" then
        love.graphics.print("VICTORY", fontBig, xScreenSize/2, yScreenSize/2)
    end
end


function love.keypressed(key)
    if gameState == "game" then
        -- Check if the player have to change side (left, right, up, down)
        player_Obj:SwitchSidePosition(key)
    end


    if DEBUG_MODE then
        if key == "escape" then
            love.event.quit()
        end

        -- Create tentacles on the 1st monster
        if key == "t" then
            for i = 1, 20 do
                monster_Obj:CreateTentacle()
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
            tempmonster_Obj = MONSTER.NewMonster(2, map_Obj, xScreenSize, yScreenSize)
            tempmonster_Obj:InitMonster("monster_background", 1, MONSTER_LIFE, "", #lstMonsters, monster_Obj.mapSidePosition)
            table.insert(lstMonsters, tempmonster_Obj)

        end

        -- Force monster position
        if key == "x" then
            monster_Obj:SetSidePosition("down")
            monster_Obj.status = "warning"
        end
    end
end

--------------------------------------------------------------------------------------------------------

function InitGame()
    map_Obj = MAP.NewMap(xScreenSize, yScreenSize)

    player_Obj = PLAYER.NewPlayer(map_Obj, xScreenSize, yScreenSize, VILLAGE_LIFE, PLAYER_LIFE)
    player_Obj:InitPlayer(0, yScreenSize/2, "idle/p1_walk", 11)

    monster_Obj = MONSTER.NewMonster(1, map_Obj, xScreenSize, yScreenSize)
    monster_Obj:InitMonster("monster_background", 1, MONSTER_LIFE, "right", 1, "")
    table.insert(lstMonsters, monster_Obj)

    gameState = "game"
end


-- Check if we add a 2nd monster
function CheckforSecondMonster()
    local monsterPercentLife = (monster_Obj.life * 100) / MONSTER_LIFE      -- Percentage of life the 1st mosnter still have

    -- Check the status to be sure that the 1st monster has already take his new position  (to avoid to have 2 monster face to face)
    if monsterPercentLife <= MONSTER_PERCENT_APPEAR_2ND_MONSTER and monster_Obj.status == "coming" then
        -- Create the second monster
        monster_Obj2 = MONSTER.NewMonster(2, map_Obj, xScreenSize, yScreenSize)
        monster_Obj2:InitMonster("monster_background", 1, MONSTER_LIFE, "", 2, monster_Obj.mapSidePosition)
        table.insert(lstMonsters, monster_Obj2)
    end
end


function ActivateBulletTime(dt)
    -- Mode bullet time ON
    if bulletTimeMode then
        bulletTimer = bulletTimer - BULLET_TIME_SPEED * dt
        if bulletTimer < 0 then
            bulletTimer = 0.5

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
