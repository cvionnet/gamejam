io.stdout:setvbuf('no')                                         -- Display console trace during execution
love.graphics.setDefaultFilter("nearest")                       -- For pixel art (set scaling filters interpolation - https://love2d.org/wiki/FilterMode)
if arg[#arg] == "-debug" then require("mobdebug").start() end   -- To debug step by step in ZeroBraneStudio
--------------------------------------------------------------------------------------------------------

local MAP = require("map_logic")
local PLAYER = require("player_logic")
local MONSTER = require("monster_logic")

local lstMonsters = {}


local DEBUG_MODE = true

--------------------------------------------------------------------------------------------------------

function love.load()
    math.randomseed(love.timer.getTime())
    love.window.setMode(1024, 768, {fullscreen=false, vsync=true})
    --love.keyboard.setKeyRepeat(true)

    xScreenSize = love.graphics.getWidth()
    yScreenSize = love.graphics.getHeight()

    InitGame()
end


function love.update(dt)
    player_Obj:update(dt)

    for key, monster in pairs(lstMonsters) do
        monster:update(dt, player_Obj)
    end
end


function love.draw()
    map_Obj:draw(DEBUG_MODE)

    for key, monster in pairs(lstMonsters) do
        monster:draw(DEBUG_MODE)
    end

    player_Obj:draw(DEBUG_MODE)

    if DEBUG_MODE then
        love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
    end
end


function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end

    -- Check if the player have to change side (left, right, up, down)
    player_Obj:SwitchSidePosition(key)


    if DEBUG_MODE then
        -- Create tentacles
        if key == "t" then
            for i = 1, 50 do
                monster_Obj:CreateTentacle()
            end
        end
    end
end

--------------------------------------------------------------------------------------------------------

function InitGame()
    map_Obj = MAP.NewMap(xScreenSize, yScreenSize)

    player_Obj = PLAYER.NewPlayer(map_Obj, xScreenSize, yScreenSize)
    player_Obj:InitPlayer(0, yScreenSize/2, "idle/p1_walk", 11)

    monster_Obj = MONSTER.NewMonster(map_Obj, xScreenSize, yScreenSize)
    monster_Obj:InitMonster(xScreenSize - map_Obj.TILE_WIDTH*2, map_Obj.TILE_HEIGHT*2, "monster_background", 1)
    table.insert(lstMonsters, monster_Obj)
end

