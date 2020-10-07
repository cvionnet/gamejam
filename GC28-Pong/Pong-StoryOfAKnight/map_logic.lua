local MAP = {}

local imgGround = love.graphics.newImage("images/map/tiled/map.png")

function MAP.NewMap()
    -- PROPERTIES
    local myMap = {}

    myMap.TILE_WIDTH = 64
    myMap.TILE_HEIGHT = 64

    myMap.colNumber = X_SCREENSIZE / myMap.TILE_WIDTH
    myMap.lineNumber = Y_SCREENSIZE / myMap.TILE_HEIGHT

    myMap.images = {}
    myMap.frame = 1

    -- 768 x 768
    -- 0 : player can't walk  /  1 : player can walk  /  2 : animated wall (can't walk)
    myMap.mapWalls = {}     -- map the walls of the room (12 x 12 cells of 64px each)
    myMap.mapWalls[1]  = {0,0,1,1,1,1,1,1,1,1,0,0}
    myMap.mapWalls[2]  = {2,2,0,0,0,0,0,0,0,0,2,2}
    myMap.mapWalls[3]  = {1,0,0,0,0,0,0,0,0,0,0,1}
    myMap.mapWalls[4]  = {1,0,0,0,0,0,0,0,0,0,0,1}
    myMap.mapWalls[5]  = {1,0,0,0,0,0,0,0,0,0,0,1}
    myMap.mapWalls[6]  = {1,0,0,0,0,0,0,0,0,0,0,1}
    myMap.mapWalls[7]  = {1,0,0,0,0,0,0,0,0,0,0,1}
    myMap.mapWalls[8]  = {1,0,0,0,0,0,0,0,0,0,0,1}
    myMap.mapWalls[9]  = {1,0,0,0,0,0,0,0,0,0,0,1}
    myMap.mapWalls[10] = {1,0,0,0,0,0,0,0,0,0,0,1}
    myMap.mapWalls[11] = {0,0,0,0,0,0,0,0,0,0,0,0}
    myMap.mapWalls[12] = {0,0,1,1,1,1,1,1,1,1,0,0}

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
        -- Display background PNG map
        love.graphics.draw(imgGround, 0, 0)

        -- Display tiles
        for line = 1, #self.mapWalls do
            for col = 1, #self.mapWalls[line] do
                local cell = self.mapWalls[line][col]

                if cell == 2 then       -- animated wall
                    love.graphics.draw(self.images[math.floor(self.frame)], (col-1)*self.TILE_WIDTH , (line-1)*self.TILE_WIDTH, 0, 1 * SPRITE_MAP_RATIO, 1 * SPRITE_MAP_RATIO)
                end
            end
        end

        -- DEBUG - draw cells
        if DEBUG_MODE == true then
            for line = 1, self.lineNumber do
                love.graphics.line(0, (line-1)*self.TILE_HEIGHT, X_SCREENSIZE, (line-1)*self.TILE_HEIGHT)
            end
            for col = 1, self.colNumber do
                love.graphics.line((col-1)*self.TILE_WIDTH, 0, (col-1)*self.TILE_WIDTH, Y_SCREENSIZE)
            end
        end
    end


    function myMap:update(dt)
        -- Bullet animation
        self:PlayAnimation(dt)
    end

--------------------------------------------------------------------------------------------------------

    function myMap:InitAnimation()
        self:LoadAnimation("ground_wall", 11)
    end


    function myMap:LoadAnimation(pImageName, pImageNumber)
        for i = 1, pImageNumber do
            self.images[i] = love.graphics.newImage("images/map/"..pImageName..tostring(i)..".png")
        end
    end


    function myMap:PlayAnimation(dt)
        self.frame = self.frame + FRAME_PER_SECOND_MAP * dt
        if self.frame > #self.images+1 then
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
        if self.mapWalls[pCol][pLine] == 1 then
            return true
        end

        return false
    end

--------------------------------------------------------------------------------------------------------

    -- Return the size of an image
    function myMap:GetImageH_W(pFullImagePath)
        local image = love.graphics.newImage(pFullImagePath)
        return image:getHeight(), image:getWidth()
    end

--------------------------------------------------------------------------------------------------------

    return myMap
end

return MAP