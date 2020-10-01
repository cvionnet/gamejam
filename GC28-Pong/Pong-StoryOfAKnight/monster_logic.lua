local MONSTER = {}

local TENTACLE = require("tentacle_logic")

local FRAME_PER_SECOND = 24
local TIME_WARNING = 4
local TIME_MIN_CREATE_TENTACLE = 1 --10
local TIME_MAX_CREATE_TENTACLE = 5 --20
local MAX_TENTACLE = 2 --10

local fontBig = love.graphics.newFont("fonts/Gameplay.ttf", 70)


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
    myMonster.status = ""                -- warning, moving, fighting, leaving, hiding

    myMonster.images = {}
    myMonster.frame = 1

    myMonster.life = 0

    myMonster.maxTentacles = MAX_TENTACLE
    myMonster.createdTentacles = 0
    myMonster.lstTentacles = {}

    myMonster.timeToNewTentacle = 0
    myMonster.timeWarning = TIME_WARNING

--------------------------------------------------------------------------------------------------------
    -- METHODS
    function myMonster:draw(DEBUG_MODE)
        -- Display a warning countdown
        if self.status == "warning" then
            self:drawWarning()
        else
            -- Background of the monster
            love.graphics.draw(self.images[math.floor(self.frame)], self.x, self.y, math.rad(self.rotation), self.sx, self.sy)  --, self.flip, 1) --, self.w/2, self.h-6) -- player.h/2)

            -- Tentacles
            for key, tentacle in pairs(self.lstTentacles) do
                tentacle:draw(DEBUG_MODE)

                -- Bullets
                for key1, bullet in pairs(tentacle.lstBullet) do
                    bullet:draw(DEBUG_MODE)
                end
            end
        end
    end


    function myMonster:update(dt, pPlayerObject)
        -- Display a warning where the monster will appear
        if self.status == "warning" then
            self:updateWarning(dt)
        -- Move the monster on the field
        elseif self.status == "moving" then
            self:updateMoving(dt)
        -- Move the monster out of the field
        elseif self.status == "leaving" then
            self:updateLeaving(dt)
        else
            -- Monster animation
            self:PlayAnimation(dt)

            -- Tentacles update
            for tentacleID = #self.lstTentacles, 1, -1 do
                local isTentacleToDelete = false
                local tentacle = self.lstTentacles[tentacleID]

                tentacle:update(dt)

                -- Bullets update and collision
                for bulletID = #tentacle.lstBullet, 1, -1 do
                    local bullet = tentacle.lstBullet[bulletID]

                    bullet:update(dt)

                    -- Bullet collisions
                    if self:CheckBulletWithPlayerCollision(bullet, pPlayerObject) == false then     -- with the player
                        if self:CheckBulletWithOutsideCollision(bullet, pPlayerObject) then         -- outside the screen
                            self:HitVillage(pPlayerObject)
                            table.remove(tentacle.lstBullet, bulletID)        -- delete the bullet
                        elseif self:CheckBulletWithTentacleCollision(bullet, tentacle) then         -- with a tentacle
                            isTentacleToDelete = self:HitTentacle(tentacle)
                        end
                    end
                end

                -- If the tentacle is dead, remove all its bullets and remove the tentacle
                if isTentacleToDelete then
                    -- Delete its own bullets
                    for i = #tentacle.lstBullet, 1, -1 do
                        table.remove(tentacle.lstBullet, i)
                    end

                    table.remove(self.lstTentacles, tentacleID)
                end
            end

            -- Create a new tentacle
            if self.createdTentacles < self.maxTentacles  then
                self.timeToNewTentacle = self.timeToNewTentacle - 1 * dt
                if self.timeToNewTentacle < 0 then
                    self.timeToNewTentacle = math.random(TIME_MIN_CREATE_TENTACLE, TIME_MAX_CREATE_TENTACLE)
                    self:CreateTentacle()
                end
            end

            -- If all tentacles have been destroyed, move the monster to another position
            if self.createdTentacles == self.maxTentacles and #self.lstTentacles == 0 then
                if self.mapSidePosition == "up" then

                elseif self.mapSidePosition == "down" then

                elseif self.mapSidePosition == "left" then

                elseif self.mapSidePosition == "right" then
                    self.vx = 50
                    self.status = "leaving"
                end
            end

        end
    end

--------------------------------------------------------------------------------------------------------

    -- Display a warning where the monster will appear
    function myMonster:drawWarning()
        if self.mapSidePosition == "up" then
            love.graphics.print(math.floor(self.timeWarning), fontBig, xScreenSize/2 - fontBig:getHeight()/2, self.map_Object.TILE_HEIGHT*2)
        elseif self.mapSidePosition == "down" then
            love.graphics.print(math.floor(self.timeWarning), fontBig, xScreenSize/2 - fontBig:getHeight()/2, yScreenSize - self.map_Object.TILE_HEIGHT*3)
        elseif self.mapSidePosition == "left" then
            love.graphics.print(math.floor(self.timeWarning), fontBig, self.map_Object.TILE_WIDTH*2, yScreenSize/2 - fontBig:getHeight()/2)
        elseif self.mapSidePosition == "right" then
            love.graphics.print(math.floor(self.timeWarning), fontBig, xScreenSize - self.map_Object.TILE_WIDTH*3, yScreenSize/2 - fontBig:getHeight()/2)
        end
    end

    -- Display a warning where the monster will appear
    function myMonster:updateWarning(dt)
        self.timeWarning = self.timeWarning - 1 * dt
        if self.timeWarning <= 0 then
            self.timeWarning = TIME_WARNING

            -- Set x / y to place the monster  +   vx / vy to move the monster on the field  +  sx / sy / position to display the monster
            self.status = "moving"
            if self.mapSidePosition == "up" then

            elseif self.mapSidePosition == "down" then

            elseif self.mapSidePosition == "left" then

            elseif self.mapSidePosition == "right" then
                self.x = xScreenSize
                self.y = map_Obj.TILE_HEIGHT*2
                self.vx = -50
                self.vy = 0

                self.sx = 1
                self.sy = -1
                self.rotation = 90
            end
        end
    end


    -- Move the monster on the field
    function myMonster:updateMoving(dt)
        -- Move the monster
        self.x = self.x + self.vx * dt
        self.y = self.y + self.vy * dt

        -- Check if final position is reached
        if self.mapSidePosition == "up" then

        elseif self.mapSidePosition == "down" then

        elseif self.mapSidePosition == "left" then

        elseif self.mapSidePosition == "right" then
            if self.x <= xScreenSize - map_Obj.TILE_WIDTH*2 then
                self.x = xScreenSize - map_Obj.TILE_WIDTH*2
                self.vx = 0
                self.status = "fighting"
            end
        end
    end


    -- Move the monster out of the field
    function myMonster:updateLeaving(dt)
        -- Move the monster
        self.x = self.x + self.vx * dt
        self.y = self.y + self.vy * dt

        -- Check if final position is reached
        if self.mapSidePosition == "up" then

        elseif self.mapSidePosition == "down" then

        elseif self.mapSidePosition == "left" then

        elseif self.mapSidePosition == "right" then
            if self.x >= xScreenSize then
                self.vx = 0
                self.status = "hiding"
            end
        end
    end
 
--------------------------------------------------------------------------------------------------------

    function myMonster:InitMonster(pAnimationFile, pAnimationNumberFrames, pMonsterLife)
        self.lstTentacles = {}
        self.lstBullet = {}
        self.createdTentacles = 0

        self.mapSidePosition = "right"
        self.status = "warning"

        self.life = pMonsterLife
        self.timeToNewTentacle = math.random(TIME_MIN_CREATE_TENTACLE, TIME_MAX_CREATE_TENTACLE)

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

    -- Display a tentacle on the monster
    function myMonster:CreateTentacle()

        local xTentacle, yTentacle = 0, 0
        local myTentacle = TENTACLE.NewTentacle(self.map_Object, self.xScreenSize, self.yScreenSize)

        -- Calculate tentacle position on the monster
        if  self.mapSidePosition == "right" then
            xTentacle = self.x - myTentacle.h + math.random(0, self.map_Object.TILE_HEIGHT)
            yTentacle = math.random(self.y - self.map_Object.TILE_WIDTH, self.y + self.w - self.map_Object.TILE_WIDTH - 20)
        end

        -- Set tentacle position
        myTentacle:InitTentacle(xTentacle, yTentacle, "monster_tentacle", 1)
        table.insert(self.lstTentacles, myTentacle)

        self.createdTentacles = self.createdTentacles + 1
    end

--------------------------------------------------------------------------------------------------------

    -- If a bullet hit the player
    function myMonster:CheckBulletWithPlayerCollision(pBullet, pPlayerObject)
        return pBullet:CheckPlayerCollision(pPlayerObject)
    end


    -- If a bullet hit the outside the screen
    function myMonster:CheckBulletWithOutsideCollision(pBullet, pPlayerObject)
        return pBullet:CheckOutboundCollision(pPlayerObject)
    end


    -- If a bullet hit the tentacle
    function myMonster:CheckBulletWithTentacleCollision(pBullet, pTentacle)
        return pBullet:CheckTentaculeCollision(pTentacle)
    end


    -- If a bullet go outside the screen, it hit the village
    function myMonster:HitVillage(pPlayerObject)
        pPlayerObject.villageLife = pPlayerObject.villageLife - 1

        -- If the village has been eradicated
        if pPlayerObject.villageLife <= 0 then
            return true
        end

        return false
    end


    -- If a bullet touch the tentacle, reduce its life
    function myMonster:HitTentacle(pTentacleObject)
        pTentacleObject.life = pTentacleObject.life - 1

        -- If the tentacle is dead
        if pTentacleObject.life <= 0 then
            return true
        end

        return false
    end

    --------------------------------------------------------------------------------------------------------


    return myMonster
end


return MONSTER