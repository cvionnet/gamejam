local ENEMY = {}

local BULLET = require("bullet_logic")
require("param")


function ENEMY.NewEnemy(pMapObject, pXScreenSize, pYScreenSize)
    -- PROPERTIES
    local myEnemy = {}

    myEnemy.map_Object = pMapObject

    myEnemy.x = 0
    myEnemy.y = 0
    myEnemy.h = 0
    myEnemy.w = 0
    myEnemy.sx = 0    -- used to flip the sprite
    myEnemy.sy = 0
    myEnemy.rotation = 0

    myEnemy.xScreenSize = pXScreenSize
    myEnemy.yScreenSize = pYScreenSize

    myEnemy.vx = 0
    myEnemy.vy = 0
    myEnemy.mapSidePosition = ""       -- up, down, left, right

    myEnemy.images = {}
    myEnemy.frame = 1

    myEnemy.life = 0
    myEnemy.timeToShoot = 0

    myEnemy.lstBullet = {}

--------------------------------------------------------------------------------------------------------
    -- METHODS
    function myEnemy:draw()
        love.graphics.draw(self.images[math.floor(self.frame)], self.x, self.y, math.rad(self.rotation), self.sx*SPRITE_ENEMY_RATIO, self.sy*SPRITE_ENEMY_RATIO)  --, self.flip, 1) --, self.w/2, self.h-6) -- player.h/2)

        -- DEBUG
        if DEBUG_MODE == true then
            love.graphics.setColor(1,0,0)
            love.graphics.circle("fill", self.x, self.y, 5)
            love.graphics.setColor(1,1,1)

            love.graphics.print("bullets:"..tostring(#self.lstBullet), self.x-30, self.y)
        end
    end


    function myEnemy:update(dt)
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

    function myEnemy:InitEnemy(pX, pY, pAnimationFile, pAnimationNumberFrames, pMonsterSidePosition)
        self.lstBullet = {}

        self.x = pX
        self.y = pY
        self.mapSidePosition = pMonsterSidePosition

        self.life = math.random(ENEMY_MIN_LIFE, ENEMY_MAX_LIFE)
        self.timeToShoot = math.random(TIME_MIN_SHOOT_BULLET, TIME_MAX_SHOOT_BULLET)

        self:LoadAnimation(pAnimationFile, pAnimationNumberFrames)
        self:SetSidePosition()
    end


    function myEnemy:LoadAnimation(pImageName, pImageNumber)
        for i = 1, pImageNumber do
            self.images[i] = love.graphics.newImage("images/monster/"..pImageName..tostring(i)..".png")
        end

        self.w = self.images[1]:getWidth() * SPRITE_ENEMY_RATIO
        self.h = self.images[1]:getHeight() * SPRITE_ENEMY_RATIO
    end


    function myEnemy:PlayAnimation(dt)
        self.frame = self.frame + FRAME_PER_SECOND_ENEMY * dt
        if self.frame > #self.images then
            self.frame = 1
        end
    end

--------------------------------------------------------------------------------------------------------

    -- Create a new bullet
    function myEnemy:ShootBullet()
        local xEnemy, yEnemy = 0, 0
        local vxEnemy, vyEnemy = 0, 0

        if self.mapSidePosition == "up" then
            xEnemy = self.x + self.w/2
            yEnemy = self.y + 5
            vxEnemy = 0
            vyEnemy = math.random(300, 200)
        elseif self.mapSidePosition == "down" then
            xEnemy = self.x + self.w/2
            yEnemy = self.y - 5
            vxEnemy = 0
            vyEnemy = math.random(-300, -200)
        elseif self.mapSidePosition == "left" then
            xEnemy = self.x + 5-- + 16                 -- 16px = bullet sprite size
            yEnemy = self.y + self.w/2
            vxEnemy = math.random(300, 200)
            vyEnemy = 0
        elseif self.mapSidePosition == "right" then
            xEnemy = self.x - 5
            yEnemy = self.y + self.w/2
            vxEnemy = math.random(-300, -200)
            vyEnemy = 0
        end

        local myBullet = BULLET.NewBullet(self.map_Object, self.xScreenSize, self.yScreenSize)
        myBullet:InitBullet(xEnemy, yEnemy, "monster_bullet", 1, vxEnemy, vyEnemy, self.mapSidePosition)
        table.insert(self.lstBullet, myBullet)
    end


    -- Set enemy side position
    function myEnemy:SetSidePosition()
        if self.mapSidePosition == "up" then
            self.sx = -1
            self.sy = 1
            self.rotation = 0 --180
        elseif self.mapSidePosition == "down" then
            self.sx = -1
            self.sy = -1
            self.rotation = 0 --180
        elseif self.mapSidePosition == "left" then
            self.sx = -1
            self.sy = -1
            self.rotation = 180 --90
        elseif self.mapSidePosition == "right" then
            self.sx = 1
            self.sy = -1
            self.rotation = 180 --90
        end
    end

--------------------------------------------------------------------------------------------------------

    return myEnemy
end


return ENEMY