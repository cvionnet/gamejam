local MAP = {}

local imgGround = love.graphics.newImage("images/mapTile_087.png")
local imgGround2 = love.graphics.newImage("images/mapTile_082.png")

function MAP.NewMap(pXScreenSize, pYScreenSize)
    -- PROPERTIES
    local myMap = {}

    myMap.TILE_WIDTH = 64
    myMap.TILE_HEIGHT = 64

    myMap.colNumber = pXScreenSize / myMap.TILE_WIDTH
    myMap.lineNumber = pYScreenSize / myMap.TILE_HEIGHT

    myMap.mapWalls = {}     -- map the walls of the room (12 x 16 cells of 64px each)
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

--------------------------------------------------------------------------------------------------------
    -- METHODS
    function myMap:draw(DEBUG_MODE)
        -- Display tiles
        for line = 1, #self.mapWalls do
            for col = 1, #self.mapWalls[line] do
                local cell = self.mapWalls[line][col]
                if cell == 1 then
                    love.graphics.draw(imgGround2, (col-1)*self.TILE_WIDTH, (line-1)*self.TILE_WIDTH)
                else
                    love.graphics.draw(imgGround, (col-1)*self.TILE_WIDTH, (line-1)*self.TILE_WIDTH)
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

--------------------------------------------------------------------------------------------------------

    -- Return the col and line on the map, from x and y coordinates
    function myMap:GetCellCol_Line(pX, pY)
        local col = 0
        local line = 0

        col = math.floor((pX / self.TILE_WIDTH)) + 1
        line = math.floor((pY / self.TILE_HEIGHT)) + 1

        return col, line
    end




    return myMap
end

return MAP