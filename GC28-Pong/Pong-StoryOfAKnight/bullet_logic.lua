local BULLET = {}
local EXPLOSION = require("explosion_logic")
local PARTICLES = require("particles_factory")

require("param")


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
    myBullet.ox = 0
    myBullet.oy = 0

    myBullet.vx = 0
    myBullet.vy = 0
    myBullet.speed = 0
    myBullet.mapSidePosition = ""       -- up, down, left, right

    myBullet.isMarkedToDestroy = false
    myBullet.isToDestroy = false
    myBullet.IsToDelete = false

    myBullet.images = {}
    myBullet.frame = 1

    myBullet.type = 0

    myBullet.explosion = {}                -- to display an explosion when the enemy die
    myBullet.explosion.obj = EXPLOSION.NewExplosion()
    myBullet.explosion.x = 0
    myBullet.explosion.y = 0
    myBullet.explosion.ratio = SPRITE_BULLET_RATIO

    myBullet.particles = {}
    myBullet.particles.obj = PARTICLES.NewParticles()
    myBullet.particles.x = 0
    myBullet.particles.y = 0
    myBullet.particles.ratio = SPRITE_BULLET_RATIO

--------------------------------------------------------------------------------------------------------
    -- METHODS
    function myBullet:draw()
        if self.isToDestroy then
            if self.explosion.obj.isFinished == false then
                self.explosion.obj:draw()
            end
        else
            -- Draw particles (if any particles exists)
            if #self.particles.obj.lstParticles > 0 then
                self.particles.obj:draw()
            end

            love.graphics.draw(self.images[math.floor(self.frame)], self.x, self.y, math.rad(self.rotation), self.sx*SPRITE_BULLET_RATIO, self.sy*SPRITE_BULLET_RATIO, self.ox, self.oy)
        end

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
        if self.isToDestroy then
            self.explosion.obj:update(dt)

            -- To remove the enemy in the list in "monster_logic" when the animation is finished
            if self.explosion.obj.isFinished then
                self.IsToDelete = true
            end
        else
            -- Bullet animation
            self:PlayAnimation(dt)

            -- Move bullet
            self.x = self.x + self.vx * dt
            self.y = self.y + self.vy * dt

            -- Check if the bullet must be destroyed
            self:CheckIfToDestroy()

            -- Draw particles (if any particles exists)
            if #self.particles.obj.lstParticles > 0 then
                self.particles.obj:update(dt)
            end
        end
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
            self.images[i] = love.graphics.newImage("images/shoot/"..pImageName..tostring(i)..".png")
        end

        self.w = self.images[1]:getWidth() * SPRITE_BULLET_RATIO
        self.h = self.images[1]:getHeight() * SPRITE_BULLET_RATIO
    end


    function myBullet:PlayAnimation(dt)
        self.frame = self.frame + FRAME_PER_SECOND * dt
        if self.frame > #self.images+1 then
            self.frame = 1
        end
    end

--------------------------------------------------------------------------------------------------------

    -- Check collision with the player
    function myBullet:CheckPlayerCollision(pPlayerObject)
        -- Check if bullet coordinates are the same as the player
        if self.mapSidePosition == "up" then
            if (self.x >= pPlayerObject.x and self.x <= pPlayerObject.x + pPlayerObject.w)
            and (self.y >= pPlayerObject.y + 10) then
                self.vy = self.vy * -1
                self.sy = self.sy * -1      -- invert the bullet image
                self.y = pPlayerObject.y + 10

                -- Create particles
                self.particles.obj:InitParticules(self.x, self.y, self.particles.ratio, 20, 1, 4)

                return true
            end
        elseif self.mapSidePosition == "down" then
            if (self.x >= pPlayerObject.x and self.x <= pPlayerObject.x + pPlayerObject.w)
            and (self.y <= pPlayerObject.y + pPlayerObject.h) then
                self.vy = self.vy * -1
                self.sy = self.sy * -1      -- invert the bullet image
                self.y = pPlayerObject.y + pPlayerObject.h

                -- Create particles
                self.particles.obj:InitParticules(self.x, self.y, self.particles.ratio, 20, 1, 4)

                return true
            end
        elseif self.mapSidePosition == "left" then
            if (self.x >= pPlayerObject.x + pPlayerObject.w/2 - 20)
            and (self.y >= pPlayerObject.y + 5 and self.y <= pPlayerObject.y + pPlayerObject.h) then
                self.vx = self.vx * -1
                self.sy = self.sy * -1      -- invert the bullet image
                self.x = pPlayerObject.x -- + pPlayerObject.w/2 - 20

                -- Create particles
                self.particles.obj:InitParticules(self.x, self.y, self.particles.ratio, 20, 1, 4)

                return true
            end
        elseif self.mapSidePosition == "right" then
            if (self.x <= pPlayerObject.x + pPlayerObject.w/2 + 20)
            and (self.y >= pPlayerObject.y + 5 and self.y <= pPlayerObject.y + pPlayerObject.h) then
                self.vx = self.vx * -1
                self.sy = self.sy * -1      -- invert the bullet image
                self.x = pPlayerObject.x + pPlayerObject.w/2 + 20

                -- Create particles
                self.particles.obj:InitParticules(self.x, self.y, self.particles.ratio, 20, 1, 4)

                return true
            end
        end

        return false
    end


    -- Check if the bullet go outside the screen
    function myBullet:CheckOutboundCollision()
        if self.mapSidePosition == "up" then
            if self.y >= Y_SCREENSIZE then
                return true
            end
        elseif self.mapSidePosition == "down" then
            if self.y <= 0 then
                return true
            end
        elseif self.mapSidePosition == "left" then
            if self.x >= X_SCREENSIZE then
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
            if self.y <= pEnemyObject.y + pEnemyObject.h/2 then
                return true
            end
        elseif self.mapSidePosition == "down" then
            if self.y >= pEnemyObject.y + pEnemyObject.h/2 then
                return true
            end
        elseif self.mapSidePosition == "left" then
            if self.x <= pEnemyObject.x + pEnemyObject.w/2 then
                return true
            end
        elseif self.mapSidePosition == "right" then
            if self.x >= pEnemyObject.x - pEnemyObject.w/2 then
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
            self.rotation = 0 --180
        elseif self.mapSidePosition == "down" then
            self.sx = -1
            self.sy = -1
            self.rotation = 0 --180
        elseif self.mapSidePosition == "left" then
            self.sx = 1
            self.sy = -1
            self.rotation = 90
        elseif self.mapSidePosition == "right" then
            self.sx = -1
            self.sy = 1
            self.rotation = 90 --90
        end

        self.ox = self.w/2
        self.oy = self.h
    end


    -- Action to perform when the bullet must be destroy
    function myBullet:CheckIfToDestroy()
        if self.isMarkedToDestroy then
            if self.vx > 0 then     -- the bullet go from left to right  (can't perform by position, because it could rebound)
                self.explosion.x = self.x - self.w/2
                self.explosion.y = self.y + self.h/2
            elseif self.vx < 0 then
                self.explosion.x = self.x + self.w/2
                self.explosion.y = self.y + self.h/2
            elseif self.vy > 0 then     -- the bullet go from up to bottom
                self.explosion.x = self.x + self.w/2
                self.explosion.y = self.y - self.h/2
            elseif self.vy < 0 then
                self.explosion.x = self.x + self.w/2
                self.explosion.y = self.y + self.h/2
            end

            self.explosion.obj:InitExplosion(self.explosion.x, self.explosion.y, self.explosion.ratio, 0, "explosion", 9)

            self.isToDestroy = true
        end
    end

--------------------------------------------------------------------------------------------------------

    return myBullet
end


return BULLET
