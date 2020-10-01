local PLAYER = {}

local FRAME_PER_SECOND = 24
local GRAVITY = .9
local STOP_PLAYER = .5  --.01
local PLAYER_FEET_HEIGHT = 6


function PLAYER.NewPlayer(pMapObject, pXScreenSize, pYScreenSize)
    -- PROPERTIES
    local myPlayer = {}

    myPlayer.map_Object = pMapObject

    myPlayer.x = 0
    myPlayer.y = 0
    myPlayer.h = 0
    myPlayer.w = 0
    myPlayer.col = 0
    myPlayer.line = 0

    myPlayer.xScreenSize = pXScreenSize
    myPlayer.yScreenSize = pYScreenSize

    myPlayer.vx = 0
    myPlayer.vy = 0
    myPlayer.vmax = 10
    myPlayer.movingDirection = ""       -- up, down, left, right
    myPlayer.mapSidePosition = ""       -- up, down, left, right

    myPlayer.images = {}
    myPlayer.frame = 1

    myPlayer.life = 0
    myPlayer.villageLife = 0
    myPlayer.bulletTime = 0
    myPlayer.shieldColor = nil

--------------------------------------------------------------------------------------------------------
    -- METHODS
    function myPlayer:draw(DEBUG_MODE)

        love.graphics.draw(self.images[math.floor(self.frame)], self.x, self.y)  --, 0, self.flip, 1) --, self.w/2, self.h-6) -- player.h/2)

        -- DEBUG - draw player box
        if DEBUG_MODE == true then
            love.graphics.setColor(1,0,0)
            love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
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
        self.x = self.x + self.vx
        self.y = self.y + self.vy

        -- Player animation
        self:PlayAnimation(dt)

        -- Movements
        self:CheckInputs(dt)

        -- Collisions
        self:CheckWallCollision(oldX, oldY)
    end

--------------------------------------------------------------------------------------------------------

    function myPlayer:InitPlayer(pX, pY, pAnimationFile, pAnimationNumberFrames)
        self.x = pX
        self.y = pY
        self.mapSidePosition = "left"

        self:LoadAnimation(pAnimationFile, pAnimationNumberFrames)
    end


    function myPlayer:LoadAnimation(pImageName, pImageNumber)
        for i = 1, pImageNumber do
            self.images[i] = love.graphics.newImage("images/player/"..pImageName..tostring(i)..".png")
        end

        self.w = self.images[1]:getWidth()
        self.h = self.images[1]:getHeight()
    end


    function myPlayer:PlayAnimation(dt)
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
        elseif self.map_Object.mapWalls[self.line][self.col] > 0 then
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
        self.vx = self.vx * GRAVITY
        self.vy = self.vy * GRAVITY
        if math.abs(self.vx) < STOP_PLAYER then self.vx = 0 end
        if math.abs(self.vy) < STOP_PLAYER then self.vy = 0 end
    end


    -- Change player side position
    function myPlayer:SwitchSidePosition(key)
        if key == "z" then
            -- If previous position was down, keep the same x ; else set position at the middle of the screen
            if self.mapSidePosition == "down" then
                self:ResetPosition_Velocity(self.x, 0)
            else
                self:ResetPosition_Velocity(self.xScreenSize/2, 0)
            end
            self.mapSidePosition = "up"
        end
        if key == "s" then
            -- If previous position was up, keep the same x ; else set position at the middle of the screen
            if self.mapSidePosition == "up" then
                self:ResetPosition_Velocity(self.x, self.yScreenSize - self.map_Object.TILE_HEIGHT)
            else
                self:ResetPosition_Velocity(self.xScreenSize/2, self.yScreenSize - self.map_Object.TILE_HEIGHT)
            end
            self.mapSidePosition = "down"
        end
        if key == "q" then
            -- If previous position was right, keep the same y ; else set position at the middle of the screen
            if self.mapSidePosition == "right" then
                self:ResetPosition_Velocity(0, self.y)
            else
                self:ResetPosition_Velocity(0, self.yScreenSize/2)
            end

            self.mapSidePosition = "left"
        end
        if key == "d" then
            -- If previous position was left, keep the same y ; else set position at the middle of the screen
            if self.mapSidePosition == "left" then
                self:ResetPosition_Velocity(self.xScreenSize - self.map_Object.TILE_WIDTH, self.y)
            else
                self:ResetPosition_Velocity(self.xScreenSize - self.map_Object.TILE_WIDTH, self.yScreenSize/2)
            end

            self.mapSidePosition = "right"
        end
    end


    -- Check keyboard inputs
    function myPlayer:CheckInputs(dt)
        -- Player can move UP and DOWN where he is on the left and right sides
        if self.mapSidePosition == "left" or self.mapSidePosition == "right" then
            if love.keyboard.isDown("up") then
                if math.abs(self.vy) <= self.vmax then
                    self.vy = self.vy - 1
                    self.movingDirection = "up"
                end
            end
            if love.keyboard.isDown("down") then
                if math.abs(self.vy) <= self.vmax then
                    self.vy = self.vy + 1
                    self.movingDirection = "down"
                end
            end
        end

        -- Player can move LEFT and RIGHT where he is on the up and down sides
        if self.mapSidePosition == "up" or self.mapSidePosition == "down" then
            if love.keyboard.isDown("left") then
                if math.abs(self.vx) <= self.vmax then
                    self.vx = self.vx - 1
                    self.movingDirection = "left"
                end
            end
            if love.keyboard.isDown("right") then
                if math.abs(self.vx) <= self.vmax then
                    self.vx = self.vx + 1
                    self.movingDirection = "right"
                end
            end
        end
    end

--------------------------------------------------------------------------------------------------------

    return myPlayer
end


return PLAYER