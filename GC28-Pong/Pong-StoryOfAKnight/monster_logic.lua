local MONSTER = {}

local ENEMY = require("enemy_logic")
require("param")


function MONSTER.NewMonster(pId, pMapObject)
    -- PROPERTIES
    local myMonster = {}

    myMonster.map_Object = pMapObject

    myMonster.id = pId
    myMonster.x = 0
    myMonster.y = 0
    myMonster.h = 0
    myMonster.w = 0
    myMonster.sx = 0    -- used to flip the sprite
    myMonster.sy = 0
    myMonster.rotation = 0

    myMonster.vx = 0
    myMonster.vy = 0
    myMonster.mapSidePosition = ""       -- up, down, left, right
    myMonster.status = ""                -- warning, coming, fighting, leaving, hiding

    myMonster.images = {}
    myMonster.frame = 1

    myMonster.life = 0

    myMonster.maxEnemies = MAX_ENEMY
    myMonster.createdEnemies = 0
    myMonster.lstEnemies = {}

    myMonster.timeToNewEnemy = 0
    myMonster.timeWarning = TIME_WARNING

    myMonster.lstMessageVillageHit = {}         -- to display a message when the village is hitten

--------------------------------------------------------------------------------------------------------
    -- METHODS
    function myMonster:draw()
        -- Display a warning countdown
        if self.status == "warning" then
            self:drawWarning()
        else
            -- Background of the monster
            --love.graphics.draw(self.images[math.floor(self.frame)], self.x, self.y, math.rad(self.rotation), self.sx*SPRITE_MONSTER_RATIO, self.sy*SPRITE_MONSTER_RATIO)

            -- Enemies
            for key, enemy in pairs(self.lstEnemies) do
                enemy:draw()

                -- Bullets
                for key1, bullet in pairs(enemy.lstBullet) do
                    bullet:draw()
                end
            end

            -- Message when the village is hitten
            self:drawMessageHitVillage()
        end


        -- DEBUG
        if DEBUG_MODE == true then
            love.graphics.setColor(1,0,0)
            love.graphics.circle("fill", self.x, self.y, 5)
            love.graphics.setColor(1,1,1)

            love.graphics.print("x:"..tostring(math.floor(self.x)).." / y:"..tostring(math.floor(self.y)), self.x, self.y-10)
        end
    end


    function myMonster:update(dt, pPlayerObject, pNumberOfMonsters, pOtherMonsterPosition)
        -- Display a warning where the monster will appear
        if self.status == "warning" then
            self:updateWarning(dt)
        -- Move the monster on the field
        elseif self.status == "coming" then
            self:updateComing(dt, pPlayerObject)
        -- All actions when the monster fight
        elseif self.status == "fighting" then
            self:updateFighting(dt, pPlayerObject)
        -- Move the monster out of the field
        elseif self.status == "leaving" then
            self:updateLeaving(dt, pNumberOfMonsters, pOtherMonsterPosition)
        end
    end

--------------------------------------------------------------------------------------------------------

    -- Display a warning where the monster will appear
    function myMonster:drawWarning()
        if self.mapSidePosition == "up" then
            love.graphics.print(math.floor(self.timeWarning), fontWarning, X_SCREENSIZE/2 - fontWarning:getHeight()/2, self.map_Object.TILE_HEIGHT*2)
        elseif self.mapSidePosition == "down" then
            love.graphics.print(math.floor(self.timeWarning), fontWarning, X_SCREENSIZE/2 - fontWarning:getHeight()/2, Y_SCREENSIZE - self.map_Object.TILE_HEIGHT*3)
        elseif self.mapSidePosition == "left" then
            love.graphics.print(math.floor(self.timeWarning), fontWarning, self.map_Object.TILE_WIDTH*2, Y_SCREENSIZE/2 - fontWarning:getHeight()/2)
        elseif self.mapSidePosition == "right" then
            love.graphics.print(math.floor(self.timeWarning), fontWarning, X_SCREENSIZE - self.map_Object.TILE_WIDTH*3, Y_SCREENSIZE/2 - fontWarning:getHeight()/2)
        end
    end

    -- Display a warning where the monster will appear
    function myMonster:updateWarning(dt)
        self.timeWarning = self.timeWarning - 1 * dt
        if self.timeWarning <= 0 then
            self.timeWarning = TIME_WARNING

            -- Set x / y to place the monster  +   vx / vy to move the monster on the field  +  sx / sy / position to display the monster
            self.status = "coming"
        end
    end

--------------------------------------------------------------------------------------------------------

    -- Move the monster on the field
    function myMonster:updateComing(dt)
        -- Move the monster
        self.x = self.x + self.vx * dt
        self.y = self.y + self.vy * dt

        -- Check if final position is reached, and then set the monster to fighting mode
        if self.mapSidePosition == "up" then
            if self.y >= map_Obj.TILE_HEIGHT*2 then
                self.y = map_Obj.TILE_HEIGHT*2
                self.vy = 0
                self.status = "fighting"
            end
        elseif self.mapSidePosition == "down" then
            if self.y <= Y_SCREENSIZE - map_Obj.TILE_HEIGHT*2 then
                self.y = Y_SCREENSIZE - map_Obj.TILE_HEIGHT*2
                self.vy = 0
                self.status = "fighting"
            end
        elseif self.mapSidePosition == "left" then
            if self.x >= map_Obj.TILE_WIDTH*2 then
                self.x = map_Obj.TILE_WIDTH*2
                self.vx = 0
                self.status = "fighting"
            end
        elseif self.mapSidePosition == "right" then
            if self.x <= X_SCREENSIZE - map_Obj.TILE_WIDTH*2 then
                self.x = X_SCREENSIZE - map_Obj.TILE_WIDTH*2
                self.vx = 0
                self.status = "fighting"
            end
        end
    end

--------------------------------------------------------------------------------------------------------

    function myMonster:updateFighting(dt, pPlayerObject)
        -- Enemies update
        for EnemyID = #self.lstEnemies, 1, -1 do
            local enemy = self.lstEnemies[EnemyID]

            enemy:update(dt, pPlayerObject)

            -- Bullets update and collision
            for bulletID = #enemy.lstBullet, 1, -1 do
                local bullet = enemy.lstBullet[bulletID]

                bullet:update(dt)

                -- Bullet collisions
                -- With the player
                if self:CheckBulletWithPlayerCollision(bullet, pPlayerObject) == false then
                    -- Outside the screen
                    if self:CheckBulletWithOutsideCollision(bullet, pPlayerObject) then
                        if sndGameBullet_VillageHit:isPlaying() then sndGameBullet_VillageHit:stop() end
                        sndGameBullet_VillageHit:play()

                        self:HitVillage(pPlayerObject, bullet)
                        table.remove(enemy.lstBullet, bulletID)        -- delete the bullet
                    -- With an enemy
                    elseif self:CheckBulletWithEnemyCollision(bullet, enemy) then
                        if sndGameBullet_EnemyHit:isPlaying() then sndGameBullet_EnemyHit:stop() end
                        sndGameBullet_EnemyHit:play()

                        self:HitEnemy(enemy)
                        table.remove(enemy.lstBullet, bulletID)        -- delete the bullet
                    end
                -- The bullet hit the player
                else
                    if sndGameBullet_PlayerHit:isPlaying() then sndGameBullet_PlayerHit:stop() end
                    sndGameBullet_PlayerHit:play()

                    camShake.shake = true
                    camShake.shakeTimer = CAM_SHAKE_TIMING
                end
            end

            -- If the enemies is dead, remove all its bullets and remove the enemy
            if enemy.IsToDelete then
                if sndGameEnemy_Death:isPlaying() then sndGameEnemy_Death:stop() end
                sndGameEnemy_Death:play()

                -- Hit the monster
                self.life = self.life - 1

                -- Delete bullets on the enemy
                for i = #enemy.lstBullet, 1, -1 do
                    table.remove(enemy.lstBullet, i)
                end

                table.remove(self.lstEnemies, EnemyID)
            end
        end


        -- Create a new enemy
        if self.createdEnemies < self.maxEnemies  then
            self.timeToNewEnemy = self.timeToNewEnemy - 1 * dt
            if self.timeToNewEnemy < 0 then
                self.timeToNewEnemy = math.random(TIME_MIN_CREATE_ENEMY, TIME_MAX_CREATE_ENEMY)
                self:CreateEnemy()
            end
        end


        -- If all enemies have been destroyed, move the monster to another position
        if self.createdEnemies == self.maxEnemies and #self.lstEnemies == 0 then
            if self.mapSidePosition == "up" then
                self.vy = -150
                self.status = "leaving"
            elseif self.mapSidePosition == "down" then
                self.vy = 150
                self.status = "leaving"
            elseif self.mapSidePosition == "left" then
                self.vx = -150
                self.status = "leaving"
            elseif self.mapSidePosition == "right" then
                self.vx = 150
                self.status = "leaving"
            end
        end


        -- Message when the village is hitten
        self:updateMessageHitVillage(dt)
    end

--------------------------------------------------------------------------------------------------------

    -- Move the monster out of the field
    function myMonster:updateLeaving(dt, pNumberOfMonsters, pOtherMonsterPosition)
        -- Move the monster
        self.x = self.x + self.vx * dt
        self.y = self.y + self.vy * dt

        -- Check if final position is reached and find another position
        if self.mapSidePosition == "up" then
            if self.y <= 0 then
                self.vy = 0
                self:SetSidePosition("", pNumberOfMonsters, pOtherMonsterPosition)
                self.status = "warning"
            end
        elseif self.mapSidePosition == "down" then
            if self.y >= Y_SCREENSIZE then
                self.vy = 0
                self:SetSidePosition("", pNumberOfMonsters, pOtherMonsterPosition)
                self.status = "warning"
            end
        elseif self.mapSidePosition == "left" then
            if self.x <= 0 then
                self.vx = 0
                self:SetSidePosition("", pNumberOfMonsters, pOtherMonsterPosition)
                self.status = "warning"
            end
        elseif self.mapSidePosition == "right" then
            if self.x >= X_SCREENSIZE then
                self.vx = 0
                self:SetSidePosition("", pNumberOfMonsters, pOtherMonsterPosition)
                self.status = "warning"
            end
        end
    end

--------------------------------------------------------------------------------------------------------

    -- Display a message where the bullet hit the village
    function myMonster:drawMessageHitVillage()
        for key, message in pairs(self.lstMessageVillageHit) do
            love.graphics.print(message.message, fontWarning, message.x , message.y)
        end
    end

    -- Display a message where the bullet hit the village
    function myMonster:updateMessageHitVillage(dt)
        for i = #self.lstMessageVillageHit, 1, -1 do
            local message = self.lstMessageVillageHit[i]

            -- When the time is up, delete the message from the list
            message.ttl = message.ttl - 5 * dt
            if message.ttl < 0 then
                table.remove(self.lstMessageVillageHit, i)
            end
        end
    end

--------------------------------------------------------------------------------------------------------

    function myMonster:InitMonster(pMonsterLife, pMonsterSidePosition, pNumberOfMonsters, pOtherMonsterPosition)
        self.lstEnemies = {}
        self.lstBullet = {}
        self.createdEnemies = 0

        self.status = "warning"

        self.w = self.map_Object.TILE_WIDTH * 2
        self.h = self.map_Object.TILE_HEIGHT * (#self.map_Object.mapWalls - 4)

        self.life = pMonsterLife
        self.timeToNewEnemy = math.random(TIME_MIN_CREATE_ENEMY, TIME_MAX_CREATE_ENEMY)

        self:SetSidePosition(pMonsterSidePosition, pNumberOfMonsters, pOtherMonsterPosition)
    end

--------------------------------------------------------------------------------------------------------

    -- Display an enemy on the monster
    function myMonster:CreateEnemy()

        local xEnemy, yEnemy = 0, 0
        local myEnemy = ENEMY.NewEnemy(self.map_Object)
        local imageEnemyH, imageEnemyW = self.map_Object:GetImageH_W("/images/monster/idle/knight_evil_side_idle1.png")
        imageEnemyH, imageEnemyW = imageEnemyH*SPRITE_ENEMY_RATIO, imageEnemyW*SPRITE_ENEMY_RATIO

        -- Calculate enemy position on the monster
        if self.mapSidePosition == "up" then
            xEnemy = math.random(self.x + (imageEnemyW)/2 + 10, self.x + self.h - (imageEnemyW)/2 - 10)
            yEnemy = math.random(10, imageEnemyH)
        elseif self.mapSidePosition == "down" then
            xEnemy = math.random(self.x + (imageEnemyW)/2 + 10, self.x + self.h - (imageEnemyW)/2 - 10)
            yEnemy = Y_SCREENSIZE - imageEnemyH - math.random(10, imageEnemyH)
        elseif self.mapSidePosition == "left" then
            xEnemy = math.random(10, imageEnemyW)
            yEnemy = math.random(self.y - (imageEnemyH)/2 + 10, self.y + self.h - (imageEnemyH)/2 - 10)     -- (imageH*SPRITE_ENEMY_RATIO)/2 : shoots are send from the center of the enemy
        elseif self.mapSidePosition == "right" then
            xEnemy = self.x + math.random(0, imageEnemyW)
            yEnemy = math.random(self.y - (imageEnemyH)/2 + 10, self.y + self.h - (imageEnemyH)/2 - 10)     -- (imageH*SPRITE_ENEMY_RATIO)/2 : shoots are send from the center of the enemy
        end

        -- Set enemy position
        myEnemy:InitEnemy(xEnemy, yEnemy, self.mapSidePosition)
        table.insert(self.lstEnemies, myEnemy)

        if sndGameEnemy_Appear:isPlaying() then sndGameEnemy_Appear:stop() end
        sndGameEnemy_Appear:play()

        self.createdEnemies = self.createdEnemies + 1
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


    -- If a bullet hit the enemy
    function myMonster:CheckBulletWithEnemyCollision(pBullet, pEnemy)
        return pBullet:CheckEnemyCollision(pEnemy)
    end


    -- If a bullet go outside the screen, it hit the village
    function myMonster:HitVillage(pPlayerObject, pBulletObject)
        pPlayerObject.villageLife = pPlayerObject.villageLife - 1

        -- Display a message where the bullet hit the village
        local myMessage = {}
        myMessage.message = "OUCH !"
        myMessage.ttl = TIME_DISPLAY_MESSAGE_VILLAGE

        if pBulletObject.mapSidePosition == "up" then
            myMessage.x = pBulletObject.x - fontWarning:getHeight()/2
            myMessage.y = pBulletObject.y - math.random(self.map_Object.TILE_WIDTH*2, self.map_Object.TILE_WIDTH*4)
        elseif pBulletObject.mapSidePosition == "down" then
            myMessage.x = pBulletObject.x - fontWarning:getHeight()/2
            myMessage.y = pBulletObject.y + math.random(self.map_Object.TILE_WIDTH*2, self.map_Object.TILE_WIDTH*4)
        elseif pBulletObject.mapSidePosition == "left" then
            myMessage.x = pBulletObject.x - math.random(self.map_Object.TILE_WIDTH*2, self.map_Object.TILE_WIDTH*4)
            myMessage.y = pBulletObject.y - fontWarning:getHeight()/2
        elseif pBulletObject.mapSidePosition == "right" then
            myMessage.x = pBulletObject.x + math.random(self.map_Object.TILE_WIDTH*2, self.map_Object.TILE_WIDTH*4)
            myMessage.y = pBulletObject.y - fontWarning:getHeight()/2
        end

        table.insert(self.lstMessageVillageHit, myMessage)
    end


    -- If a bullet touch the enemy, reduce its life
    function myMonster:HitEnemy(pEnemyObject)
        pEnemyObject.life = pEnemyObject.life - 1
        pEnemyObject.isHit = true
    end

--------------------------------------------------------------------------------------------------------

    -- Set monster side position
    function myMonster:SetSidePosition(pForcedPosition, pNumberOfMonsters, pOtherMonsterPosition)

        -- Get a new position if none has been passed as parameter
        if pForcedPosition == "" or pForcedPosition == nil then
            self:GetNextSidePosition(pNumberOfMonsters, pOtherMonsterPosition)
        else
            self.mapSidePosition = pForcedPosition
        end

        if self.mapSidePosition == "up" then
            self.x = map_Obj.TILE_WIDTH*2
            self.y = 0
            self.vx = 0
            self.vy = MONSTER_WALKING_SPEED

            self.sx = -1
            self.sy = 1
            self.rotation = 180
        elseif self.mapSidePosition == "down" then
            self.x = map_Obj.TILE_WIDTH*2
            self.y = Y_SCREENSIZE
            self.vx = 0
            self.vy = -MONSTER_WALKING_SPEED

            self.sx = -1
            self.sy = -1
            self.rotation = 180
        elseif self.mapSidePosition == "left" then
            self.x = 0
            self.y = map_Obj.TILE_HEIGHT*2
            self.vx = MONSTER_WALKING_SPEED
            self.vy = 0

            self.sx = 1
            self.sy = 1
            self.rotation = 90
        elseif self.mapSidePosition == "right" then
            self.x = X_SCREENSIZE
            self.y = map_Obj.TILE_HEIGHT*2
            self.vx = -MONSTER_WALKING_SPEED
            self.vy = 0

            self.sx = 1
            self.sy = -1
            self.rotation = 90
        end
    end

    -- Get the next side where the monster will appear
    function myMonster:GetNextSidePosition(pNumberOfMonsters, pOtherMonsterPosition)
        local positionID = -1

        -- Only one monster
        if pNumberOfMonsters == 1 then

            -- While a new position has not been found
            while 1 do
                -- Get a random value not equal the same as before
                positionID = math.random(1, #SIDE_POSITIONS)
                if SIDE_POSITIONS[positionID] ~= nil and SIDE_POSITIONS[positionID] ~= self.mapSidePosition then
                    break
                end
            end

            -- 2 monsters, set position aside from the oter monster (to not have monsters face to face)
        elseif pNumberOfMonsters == 2 then

            local otherMonsterPositionID = -1
            local newPositionID = -1

            -- Get the other monster position ID
            for i = 1, #SIDE_POSITIONS do
                if SIDE_POSITIONS[i] == pOtherMonsterPosition then
                    otherMonsterPositionID = i
                end
            end

            -- Get a new position (must be -1 or 1)
            while 1 do
                newPositionID = math.random(-1, 1)
                if newPositionID ~= 0 then
                    break
                end
            end

            -- Return the position +1 or -1 from the other monster
            if (newPositionID == -1 and otherMonsterPositionID == 1) then
                positionID = #SIDE_POSITIONS
            elseif (newPositionID == 1 and otherMonsterPositionID == #SIDE_POSITIONS) then
                positionID = 1
            else
                positionID = otherMonsterPositionID + newPositionID
            end
            --print(self.id, newPositionID, otherMonsterPositionID)
        end

        -- Set new position and reset enemies created counter
        self.mapSidePosition = SIDE_POSITIONS[positionID]
        self.createdEnemies = 0
        self.lstMessageVillageHit = {}
        --print(self.id, self.mapSidePosition, positionID, pNumberOfMonsters, SIDE_POSITIONS[pOtherMonsterPosition])
    end


--[[     -- Get the next side where the monster will appear
    function myMonster:GetNextSidePosition_MultipleMonsters()
        local actualpositionID = -1
        local newPositionID = -1

        -- Get the actual position ID
        for i = 1, #SIDE_POSITIONS do
            if SIDE_POSITIONS[i] == self.mapSidePosition then
                actualpositionID = i
            end
        end

        -- Get a new position (must be -1 or 1)
        while 1 do
            newPositionID = math.random(-1, 1)
            if newPositionID ~= 0 then
                break
            end
        end

        -- Return the position +1 or -1 from current monster
        if (newPositionID == -1 and actualpositionID == 1) then
            return SIDE_POSITIONS[#SIDE_POSITIONS]
        elseif (newPositionID == 1 and actualpositionID == #SIDE_POSITIONS) then
            return SIDE_POSITIONS[1]
        else
            return SIDE_POSITIONS[actualpositionID + newPositionID]
        end
    end ]]

--------------------------------------------------------------------------------------------------------

    return myMonster
end


return MONSTER