local MONSTER = {}

local TENTACLE = require("tentacle_logic")
local BULLET = require("bullet_logic")

local FRAME_PER_SECOND = 24


function MONSTER.NewMonster(pMapObject, pXScreenSize, pYScreenSize)
    -- PROPERTIES
    local myMonster = {}

    myMonster.map_Object = pMapObject

    myMonster.x = 0
    myMonster.y = 0
    myMonster.h = 0
    myMonster.w = 0
    myMonster.sx = 0    -- used to flip the sprite
    myMonster.sy = 0
    myMonster.rotation = 0

    myMonster.xScreenSize = pXScreenSize
    myMonster.yScreenSize = pYScreenSize

    myMonster.vx = 0
    myMonster.vy = 0
    myMonster.mapSidePosition = ""       -- up, down, left, right

    myMonster.images = {}
    myMonster.frame = 1

    myMonster.life = 0

    myMonster.tentacles = {}

--------------------------------------------------------------------------------------------------------
    -- METHODS
    function myMonster:draw(DEBUG_MODE)

        -- Background of the monster
        love.graphics.draw(self.images[math.floor(self.frame)], self.x, self.y, math.rad(self.rotation), self.sx, self.sy)  --, self.flip, 1) --, self.w/2, self.h-6) -- player.h/2)

        -- Tentacles
        for key, tentacle in pairs(self.tentacles) do
            tentacle:draw()

            -- Bullets
            for key1, bullet in pairs(tentacle.lstBullet) do
                bullet:draw()
            end
        end


        -- DEBUG - draw player box
        if DEBUG_MODE == true then
            love.graphics.setColor(1,0,0)
            love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
            love.graphics.setColor(1,1,1)
        end
    end


    function myMonster:update(dt)
        -- Monster animation
        self:PlayAnimation(dt)

        -- Tentacles animation
        for key, tentacle in pairs(self.tentacles) do
            tentacle:update(dt)
        end

        -- Collisions
        --self:CheckWallCollision(oldX, oldY)
    end

--------------------------------------------------------------------------------------------------------

    function myMonster:InitMonster(pX, pY, pAnimationFile, pAnimationNumberFrames)
        self.x = pX
        self.y = pY
        self.sx = 1
        self.sy = -1
        self.rotation = 90
        self.mapSidePosition = "right"

        self:LoadAnimation(pAnimationFile, pAnimationNumberFrames)
    end


    function myMonster:LoadAnimation(pImageName, pImageNumber)
        for i = 1, pImageNumber do
            self.images[i] = love.graphics.newImage("images/monster/"..pImageName..tostring(i)..".png")
        end

        self.w = self.images[1]:getWidth()
        self.h = self.images[1]:getHeight()
    end


    function myMonster:PlayAnimation(dt)
        if math.abs(self.vx) < 1 and math.abs(self.vy) < 1 then
            self.frame = 1
        else
            self.frame = self.frame + FRAME_PER_SECOND * dt
            if self.frame > #self.images then
                self.frame = 1
            end
        end
    end

--------------------------------------------------------------------------------------------------------

    -- Change player side position
    function myMonster:SwitchSidePosition(key)

    end

--------------------------------------------------------------------------------------------------------

    function myMonster:InitTentacle()
        local myTentacle = TENTACLE.NewTentacle(self.map_Object, self.xScreenSize, self.yScreenSize)
--        myTentacle:InitTentacle(self.x - self.map_Object.TILE_HEIGHT * 2, math.random(self.y, self.y + self.map_Object.TILE_HEIGHT), "monster_tentacle", 1)
        myTentacle:InitTentacle(self.x - self.map_Object.TILE_HEIGHT * 2 + math.random(0,self.map_Object.TILE_HEIGHT), math.random(self.y, self.y + self.w - myTentacle.h*2), "monster_tentacle", 1)
        table.insert(self.tentacles, myTentacle)



        local myBullet = BULLET.NewBullet(self.map_Object)
        myBullet:InitBullet(myTentacle.x - 30, myTentacle.y, "monster_bullet", 1)
        print(myTentacle.lstBullet)
        table.insert(myTentacle.lstBullet, myBullet)
    end

--------------------------------------------------------------------------------------------------------

    return myMonster
end


return MONSTER