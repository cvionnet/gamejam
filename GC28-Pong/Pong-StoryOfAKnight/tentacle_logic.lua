local TENTACLE = {}

local BULLET = require("bullet_logic")
require("param")


function TENTACLE.NewTentacle(pMapObject, pXScreenSize, pYScreenSize)
    -- PROPERTIES
    local myTentacle = {}

    myTentacle.map_Object = pMapObject

    myTentacle.x = 0
    myTentacle.y = 0
    myTentacle.h = 0
    myTentacle.w = 0
    myTentacle.sx = 0    -- used to flip the sprite
    myTentacle.sy = 0
    myTentacle.rotation = 0

    myTentacle.xScreenSize = pXScreenSize
    myTentacle.yScreenSize = pYScreenSize

    myTentacle.vx = 0
    myTentacle.vy = 0
    myTentacle.mapSidePosition = ""       -- up, down, left, right

    myTentacle.images = {}
    myTentacle.frame = 1

    myTentacle.life = 0
    myTentacle.timeToShoot = 0

    myTentacle.lstBullet = {}

--------------------------------------------------------------------------------------------------------
    -- METHODS
    function myTentacle:draw()
        love.graphics.draw(self.images[math.floor(self.frame)], self.x, self.y, math.rad(self.rotation), self.sx*SPRITE_RATIO, self.sy*SPRITE_RATIO)  --, self.flip, 1) --, self.w/2, self.h-6) -- player.h/2)

        -- DEBUG
        if DEBUG_MODE == true then
            love.graphics.setColor(1,0,0)
            love.graphics.circle("fill", self.x, self.y, 5)
            love.graphics.setColor(1,1,1)

            love.graphics.print("bullets:"..tostring(#self.lstBullet), self.x-30, self.y)
        end
    end


    function myTentacle:update(dt)
        -- Monster animation
        self:PlayAnimation(dt)

        -- Shoot a new bullet
        self.timeToShoot = self.timeToShoot - 1 * dt
        if self.timeToShoot < 0 then
            self.timeToShoot = math.random(TIME_MIN_SHOOT_BULLET, TIME_MAX_SHOOT_BULLET)
            self:ShootBullet()
        end
    end

--------------------------------------------------------------------------------------------------------

    function myTentacle:InitTentacle(pX, pY, pAnimationFile, pAnimationNumberFrames, pMonsterSidePosition)
        self.lstBullet = {}

        self.x = pX
        self.y = pY
        self.mapSidePosition = pMonsterSidePosition

        self.life = math.random(TENTACLE_MIN_LIFE, TENTACLE_MAX_LIFE)
        self.timeToShoot = math.random(TIME_MIN_SHOOT_BULLET, TIME_MAX_SHOOT_BULLET)

        self:LoadAnimation(pAnimationFile, pAnimationNumberFrames)
        self:SetSidePosition()
    end


    function myTentacle:LoadAnimation(pImageName, pImageNumber)
        for i = 1, pImageNumber do
            self.images[i] = love.graphics.newImage("images/monster/"..pImageName..tostring(i)..".png")
        end

        self.w = self.images[1]:getWidth() * SPRITE_RATIO
        self.h = self.images[1]:getHeight() * SPRITE_RATIO
    end


    function myTentacle:PlayAnimation(dt)
        self.frame = self.frame + FRAME_PER_SECOND_TENTACLE * dt
        if self.frame > #self.images then
            self.frame = 1
        end
    end

--------------------------------------------------------------------------------------------------------

    -- Create a new bullet
    function myTentacle:ShootBullet()
        local xTentacle, yTentacle = 0, 0
        local vxTentacle, vyTentacle = 0, 0

        if self.mapSidePosition == "up" then
            xTentacle = self.x + self.w/2
            yTentacle = self.y + 5
            vxTentacle = 0
            vyTentacle = math.random(300, 200)
        elseif self.mapSidePosition == "down" then
            xTentacle = self.x + self.w/2
            yTentacle = self.y - 5
            vxTentacle = 0
            vyTentacle = math.random(-300, -200)
        elseif self.mapSidePosition == "left" then
            xTentacle = self.x + 5-- + 16                 -- 16px = bullet sprite size
            yTentacle = self.y + self.w/2
            vxTentacle = math.random(300, 200)
            vyTentacle = 0
        elseif self.mapSidePosition == "right" then
            xTentacle = self.x - 5
            yTentacle = self.y + self.w/2
            vxTentacle = math.random(-300, -200)
            vyTentacle = 0
        end

        local myBullet = BULLET.NewBullet(self.map_Object, self.xScreenSize, self.yScreenSize)
        myBullet:InitBullet(xTentacle, yTentacle, "monster_bullet", 1, vxTentacle, vyTentacle, self.mapSidePosition)
        table.insert(self.lstBullet, myBullet)
    end


    -- Set tentacle side position
    function myTentacle:SetSidePosition()
        if self.mapSidePosition == "up" then
            self.sx = -1
            self.sy = 1
            self.rotation = 180
        elseif self.mapSidePosition == "down" then
            self.sx = -1
            self.sy = -1
            self.rotation = 180
        elseif self.mapSidePosition == "left" then
            self.sx = 1
            self.sy = 1
            self.rotation = 90
        elseif self.mapSidePosition == "right" then
            self.sx = 1
            self.sy = -1
            self.rotation = 90
        end
    end

--------------------------------------------------------------------------------------------------------

    return myTentacle
end


return TENTACLE