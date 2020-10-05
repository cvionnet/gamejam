local BULLET = {}

require("param")


function BULLET.NewBullet(pMapObject, pXScreenSize, pYScreenSize)
    -- PROPERTIES
    local myBullet = {}

    myBullet.map_Object = pMapObject

    myBullet.x = 0
    myBullet.y = 0
    myBullet.h = 0
    myBullet.w = 0
    myBullet.sx = 0    -- used to flip the sprite
    myBullet.sy = 0
    myBullet.rotation = 0

    myBullet.xScreenSize = pXScreenSize
    myBullet.yScreenSize = pYScreenSize

    myBullet.vx = 0
    myBullet.vy = 0
    myBullet.speed = 0
    myBullet.mapSidePosition = ""       -- up, down, left, right

    myBullet.images = {}
    myBullet.frame = 1

    myBullet.type = 0

--------------------------------------------------------------------------------------------------------
    -- METHODS
    function myBullet:draw()

        love.graphics.draw(self.images[math.floor(self.frame)], self.x, self.y, math.rad(self.rotation), self.sx*SPRITE_BULLET_RATIO, self.sy*SPRITE_BULLET_RATIO)  --, self.flip, 1) --, self.w/2, self.h-6) -- player.h/2)

        -- DEBUG
        if DEBUG_MODE == true then
            --love.graphics.setColor(1,0,0)
            --love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
            --love.graphics.setColor(1,1,1)

            love.graphics.setColor(1,0,0)
            love.graphics.circle("fill", self.x, self.y, 5)
            love.graphics.setColor(1,1,1)

            love.graphics.print("x:"..tostring(math.floor(self.x)).." / y:"..tostring(math.floor(self.y)), self.x, self.y-10)
        end
    end


    function myBullet:update(dt)
        -- Bullet animation
        self:PlayAnimation(dt)

        -- Move bullet
        self.x = self.x + self.vx * dt
        self.y = self.y + self.vy * dt
    end

--------------------------------------------------------------------------------------------------------

    function myBullet:InitBullet(pX, pY, pAnimationFile, pAnimationNumberFrames, pVx, pVy, pEnemySidePosition)
        self.x = pX
        self.y = pY
        self.vx = pVx
        self.vy = pVy
        self.mapSidePosition = pEnemySidePosition

        self:LoadAnimation(pAnimationFile, pAnimationNumberFrames)
        self:SetSidePosition()
    end


    function myBullet:LoadAnimation(pImageName, pImageNumber)
        for i = 1, pImageNumber do
            self.images[i] = love.graphics.newImage("images/monster/"..pImageName..tostring(i)..".png")
        end

        self.w = self.images[1]:getWidth() * SPRITE_BULLET_RATIO
        self.h = self.images[1]:getHeight() * SPRITE_BULLET_RATIO
    end


    function myBullet:PlayAnimation(dt)
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

    -- Check collision with the player
    function myBullet:CheckPlayerCollision(pPlayerObject)
        -- Check if bullet coordinates are the same as the player
        if self.mapSidePosition == "up" then
            if (self.y >= pPlayerObject.y) and (self.x >= pPlayerObject.x and self.x <= pPlayerObject.x + pPlayerObject.w) then
                self.vy = self.vy * -1
                self.sy = self.sy * -1      -- invert the bullet image
                self.y = pPlayerObject.y
                return true
            end
        elseif self.mapSidePosition == "down" then
            if (self.y <= pPlayerObject.y + pPlayerObject.h) and (self.x >= pPlayerObject.x and self.x <= pPlayerObject.x + pPlayerObject.w) then
                self.vy = self.vy * -1
                self.sy = self.sy * -1      -- invert the bullet image
                self.y = pPlayerObject.y + pPlayerObject.h
                return true
            end
        elseif self.mapSidePosition == "left" then
            if (self.x >= pPlayerObject.x) and (self.y >= pPlayerObject.y and self.y <= pPlayerObject.y + pPlayerObject.h) then
                self.vx = self.vx * -1
                self.sy = self.sy * -1      -- invert the bullet image
                self.x = pPlayerObject.x
                return true
            end
        elseif self.mapSidePosition == "right" then
            if (self.x <= pPlayerObject.x + pPlayerObject.w) and (self.y >= pPlayerObject.y and self.y <= pPlayerObject.y + pPlayerObject.h) then
                self.vx = self.vx * -1
                self.sy = self.sy * -1      -- invert the bullet image
                self.x = pPlayerObject.x + pPlayerObject.w
                return true
            end
        end

        return false
    end


    -- Check if the bullet go outside the screen
    function myBullet:CheckOutboundCollision()
        if self.mapSidePosition == "up" then
            if self.y >= self.yScreenSize then
                return true
            end
        elseif self.mapSidePosition == "down" then
            if self.y <= 0 then
                return true
            end
        elseif self.mapSidePosition == "left" then
            if self.x >= self.xScreenSize then
                return true
            end
        elseif self.mapSidePosition == "right" then
            if self.x <= 0 then
                return true
            end
        end

        return false
    end


    -- Check if the bullet touch the enemies
    -- ! direction is inverted, the bullet has rebounded on the player
    function myBullet:CheckEnemyCollision(pEnemyObject)
        -- Check if bullet coordinates are the same as the enemy
        if self.mapSidePosition == "up" then
            if self.y <= pEnemyObject.y then
                return true
            end
        elseif self.mapSidePosition == "down" then
            if self.y >= pEnemyObject.y then
                return true
            end
        elseif self.mapSidePosition == "left" then
            if self.x <= pEnemyObject.x then
                return true
            end
        elseif self.mapSidePosition == "right" then
            if self.x >= pEnemyObject.x then
                return true
            end
        end

        return false
    end

--------------------------------------------------------------------------------------------------------

    -- Set bullet side position
    function myBullet:SetSidePosition()
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

    return myBullet
end


return BULLET