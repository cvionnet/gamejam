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
    monster_Obj:update(dt)
end


function love.draw()
    map_Obj:draw(DEBUG_MODE)
    monster_Obj:draw(DEBUG_MODE)
    player_Obj:draw(DEBUG_MODE)
end


function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end

if key == "t" then
    monster_Obj:InitTentacle()
end

    player_Obj:SwitchSidePosition(key)
end

--------------------------------------------------------------------------------------------------------

function InitGame()
    map_Obj = MAP.NewMap(xScreenSize, yScreenSize)

    player_Obj = PLAYER.NewPlayer(map_Obj, xScreenSize, yScreenSize)
    player_Obj:InitPlayer(0, yScreenSize/2, "idle/p1_walk", 11)

    monster_Obj = MONSTER.NewMonster(map_Obj, xScreenSize, yScreenSize)
    monster_Obj:InitMonster(xScreenSize - map_Obj.TILE_WIDTH*2, map_Obj.TILE_HEIGHT*2, "monster_background", 1)
end

