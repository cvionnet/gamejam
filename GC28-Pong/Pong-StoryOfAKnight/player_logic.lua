local PLAYER = {}

require("param")


function PLAYER.NewPlayer(pMapObject, pVillageLife, pPlayerLife)
    -- PROPERTIES
    local myPlayer = {}

    myPlayer.map_Object = pMapObject

    myPlayer.x = 0
    myPlayer.y = 0
    myPlayer.h = 0
    myPlayer.w = 0
    myPlayer.col = 0
    myPlayer.line = 0

    myPlayer.vx = 0
    myPlayer.vy = 0
    myPlayer.vmax = 10
    myPlayer.movingDirection = ""       -- up, down, left, right
    myPlayer.mapSidePosition = ""       -- up, down, left, right

    myPlayer.previousPosition = {}      -- to save coordinates from previous side positions (1 = left, 2 = up, 3 = right, 4 down)
    myPlayer.previousPosition.x = 0
    myPlayer.previousPosition.y = 0

    myPlayer.frame = 1
    myPlayer.currentAnimation = ""
    myPlayer.lstAnimations = {}                         -- stock all images of an animation ("run1", "run2"...), indexed by a name (eg :  lstAnimations["run"])
    myPlayer.lstAnimationsImages = {}                   -- stock all images (Love2d object) used in all animations, indexed by mage name (eg : "run1", "run2"...)

    myPlayer.life = pPlayerLife
    myPlayer.isHit = false
    myPlayer.villageLife = pVillageLife

    --myPlayer.bulletTime = 0
    myPlayer.shieldColor = nil

--------------------------------------------------------------------------------------------------------
    -- METHODS
    function myPlayer:draw()

        self:drawAnimation()
        --love.graphics.print("Villageois : "..tostring(self.villageLife), 10, 30)

        -- DEBUG - draw player box
        if DEBUG_MODE == true then
            --love.graphics.setColor(1,0,0)
            --love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
            --love.graphics.setColor(1,1,1)

            love.graphics.setColor(1,0,0)
            love.graphics.circle("fill", self.x, self.y, 5)
            love.graphics.setColor(1,1,1)

            --love.graphics.print("Col:"..tostring(self.col).." / Line:"..tostring(self.line), self.x, self.y-10)
            love.graphics.print("x:"..tostring(math.floor(self.x)).." / y:"..tostring(math.floor(self.y)), self.x, self.y-10)
        end
    end


    function myPlayer:update(dt)
        -- Save last player position BEFORE moving. If it collides with a wall, we reset it's position (to avoid it to be stuck in the wall)
        local oldX = self.x
        local oldY = self.y

        self:PlayerFriction()

        -- Move the sprite and apply velocity
        self.x = self.x + self.vx * PLAYER_SPEED * dt
        self.y = self.y + self.vy * PLAYER_SPEED * dt

        -- Player animation
        --self:PlayAnimation(dt)
        self:updateAnimation(dt)

        -- Movements
        self:CheckInputs(dt)

        -- Collisions
        self:CheckWallCollision(oldX, oldY)
    end

--------------------------------------------------------------------------------------------------------

    function myPlayer:InitPlayer(pX, pY)
        self.x = pX
        self.y = pY
        self.mapSidePosition = "left"

        self:AddNewAnimation("idle", "images/player/idle", { "knight_hero_side_idle1", "knight_hero_side_idle2", "knight_hero_side_idle3" })
        self:AddNewAnimation("run", "images/player/run", { "knight_hero_side_defend1", "knight_hero_side_defend2", "knight_hero_side_defend3", "knight_hero_side_defend4" })
        self:AddNewAnimation("protect", "images/player/protect", { "knight_hero_side_protect1", "knight_hero_side_protect2" })
        self:PlayAnimation("protect")

        -- Initialize 4 lists (1 = left, 2 = up, 3 = right, 4 down) to store previous positions
        self.previousPosition[1] = {}
        self.previousPosition[2] = {}
        self.previousPosition[3] = {}
        self.previousPosition[4] = {}

        -- When player change side, save its coordinates. If he moves back, keep the same position
        self:savePlayerPosition()
    end


    -- When player change side, keep last position. If he moves back, set the same coordinates
    function myPlayer:savePlayerPosition()
        if self.mapSidePosition == "up" then
            self.previousPosition[2].x = self.x
            self.previousPosition[2].y = self.y
        elseif self.mapSidePosition == "down" then
            self.previousPosition[4].x = self.x
            self.previousPosition[4].y = self.y
        elseif self.mapSidePosition == "left" then
            self.previousPosition[1].x = self.x
            self.previousPosition[1].y = self.y
        elseif self.mapSidePosition == "right" then
            self.previousPosition[3].x = self.x
            self.previousPosition[3].y = self.y
        end
    end

--------------------------------------------------------------------------------------------------------

    -- Create a new animation
    function myPlayer:AddNewAnimation(pName, pFolder, pListImages)
        self:AddAnimationImages(pFolder, pListImages)
        self.lstAnimations[pName] = pListImages
    end


    -- Load images used for an animation (from a folder)
    function myPlayer:AddAnimationImages(pFolder, pListImages)
        for key, image in pairs(pListImages) do
            local fileName = pFolder.."/"..image..".png"
            self.lstAnimationsImages[image] = love.graphics.newImage(fileName)
        end

        self.w = self.lstAnimationsImages["knight_hero_side_idle1"]:getWidth() * SPRITE_PLAYER_RATIO
        self.h = self.lstAnimationsImages["knight_hero_side_idle1"]:getHeight() * SPRITE_PLAYER_RATIO
    end


    -- Prepare the animation before being played
    function myPlayer:PlayAnimation(pName)
        if self.currentAnimation ~= pName then
            self.currentAnimation = pName
            self.frame = 1
        end
    end


    function myPlayer:drawAnimation()
        local imgName = self.lstAnimations[self.currentAnimation][math.floor(self.frame)]    -- get image name for the current animation and the current fame  (eg : for "run" and frame=1, get "run1")
        local img = self.lstAnimationsImages[imgName]       -- get Love2d image object from the name of the image

        --print(img, self.x, self.y, SPRITE_PLAYER_RATIO)
        if img ~= nil then
            if self.isHit then
                love.graphics.setShader(shaderBlink)
                shaderBlink:send("WhiteFactor", 1)

                love.graphics.draw(img, self.x, self.y, 0, 1 * SPRITE_PLAYER_RATIO, 1 * SPRITE_PLAYER_RATIO)

                love.graphics.setShader()
                self.isHit = false
            else
                love.graphics.draw(img, self.x, self.y, 0, 1 * SPRITE_PLAYER_RATIO, 1 * SPRITE_PLAYER_RATIO)
            end
        end
    end


    function myPlayer:updateAnimation(dt)
        if self.currentAnimation ~= "" then
            if self.currentAnimation == "run" then
                self.frame = self.frame + FRAME_PER_SECOND_PLAYER_RUN * dt

                -- If the player stop
                if math.abs(self.vx) < 1 and math.abs(self.vy) < 1 then
                    self:PlayAnimation("protect")
                end
            elseif self.currentAnimation == "idle" or self.currentAnimation == "protect" then
                self.frame = self.frame + FRAME_PER_SECOND_PLAYER_IDLE * dt
            end

            -- Reset timer
            if self.frame > #self.lstAnimations[self.currentAnimation]+1 then
                self.frame = 1
            end
        end
    end

--------------------------------------------------------------------------------------------------------

    -- Check wall collision
    function myPlayer:CheckWallCollision(pX, pY)
        local stopPlayer = false

        -- Get player col and line
        if self.movingDirection == "up" or self.movingDirection == "down" then
            self.col, self.line = self.map_Object:GetCellCol_Line(self.x, self.y + (self.h-PLAYER_FEET_HEIGHT))
        elseif self.movingDirection == "left" then
            self.col, self.line = self.map_Object:GetCellCol_Line(self.x, self.y)
        elseif self.movingDirection == "right" then
            self.col, self.line = self.map_Object:GetCellCol_Line(self.x + self.w, self.y)
        end


        -- Check if player is out of the map bound
        if (self.col <= 0 or self.line <= 0) or (self.col > self.map_Object.colNumber or self.line > self.map_Object.lineNumber) then
            stopPlayer = true
        -- If the ID is not 0, the player can't walk on it
        elseif self.map_Object:PlayerCanWalkOnTile(self.col, self.line) == false then  -- self.map_Object.mapWalls[self.line][self.col] > 0 then
            stopPlayer = true
        end

        if stopPlayer then
            self:ResetPosition_Velocity(pX, pY)
        end
    end


    function myPlayer:ResetPosition_Velocity(pX, pY)
        self.x = pX
        self.y = pY
        self.vx = 0
        self.vy = 0
    end

--------------------------------------------------------------------------------------------------------

    function myPlayer:PlayerFriction()
        -- Reduce velocity (=friction)  - 10% each time
        self.vx = self.vx * PARTICLE_GRAVITY
        self.vy = self.vy * PARTICLE_GRAVITY
        if math.abs(self.vx) < STOP_PLAYER then self.vx = 0 end
        if math.abs(self.vy) < STOP_PLAYER then self.vy = 0 end
    end


    -- Change player side position
    function myPlayer:SwitchSidePosition(key)
        -- When player change side, save its coordinates. If he moves back, keep the same position
        self:savePlayerPosition()

        if key == "z" or key == "w" then
            -- If previous position was saved, set previous coordinates ; else set position at the middle of the screen
            if self.previousPosition[2].x ~= nil then
                --self:ResetPosition_Velocity(self.x, 0)
                self:ResetPosition_Velocity(self.previousPosition[2].x, self.previousPosition[2].y)
            else
                self:ResetPosition_Velocity(X_SCREENSIZE/2, 0)
            end
            self.mapSidePosition = "up"
        end
        if key == "s" then
            -- If previous position was saved, set previous coordinates ; else set position at the middle of the screen
            if self.previousPosition[4].x ~= nil then
                --self:ResetPosition_Velocity(self.x, Y_SCREENSIZE - self.map_Object.TILE_HEIGHT)
                self:ResetPosition_Velocity(self.previousPosition[4].x, self.previousPosition[4].y)
            else
                self:ResetPosition_Velocity(X_SCREENSIZE/2, Y_SCREENSIZE - self.map_Object.TILE_HEIGHT)
            end
            self.mapSidePosition = "down"
        end
        if key == "q" or key == "a" then
            -- If previous position was saved, set previous coordinates ; else set position at the middle of the screen
            if self.previousPosition[1].x ~= nil then
                --self:ResetPosition_Velocity(0, self.y)
                self:ResetPosition_Velocity(self.previousPosition[1].x, self.previousPosition[1].y)
            else
                self:ResetPosition_Velocity(0, Y_SCREENSIZE/2)
            end

            self.mapSidePosition = "left"
        end
        if key == "d" then
            -- If previous position was saved, set previous coordinates ; else set position at the middle of the screen
            if self.previousPosition[3].x ~= nil then
                self:ResetPosition_Velocity(X_SCREENSIZE - self.map_Object.TILE_WIDTH, self.y)
                self:ResetPosition_Velocity(self.previousPosition[3].x, self.previousPosition[3].y)
            else
                self:ResetPosition_Velocity(X_SCREENSIZE - self.map_Object.TILE_WIDTH, Y_SCREENSIZE/2)
            end

            self.mapSidePosition = "right"
        end
    end


    -- Check keyboard inputs
    function myPlayer:CheckInputs(dt)
        local stopWalkSound = true

        -- Player can move UP and DOWN where he is on the left and right sides
        if self.mapSidePosition == "left" or self.mapSidePosition == "right" then
            if love.keyboard.isDown("up") then
                if math.abs(self.vy) <= self.vmax then
                    self.vy = self.vy - 1
                    self.movingDirection = "up"

                    self:PlayAnimation("run")
                    stopWalkSound = false
                end
            end
            if love.keyboard.isDown("down") then
                if math.abs(self.vy) <= self.vmax then
                    self.vy = self.vy + 1
                    self.movingDirection = "down"

                    self:PlayAnimation("run")
                    stopWalkSound = false
                end
            end
        end

        -- Player can move LEFT and RIGHT where he is on the up and down sides
        if self.mapSidePosition == "up" or self.mapSidePosition == "down" then
            if love.keyboard.isDown("left") then
                if math.abs(self.vx) <= self.vmax then
                    self.vx = self.vx - 1
                    self.movingDirection = "left"

                    self:PlayAnimation("run")
                    stopWalkSound = false
                end
            end
            if love.keyboard.isDown("right") then
                if math.abs(self.vx) <= self.vmax then
                    self.vx = self.vx + 1
                    self.movingDirection = "right"

                    self:PlayAnimation("run")
                    stopWalkSound = false
                end
            end
        end

        if stopWalkSound then
            -- Stop step sounds
            if sndGamePlayer_Walk:isPlaying() then
                sndGamePlayer_Walk:stop()
            end
        else
            -- Play step sounds
            if sndGamePlayer_Walk:isPlaying() == false then
                sndGamePlayer_Walk:setLooping(true)
                sndGamePlayer_Walk:play()
            end
        end
    end

--------------------------------------------------------------------------------------------------------

    return myPlayer
end


return PLAYER