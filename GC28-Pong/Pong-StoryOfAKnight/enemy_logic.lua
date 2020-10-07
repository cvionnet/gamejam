local ENEMY = {}

local BULLET = require("bullet_logic")
require("param")


function ENEMY.NewEnemy(pMapObject)
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

    myEnemy.vx = 0
    myEnemy.vy = 0
    myEnemy.mapSidePosition = ""       -- up, down, left, right

    myEnemy.images = {}
    myEnemy.frame = 1

    myEnemy.life = 0
    myEnemy.timeToShoot = 0
    myEnemy.timeHurtPlayer = TIME_HURT_PLAYER

    myEnemy.lstBullet = {}

--------------------------------------------------------------------------------------------------------
    -- METHODS
    function myEnemy:draw()
        love.graphics.draw(self.images[math.floor(self.frame)], self.x, self.y, math.rad(self.rotation), self.sx*SPRITE_ENEMY_RATIO, self.sy*SPRITE_ENEMY_RATIO)

        -- DEBUG
        if DEBUG_MODE == true then
            love.graphics.setColor(1,0,0)
            love.graphics.circle("fill", self.x, self.y, 5)
            love.graphics.setColor(1,1,1)

            love.graphics.print("bullets:"..tostring(#self.lstBullet), self.x-30, self.y)
        end
    end


    function myEnemy:update(dt, pPlayerObject)
        -- Monster animation
        self:PlayAnimation(dt)

        -- Check for a collision with the player
        self:CheckPlayerCollision(dt, pPlayerObject)

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
        self.frame = self.frame + dt -- + FRAME_PER_SECOND_ENEMY * dt
        if self.frame > #self.images+1 then
            self.frame = 1
        end
    end

--------------------------------------------------------------------------------------------------------

    -- Check collision with the player
    function myEnemy:CheckPlayerCollision(dt, pPlayerObject)
        local isPlayerHurt = false

        -- Check if enemy coordinates are the same as the player
        if self.mapSidePosition == "up" then
            if self.y >= pPlayerObject.y then isPlayerHurt = true end
        elseif self.mapSidePosition == "down" then
            if self.y <= pPlayerObject.y + pPlayerObject.h then isPlayerHurt = true end
        elseif self.mapSidePosition == "left" then
            if self.x >= pPlayerObject.x then isPlayerHurt = true end
            if (pPlayerObject.x >= self.x and pPlayerObject.x <= self.x + self.w) and (pPlayerObject.y >= self.y and pPlayerObject.y <= self.y + self.h) then isPlayerHurt = true end
        elseif self.mapSidePosition == "right" then
            if (pPlayerObject.x >= self.x and pPlayerObject.x <= self.x + self.w) and (pPlayerObject.y >= self.y and pPlayerObject.y <= self.y + self.h) then isPlayerHurt = true end
        end

        -- Decrease player's life
        if isPlayerHurt then
            self.timeHurtPlayer = self.timeHurtPlayer - 1 * dt
            if self.timeHurtPlayer <= 0 then
                self.timeHurtPlayer = TIME_HURT_PLAYER
                pPlayerObject.life = pPlayerObject.life - 1
            end
        end

    end

--------------------------------------------------------------------------------------------------------

    -- Create a new bullet
    function myEnemy:ShootBullet()
        local xBullet, yBullet = 0, 0
        local vxBullet, vyBullet = 0, 0
        local imageBulletH, imageBulletW = self.map_Object:GetImageH_W("/images/shoot/frame1.png")
        imageBulletH, imageBulletW = imageBulletH*SPRITE_BULLET_RATIO, imageBulletW*SPRITE_BULLET_RATIO

        if self.mapSidePosition == "up" then
            xBullet = self.x - self.w/2 + imageBulletW/2
            yBullet = self.y + self.h/2 + 5
            vxBullet = 0
            vyBullet = math.random(BULLET_MIN_SPEED, BULLET_MAX_SPEED)
        elseif self.mapSidePosition == "down" then
            xBullet = self.x - self.w/2 + imageBulletW/2
            yBullet = self.y + self.h/2 - 5
            vxBullet = 0
            vyBullet = math.random(-BULLET_MAX_SPEED, -BULLET_MIN_SPEED)
        elseif self.mapSidePosition == "left" then
            xBullet = self.x + self.w/2 + 5
            yBullet = self.y + self.h/2 -- - imageBulletH/2
            vxBullet = math.random(BULLET_MIN_SPEED, BULLET_MAX_SPEED)
            vyBullet = 0
        elseif self.mapSidePosition == "right" then
            xBullet = self.x - self.w/2 - 5
            yBullet = self.y + self.h/2 + imageBulletH/2
            vxBullet = math.random(-BULLET_MAX_SPEED, -BULLET_MIN_SPEED)
            vyBullet = 0
        end

        local myBullet = BULLET.NewBullet(self.map_Object)
        myBullet:InitBullet(xBullet, yBullet, "frame", 11, vxBullet, vyBullet, self.mapSidePosition)
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
            self.sy = 1
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