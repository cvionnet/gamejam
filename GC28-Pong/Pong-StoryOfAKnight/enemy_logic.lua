local ENEMY = {}

local BULLET = require("bullet_logic")
local EXPLOSION = require("explosion_logic")

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
    myEnemy.finalPositionX = 0
    myEnemy.finalPositionY = 0
    myEnemy.alpha = 0

    myEnemy.frame = 1
    myEnemy.currentAnimation = ""
    myEnemy.lstAnimations = {}                         -- stock all images of an animation ("run1", "run2"...), indexed by a name (eg :  lstAnimations["run"])
    myEnemy.lstAnimationsImages = {}                   -- stock all images (Love2d object) used in all animations, indexed by mage name (eg : "run1", "run2"...)

    myEnemy.life = 0
    myEnemy.isHit = false
    myEnemy.isDead = false
    myEnemy.IsToDelete = false

    myEnemy.timeToShoot = 0
    myEnemy.timeHurtPlayer = TIME_HURT_PLAYER

    myEnemy.lstBullet = {}

    myEnemy.explosion = {}                -- to display an explosion when the enemy die
    myEnemy.explosion.obj = EXPLOSION.NewExplosion()
    myEnemy.explosion.x = 0
    myEnemy.explosion.y = 0
    myEnemy.explosion.ratio = SPRITE_ENEMY_RATIO

--------------------------------------------------------------------------------------------------------
    -- METHODS
    function myEnemy:draw()
        if self.isDead then
            if self.explosion.obj.isFinished == false then
                self.explosion.obj:draw()
            end
        else
            self:drawAnimation()
        end

        -- DEBUG
        if DEBUG_MODE == true then
            love.graphics.setColor(1,0,0)
            love.graphics.circle("fill", self.x, self.y, 5)
            love.graphics.setColor(1,1,1)

            love.graphics.print("bullets:"..tostring(#self.lstBullet), self.x-30, self.y)
        end
    end


    function myEnemy:update(dt, pPlayerObject)
        if self.isDead then
            self.explosion.obj:update(dt)

            -- To remove the enemy in the list in "monster_logic" when the animation is finished
            if self.explosion.obj.isFinished then
                self.IsToDelete = true
            end
        else
            -- Monster animation
            if self.currentAnimation == "walk" then
                self:updateComing(dt)
            end

            self:updateAnimation(dt)

            -- Check for a collision with the player
            self:CheckPlayerCollision(dt, pPlayerObject)

            -- Shoot a new bullet
            if self.currentAnimation ~= "walk" then
                self.timeToShoot = self.timeToShoot - 1 * dt
                if self.timeToShoot < 0 then
                    self:PlayAnimation("attack")

                    self.timeToShoot = math.random(TIME_MIN_SHOOT_BULLET, TIME_MAX_SHOOT_BULLET)
                    self:ShootBullet()
                end
            end

            -- Check if the enemy is dead
            self:CheckIfDead()
        end
    end

--------------------------------------------------------------------------------------------------------

    function myEnemy:InitEnemy(pX, pY, pMonsterSidePosition)
        self.lstBullet = {}

        self.finalPositionX = pX
        self.finalPositionY = pY
        self.mapSidePosition = pMonsterSidePosition
        self.alpha = 0

        self.life = math.random(ENEMY_MIN_LIFE, ENEMY_MAX_LIFE)
        self.timeToShoot = math.random(TIME_MIN_SHOOT_BULLET, TIME_MAX_SHOOT_BULLET)

        self:AddNewAnimation("idle", "images/monster/idle", { "knight_evil_side_idle1", "knight_evil_side_idle2" })
        self:AddNewAnimation("walk", "images/monster/walk", { "knight_evil_side_walk1", "knight_evil_side_walk2", "knight_evil_side_walk3", "knight_evil_side_walk4" })
        self:AddNewAnimation("attack", "images/monster/attack", { "knight_evil_side_attack1", "knight_evil_side_attack2", "knight_evil_side_attack3", "knight_evil_side_attack4", "knight_evil_side_attack5", "knight_evil_side_attack6" })
        self:PlayAnimation("walk")

        self:SetSidePosition()
    end

--------------------------------------------------------------------------------------------------------

    -- Move the monster on the field
    function myEnemy:updateComing(dt)
        -- Move the monster
        self.x = self.x + self.vx * dt
        self.y = self.y + self.vy * dt

        -- Make the monster appear from the fog
        if self.alpha < 1 then
            self.alpha = self.alpha + dt/3
        else
            self.alpha = 1
        end

        -- Check if final position is reached, and then set the monster to fighting mode
        if self.mapSidePosition == "up" then
            if self.y >= self.finalPositionY then
                self.y = self.finalPositionY
                self.vy = 0
                self:PlayAnimation("idle")
            end
        elseif self.mapSidePosition == "down" then
            if self.y <= self.finalPositionY then
                self.y = self.finalPositionY
                self.vy = 0
                self:PlayAnimation("idle")
            end
        elseif self.mapSidePosition == "left" then
            if self.x >= self.finalPositionX then
                self.x = self.finalPositionX
                self.vx = 0
                self:PlayAnimation("idle")
            end
        elseif self.mapSidePosition == "right" then
            if self.x <= self.finalPositionX then
                self.x = self.finalPositionX
                self.vx = 0
                self:PlayAnimation("idle")
            end
        end
    end

--------------------------------------------------------------------------------------------------------

    -- Create a new animation
    function myEnemy:AddNewAnimation(pName, pFolder, pListImages)
        self:AddAnimationImages(pFolder, pListImages)
        self.lstAnimations[pName] = pListImages
    end


    -- Load images used for an animation (from a folder)
    function myEnemy:AddAnimationImages(pFolder, pListImages)
        for key, image in pairs(pListImages) do
            local fileName = pFolder.."/"..image..".png"
            self.lstAnimationsImages[image] = love.graphics.newImage(fileName)
        end

        self.w = self.lstAnimationsImages["knight_evil_side_idle1"]:getWidth() * SPRITE_ENEMY_RATIO
        self.h = self.lstAnimationsImages["knight_evil_side_idle1"]:getHeight() * SPRITE_ENEMY_RATIO
    end


    -- Prepare the animation before being played
    function myEnemy:PlayAnimation(pName)
        if self.currentAnimation ~= pName then
            self.currentAnimation = pName
            self.frame = 1
        end
    end


    function myEnemy:drawAnimation()
        local imgName = self.lstAnimations[self.currentAnimation][math.floor(self.frame)]    -- get image name for the current animation and the current fame  (eg : for "run" and frame=1, get "run1")
        local img = self.lstAnimationsImages[imgName]       -- get Love2d image object from the name of the image


        if myEnemy.isHit then
            love.graphics.setShader(shaderBlink)
            shaderBlink:send("WhiteFactor", 1)

            love.graphics.draw(img, self.x, self.y, math.rad(self.rotation), self.sx*SPRITE_ENEMY_RATIO, self.sy*SPRITE_ENEMY_RATIO)

            love.graphics.setShader()
            self.isHit = false
        else
            love.graphics.setColor(1,1,1,self.alpha)
            love.graphics.draw(img, self.x, self.y, math.rad(self.rotation), self.sx*SPRITE_ENEMY_RATIO, self.sy*SPRITE_ENEMY_RATIO)
            love.graphics.setColor(1,1,1,1)
        end
    end


    function myEnemy:updateAnimation(dt)
        if self.currentAnimation ~= "" then
            if self.currentAnimation == "walk" then
                self.frame = self.frame + FRAME_PER_SECOND_ENEMY * dt
            elseif self.currentAnimation == "attack" then
                self.frame = self.frame + FRAME_PER_SECOND_ENEMY_ATTACK * dt
            elseif self.currentAnimation == "idle" then
                self.frame = self.frame + FRAME_PER_SECOND_ENEMY * dt
            end

            -- Reset timer
            if self.frame > #self.lstAnimations[self.currentAnimation]+1 then
                self.frame = 1

                if self.currentAnimation == "attack" then       -- after an attack, back to idle animation
                    self:PlayAnimation("idle")
                end
            end
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


    -- Set enemy side position
    function myEnemy:SetSidePosition()
        if self.mapSidePosition == "up" then
            self.x = self.finalPositionX
            self.y = -self.h
            self.vx = 0
            self.vy = ENEMY_WALKING_SPEED

            self.sx = -1
            self.sy = 1
            self.rotation = 0 --180
        elseif self.mapSidePosition == "down" then
            self.x = self.finalPositionX
            self.y = Y_SCREENSIZE
            self.vx = 0
            self.vy = -ENEMY_WALKING_SPEED

            self.sx = -1
            self.sy = 1
            self.rotation = 0 --180
        elseif self.mapSidePosition == "left" then
            self.x = -self.w
            self.y = self.finalPositionY
            self.vx = ENEMY_WALKING_SPEED
            self.vy = 0

            self.sx = -1
            self.sy = -1
            self.rotation = 180 --90
        elseif self.mapSidePosition == "right" then
            self.x = X_SCREENSIZE + self.w
            self.y = self.finalPositionY
            self.vx = -ENEMY_WALKING_SPEED
            self.vy = 0

            self.sx = 1
            self.sy = -1
            self.rotation = 180 --90
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


    -- Action to perform when the enemy is dead
    function myEnemy:CheckIfDead()
        if self.life <= 0 then
            if self.mapSidePosition == "up" then
                self.explosion.x = self.x - self.w/2
                self.explosion.y = self.y + self.h/2
            elseif self.mapSidePosition == "down" then
                self.explosion.x = self.x - self.w/2
                self.explosion.y = self.y + self.h/2
            elseif self.mapSidePosition == "left" then
                self.explosion.x = self.x + self.w/2
                self.explosion.y = self.y + self.h/2
            elseif self.mapSidePosition == "right" then
                self.explosion.x = self.x - self.w/2
                self.explosion.y = self.y + self.h/2
            end

            self.explosion.obj:InitExplosion(self.explosion.x, self.explosion.y, self.explosion.ratio, 0, "explosion", 9)

            self.isDead = true

            -- Mark all bullets to be destroyed
            for i = 1, #self.lstBullet do
                self.lstBullet[i].isMarkedToDestroy = true
            end
        end
    end


--------------------------------------------------------------------------------------------------------

    return myEnemy
end


return ENEMY