local MONSTER = {}

local TENTACLE = require("tentacle_logic")

local FRAME_PER_SECOND = 24
local TIME_MIN_CREATE_TENTACLE = 10
local TIME_MAX_CREATE_TENTACLE = 20


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

    myMonster.timeToNewTentacle = 0
    myMonster.maxTentacles = 10
    myMonster.createdTentacles = 0
    myMonster.lstTentacles = {}

--------------------------------------------------------------------------------------------------------
    -- METHODS
    function myMonster:draw(DEBUG_MODE)

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


    function myMonster:update(dt, pPlayerObject)
        -- Monster animation
        self:PlayAnimation(dt)

        -- Tentacles update
        for tentacleID = #self.lstTentacles, 1, -1 do
            local isTentacleToDelete = false
            local isVillageEradicated = false
            local tentacle = self.lstTentacles[tentacleID]

            tentacle:update(dt)

            -- Bullets update and collision
            for bulletID = #tentacle.lstBullet, 1, -1 do
                local bullet = tentacle.lstBullet[bulletID]

                bullet:update(dt)

                -- Bullet collisions
                if self:CheckBulletWithPlayerCollision(bullet, pPlayerObject) == false then     -- with the player
                    if self:CheckBulletWithOutsideCollision(bullet, pPlayerObject) then         -- outside the screen
                        isVillageEradicated = self:HitVillage(pPlayerObject)

                        if isVillageEradicated then
                        
                        else
                            table.remove(tentacle.lstBullet, bulletID)        -- delete the bullet
                        end

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
            self.timeToNewTentacle = self.timeToNewTentacle - 0.1
            if self.timeToNewTentacle < 0 then
                self.timeToNewTentacle = math.random(TIME_MIN_CREATE_TENTACLE, TIME_MAX_CREATE_TENTACLE)
                self:CreateTentacle()
            end
        end

        -- If all tentacles have been destroyed, move the monster
        if self.createdTentacles == self.maxTentacles and #self.lstTentacles == 0 then
            print("MOVE !")
        else
            print(#self.lstTentacles, self.createdTentacles)
        end
    end

--------------------------------------------------------------------------------------------------------

    function myMonster:InitMonster(pX, pY, pAnimationFile, pAnimationNumberFrames, pMonsterLife)
        self.lstTentacles = {}
        self.lstBullet = {}
        self.createdTentacles = 0

        self.x = pX
        self.y = pY
        self.sx = 1
        self.sy = -1
        self.rotation = 90
        self.mapSidePosition = "right"

        self.life = pMonsterLife
        self.timeToNewTentacle = math.random(TIME_MIN_CREATE_TENTACLE, TIME_MAX_CREATE_TENTACLE)

        self:LoadAnimation(pAnimationFile, pAnimationNumberFrames)

        self:CreateTentacle()
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