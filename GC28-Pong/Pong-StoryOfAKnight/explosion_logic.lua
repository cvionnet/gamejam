
local EXPLOSION = {}

require("param")


function EXPLOSION.NewExplosion()
    -- PROPERTIES
    local myExplosion = {}

    myExplosion.x = 0
    myExplosion.y = 0
    myExplosion.w = 0
    myExplosion.h = 0
    myExplosion.angle = 0
    myExplosion.aspectRatio = 1

    myExplosion.frame = 1
    myExplosion.images = {}

    myExplosion.isFinished = false

--------------------------------------------------------------------------------------------------------
    -- METHODS
    function myExplosion:draw()
        love.graphics.draw(self.images[math.floor(self.frame)], self.x, self.y, math.rad(self.angle), self.aspectRatio, self.aspectRatio, self.w/2, self.h/2)
        --love.graphics.draw(self.images[math.floor(self.frame)], self.x + math.random(-40,-30), self.y + math.random(30,40), math.rad(self.angle), self.aspectRatio, self.aspectRatio, self.w/2, self.h/2)
        --love.graphics.draw(self.images[math.floor(self.frame)], self.x + math.random(30,40), self.y + math.random(-40,-30), math.rad(self.angle), self.aspectRatio, self.aspectRatio, self.w/2, self.h/2)
    end

    function myExplosion:update(dt)
        self.frame = self.frame + FRAME_PER_SECOND_EXPLOSION * dt
        if self.frame > #self.images+1 then
            self.frame = 1
            self.isFinished = true      -- to delete the explosion in the list in "monster_logic"
        end
    end

    --------------------------------------------------------------------------------------------------------

    -- To load animation sprites and position where the explision will be displayed
    function myExplosion:InitExplosion(pX, pY, pAspectRatio, pAngle, pAnimationFile, pAnimationNumberFrames)
        self:LoadExplosionAnimation(pAnimationFile, pAnimationNumberFrames)

        self.x = pX
        self.y = pY
        self.angle = pAngle
        self.aspectRatio = pAspectRatio
    end


    function myExplosion:LoadExplosionAnimation(pImageName, pImageNumber)
        for i = 1, pImageNumber do
            self.images[i] = love.graphics.newImage("images/explosion/"..pImageName..tostring(i)..".png")
        end

        self.w = self.images[1]:getWidth() * self.aspectRatio
        self.h = self.images[1]:getHeight() * self.aspectRatio

        if sndGameEnemy_Disappear:isPlaying() then sndGameEnemy_Disappear:stop() end
        sndGameEnemy_Disappear:play()
    end

    return myExplosion
end


return EXPLOSION