local TENTACLE = {}

local FRAME_PER_SECOND = 24


function TENTACLE.NewTentacle(pMapObject, pXScreenSize, pYScreenSize)
    -- PROPERTIES
    local myTentacle = {}

    myTentacle.map_Object = pMapObject

    myTentacle.x = 0
    myTentacle.y = 0
    myTentacle.h = 0
    myTentacle.w = 0
    myTentacle.sx = 0    -- used to flip the sprite
    myTentacle.sy = 0
    myTentacle.rotation = 0

    myTentacle.xScreenSize = pXScreenSize
    myTentacle.yScreenSize = pYScreenSize

    myTentacle.vx = 0
    myTentacle.vy = 0
    myTentacle.mapSidePosition = ""       -- up, down, left, right

    myTentacle.images = {}
    myTentacle.frame = 1

    myTentacle.life = 0
    myTentacle.speedShoot = 0

    myTentacle.lstBullet = {}

--------------------------------------------------------------------------------------------------------
    -- METHODS
    function myTentacle:draw(DEBUG_MODE)

        love.graphics.draw(self.images[math.floor(self.frame)], self.x, self.y, math.rad(self.rotation), self.sx, self.sy)  --, self.flip, 1) --, self.w/2, self.h-6) -- player.h/2)

        -- DEBUG - draw player box
        if DEBUG_MODE == true then
            love.graphics.setColor(1,0,0)
            love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
            love.graphics.setColor(1,1,1)
        end
    end


    function myTentacle:update(dt)
        -- Monster animation
        self:PlayAnimation(dt)

        -- Collisions
        --self:CheckWallCollision(oldX, oldY)
    end

--------------------------------------------------------------------------------------------------------

    function myTentacle:InitTentacle(pX, pY, pAnimationFile, pAnimationNumberFrames)
        self.x = pX
        self.y = pY
        self.sx = 1
        self.sy = -1
        self.rotation = 90
        self.mapSidePosition = "right"

        self:LoadAnimation(pAnimationFile, pAnimationNumberFrames)
    end


    function myTentacle:LoadAnimation(pImageName, pImageNumber)
        for i = 1, pImageNumber do
            self.images[i] = love.graphics.newImage("images/monster/"..pImageName..tostring(i)..".png")
        end

        self.w = self.images[1]:getWidth()
        self.h = self.images[1]:getHeight()
    end


    function myTentacle:PlayAnimation(dt)
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
    function myTentacle:SwitchSidePosition(key)

    end

--------------------------------------------------------------------------------------------------------

    return myTentacle
end


return TENTACLE