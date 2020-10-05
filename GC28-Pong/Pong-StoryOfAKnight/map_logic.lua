local MAP = {}

local imgGround = love.graphics.newImage("images/map/ground1.png")
local imgGround2 = love.graphics.newImage("images/map/ground2.png")
local imgGround3 = love.graphics.newImage("images/map/ground3.png")

local imgGround_top = love.graphics.newImage("images/map/ground_top.png")
local imgGround_top_border = love.graphics.newImage("images/map/ground_top_border.png")
local imgGround_top_border_corner = love.graphics.newImage("images/map/ground_top_border_corner.png")


function MAP.NewMap(pXScreenSize, pYScreenSize)
    -- PROPERTIES
    local myMap = {}
    local imgGround_size = imgGround_top:getWidth()*SPRITE_MAP_RATIO

    myMap.TILE_WIDTH = 64
    myMap.TILE_HEIGHT = 64

    myMap.colNumber = pXScreenSize / myMap.TILE_WIDTH
    myMap.lineNumber = pYScreenSize / myMap.TILE_HEIGHT

    myMap.images = {}
    myMap.frame = 1

    -- 768 x 768
    myMap.mapWalls = {}     -- map the walls of the room (12 x 12 cells of 64px each)
    myMap.mapWalls[1]  = { 2,  9,  0,  1,  1, "C","C",  1,  1,  1, "A", 2}
    myMap.mapWalls[2]  = {"B","B", 1,  1,  0, "C","C",  1,  1,  1, "B","B"}
    myMap.mapWalls[3]  = { 1,  1,  1,  0,  0, "C","C",  1,  1,  1,  1,  1}
    myMap.mapWalls[4]  = { 1,  1,  0,  0,  0, "C","C",  0,  1,  1,  1,  0}
    myMap.mapWalls[5]  = { 1,  1,  0,  0,  0, "C","C",  0,  0,  0,  0,  0}
    myMap.mapWalls[6]  = {"C","C","C","C","C","C","C","C","C","C","C","C"}
    myMap.mapWalls[7]  = {"C","C","C","C","C","C","C","C","C","C","C","C"}
    myMap.mapWalls[8]  = { 1,  0,  0,  0,  0, "C","C",  0,  0,  0,  0,  0}
    myMap.mapWalls[9]  = { 1,  1,  1,  1,  0, "C","C",  0,  0,  1,  1,  1}
    myMap.mapWalls[10] = { 1,  1,  0,  1,  0, "C","C",  0,  1,  1,  1,  1}
    myMap.mapWalls[11] = { 6,  4,  1,  1,  0, "C","C",  0,  1,  1,  3,  5}
    myMap.mapWalls[12] = { 2,  8,  1,  1,  0, "C","C",  1,  1,  1,  7,  2}

    local lstNonWalking = {2,3,4,5,6,7,8,9,"A","B"}

    -- 768 x 768     (32 x 32)
--[[     
    myMap.mapWalls = {}     -- map the walls of the room (12 x 12 cells of 64px each)
    myMap.mapWalls[1]  = {1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1}
    myMap.mapWalls[2]  = {1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1}
    myMap.mapWalls[3]  = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    myMap.mapWalls[4]  = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    myMap.mapWalls[5]  = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    myMap.mapWalls[6]  = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    myMap.mapWalls[7]  = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    myMap.mapWalls[8]  = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    myMap.mapWalls[9]  = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    myMap.mapWalls[10] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    myMap.mapWalls[11] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    myMap.mapWalls[12] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    myMap.mapWalls[13] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    myMap.mapWalls[14] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    myMap.mapWalls[15] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    myMap.mapWalls[16] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    myMap.mapWalls[17] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    myMap.mapWalls[18] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    myMap.mapWalls[19] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    myMap.mapWalls[20] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    myMap.mapWalls[21] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    myMap.mapWalls[22] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    myMap.mapWalls[23] = {1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1}
    myMap.mapWalls[24] = {1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1}
 ]]

    -- 1024 x 768
--[[     myMap.mapWalls = {}     -- map the walls of the room (12 x 16 cells of 64px each)
    myMap.mapWalls[1]  = {1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1}
    myMap.mapWalls[2]  = {1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1}
    myMap.mapWalls[3]  = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    myMap.mapWalls[4]  = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    myMap.mapWalls[5]  = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    myMap.mapWalls[6]  = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    myMap.mapWalls[7]  = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    myMap.mapWalls[8]  = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    myMap.mapWalls[9]  = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    myMap.mapWalls[10] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    myMap.mapWalls[11] = {1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1}
    myMap.mapWalls[12] = {1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1}
 ]]

 --------------------------------------------------------------------------------------------------------
    -- METHODS
    function myMap:draw(DEBUG_MODE)
        -- Display tiles
        for line = 1, #self.mapWalls do
            for col = 1, #self.mapWalls[line] do
                local cell = self.mapWalls[line][col]

                if cell == 0 then
                    love.graphics.draw(imgGround2, (col-1)*self.TILE_WIDTH, (line-1)*self.TILE_WIDTH, 0, 1 * SPRITE_MAP_RATIO, 1 * SPRITE_MAP_RATIO)

                elseif cell == 1 then
                    love.graphics.draw(imgGround, (col-1)*self.TILE_WIDTH, (line-1)*self.TILE_WIDTH, 0, 1 * SPRITE_MAP_RATIO, 1 * SPRITE_MAP_RATIO)
                elseif cell == "C" then
                    love.graphics.draw(imgGround3, (col-1)*self.TILE_WIDTH, (line-1)*self.TILE_WIDTH, 0, 1 * SPRITE_MAP_RATIO, 1 * SPRITE_MAP_RATIO)

                elseif cell == 2 then
                    love.graphics.draw(imgGround_top, (col-1)*self.TILE_WIDTH, (line-1)*self.TILE_WIDTH, 0, 1 * SPRITE_MAP_RATIO, 1 * SPRITE_MAP_RATIO)

                elseif cell == 3 then
                    love.graphics.draw(imgGround_top_border_corner, (col-1)*self.TILE_WIDTH, (line-1)*self.TILE_WIDTH, 0, 1 * SPRITE_MAP_RATIO, 1 * SPRITE_MAP_RATIO)
                elseif cell == 4 then
                    love.graphics.draw(imgGround_top_border_corner, (col-1)*self.TILE_WIDTH + imgGround_size, (line-1)*self.TILE_WIDTH, 0, -1 * SPRITE_MAP_RATIO, 1 * SPRITE_MAP_RATIO)

                elseif cell == 5 then
                    love.graphics.draw(imgGround_top_border, (col-1)*self.TILE_WIDTH, (line-1)*self.TILE_WIDTH, 0, 1 * SPRITE_MAP_RATIO, 1 * SPRITE_MAP_RATIO)
                elseif cell == 6 then
                    love.graphics.draw(imgGround_top_border, (col-1)*self.TILE_WIDTH + imgGround_size, (line-1)*self.TILE_WIDTH, 0, -1 * SPRITE_MAP_RATIO, 1 * SPRITE_MAP_RATIO)

                elseif cell == 7 then
                    love.graphics.draw(imgGround_top_border, (col-1)*self.TILE_WIDTH, (line-1)*self.TILE_WIDTH + imgGround_size, math.rad(-90), 1 * SPRITE_MAP_RATIO, 1 * SPRITE_MAP_RATIO)
                elseif cell == 8 then
                    love.graphics.draw(imgGround_top_border, (col-1)*self.TILE_WIDTH + imgGround_size, (line-1)*self.TILE_WIDTH + imgGround_size, math.rad(90), -1 * SPRITE_MAP_RATIO, 1 * SPRITE_MAP_RATIO)

                elseif cell == 9 then
                    love.graphics.draw(imgGround_top_border, (col-1)*self.TILE_WIDTH + imgGround_size, (line-1)*self.TILE_WIDTH + imgGround_size, math.rad(-90), 1 * SPRITE_MAP_RATIO, -1 * SPRITE_MAP_RATIO)
                elseif cell == "A" then
                    love.graphics.draw(imgGround_top_border, (col-1)*self.TILE_WIDTH , (line-1)*self.TILE_WIDTH + imgGround_size, math.rad(90), -1 * SPRITE_MAP_RATIO, -1 * SPRITE_MAP_RATIO)

                elseif cell == "B" then
                    self:LoadAnimation("ground_wall", 11)
                    love.graphics.draw(self.images[math.floor(self.frame)], (col-1)*self.TILE_WIDTH , (line-1)*self.TILE_WIDTH, 0, 1 * SPRITE_MAP_RATIO, 1 * SPRITE_MAP_RATIO)
                end
            end
        end

        -- DEBUG - draw cells
        if DEBUG_MODE == true then
            for line = 1, self.lineNumber do
                love.graphics.line(0, (line-1)*self.TILE_HEIGHT, xScreenSize, (line-1)*self.TILE_HEIGHT)
            end
            for col = 1, self.colNumber do
                love.graphics.line((col-1)*self.TILE_WIDTH, 0, (col-1)*self.TILE_WIDTH, yScreenSize)
            end
        end
    end


    function myMap:update(dt)
        -- Bullet animation
        self:PlayAnimation(dt)
    end

--------------------------------------------------------------------------------------------------------

    function myMap:LoadAnimation(pImageName, pImageNumber)
        for i = 1, pImageNumber do
            self.images[i] = love.graphics.newImage("images/map/"..pImageName..tostring(i)..".png")
        end
    end


    function myMap:PlayAnimation(dt)
        self.frame = self.frame + FRAME_PER_SECOND_MAP * dt
        if self.frame > #self.images then
            self.frame = 1
        end
    end

--------------------------------------------------------------------------------------------------------

    -- Return the col and line on the map, from x and y coordinates
    function myMap:GetCellCol_Line(pX, pY)
        local col = 0
        local line = 0

        col = math.floor((pX / self.TILE_WIDTH)) + 1
        line = math.floor((pY / self.TILE_HEIGHT)) + 1

        return col, line
    end

    -- Return the x and y coordinates on the map, from col and line
    function myMap:GetCellX_Y(pCol, pLine)
        local x = 0
        local y = 0

        x = pCol * self.TILE_WIDTH
        y = pLine * self.TILE_HEIGHT

        return x, y
    end


    -- Return if the player can walk on the tile
    function myMap:PlayerCanWalkOnTile(pCol, pLine)
        for i = 1, #lstNonWalking do
            if self.mapWalls[pCol][pLine] == lstNonWalking[i] then
                return false
            end
        end

        return true
    end

--------------------------------------------------------------------------------------------------------

    return myMap
end

return MAP