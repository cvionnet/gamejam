local BULLET = {}

local FRAME_PER_SECOND = 24


function BULLET.NewBullet(pMapObject)
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

    myBullet.vx = 0
    myBullet.vy = 0
    myBullet.speed = 0
    myBullet.mapSidePosition = ""       -- up, down, left, right

    myBullet.images = {}
    myBullet.frame = 1

    myBullet.type = 0
    myBullet.speedShoot = 0

--------------------------------------------------------------------------------------------------------
    -- METHODS
    function myBullet:draw(DEBUG_MODE)

        love.graphics.draw(self.images[math.floor(self.frame)], self.x, self.y, math.rad(self.rotation), self.sx, self.sy)  --, self.flip, 1) --, self.w/2, self.h-6) -- player.h/2)

        -- DEBUG - draw player box
        if DEBUG_MODE == true then
            love.graphics.setColor(1,0,0)
            love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
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

    function myBullet:InitBullet(pX, pY, pAnimationFile, pAnimationNumberFrames, pVx, pVy)
        self.x = pX
        self.y = pY
        self.vx = pVx
        self.vy = pVy
        self.sx = 1
        self.sy = -1
        self.rotation = 90
        self.mapSidePosition = "right"

        self:LoadAnimation(pAnimationFile, pAnimationNumberFrames)
    end


    function myBullet:LoadAnimation(pImageName, pImageNumber)
        for i = 1, pImageNumber do
            self.images[i] = love.graphics.newImage("images/monster/"..pImageName..tostring(i)..".png")
        end

        self.w = self.images[1]:getWidth()
        self.h = self.images[1]:getHeight()
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
        if self.mapSidePosition == "up" or self.mapSidePosition == "down" then

        elseif self.mapSidePosition == "left" then

        elseif self.mapSidePosition == "right" then
            if (self.x <= pPlayerObject.x + self.map_Object.TILE_WIDTH) and (self.y >= pPlayerObject.y and self.y <= pPlayerObject.y + self.map_Object.TILE_HEIGHT) then
                self.vx = self.vx * -1
                self.x = pPlayerObject.x + self.map_Object.TILE_WIDTH
                return true
            end
        end

        return false
    end

    -- Check if the bullet go outside the screen
    function myBullet:CheckOutboundCollision()
        if self.mapSidePosition == "up" or self.mapSidePosition == "down" then

        elseif self.mapSidePosition == "left" then

        elseif self.mapSidePosition == "right" then
            if self.x <= 0 then
                return true
            end
        end

        return false
    end


    -- Check if the bullet touch the tentacle
    function myBullet:CheckTentaculeCollision(pTentacleObject)
        -- Check if bullet coordinates are the same as the tentacle
        if self.mapSidePosition == "up" or self.mapSidePosition == "down" then

        elseif self.mapSidePosition == "left" then

        elseif self.mapSidePosition == "right" then
            if self.x >= pTentacleObject.x then
                return true
            end
        end

        return false
    end

--------------------------------------------------------------------------------------------------------

    -- If a bullet go outside the screen, it hit the village
    function myBullet:HitVillage(pPlayerObject)
        pPlayerObject.villageLife = pPlayerObject.villageLife - 1
    end


    -- If a bullet touch the tentacle, reduce its life
    function myBullet:HitTentacle(pTentacleObject)
        pTentacleObject.life = pTentacleObject.life - 1
        print(pTentacleObject.life)
    end

--------------------------------------------------------------------------------------------------------

    return myBullet
end


return BULLET