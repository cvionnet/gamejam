
local PARTICLES = {}

require("param")


function PARTICLES.NewParticles()
    -- PROPERTIES
    local myParticles = {}

    myParticles.lstParticles = {}

--------------------------------------------------------------------------------------------------------
    -- METHODS
    function myParticles:draw()
        for i = 1, #self.lstParticles do
            local size = self.lstParticles[i].size * self.lstParticles[i].aspectRatio

            love.graphics.setColor(self.lstParticles[i].color)
            love.graphics.rectangle("fill", self.lstParticles[i].x, self.lstParticles[i].y, size, size)
        end
        love.graphics.setColor(1, 1, 1, 1)
    end


    function myParticles:update(dt)
        for i = #self.lstParticles,1,-1  do
            -- Move Particles
            self.lstParticles[i].x = self.lstParticles[i].x + self.lstParticles[i].vx
            self.lstParticles[i].y = self.lstParticles[i].y + self.lstParticles[i].vy

            -- Delete Particles (99999 = infinite)
            if self.lstParticles[i].lifetime ~= 99999 then
                self.lstParticles[i].lifetime = self.lstParticles[i].lifetime - dt
                if self.lstParticles[i].lifetime <= 0 then
                    table.remove(self.lstParticles, i)
                end
            end
        end
    end

--------------------------------------------------------------------------------------------------------

    function myParticles:InitParticules(pX, pY, pAspectRatio, pParticleQuantity, pSizeMin, pSizeMax, pColor)
        for i = 1, pParticleQuantity do
            self:CreateParticle(self.lstParticles, pX, pY, pAspectRatio, pColor, pSizeMin, pSizeMax)
        end
    end


    function myParticles:CreateParticle(pDestinationList, pX, pY, pAspectRatio, pColor, pSizeMin, pSizeMax)
        local myParticle = {}

        myParticle.gravity = 200
        myParticle.size = math.random(pSizeMin,pSizeMax)

        myParticle.lifetime = math.random(50, 70)/100

        if pColor == nil then
            myParticle.color = {1, 1, 1}
        else
            myParticle.color = pColor
        end

        myParticle.x = pX + math.random(-5, 5)     -- math.random(-5, 5) : to not display all Particles at the same start point
        myParticle.y = pY + math.random(-5, 5)
        myParticle.aspectRatio = pAspectRatio

        -- Bug possible : si on tombe sur 0, la Particle ne bougera pas (correction : boucler sur le random tant que la valeur est 0)
        myParticle.vx = math.random(-150, 150)/myParticle.gravity     -- /myParticle.gravity : to have a more precise number
        myParticle.vy = math.random(-150, 150)/myParticle.gravity

        table.insert(pDestinationList, myParticle)
    end

--------------------------------------------------------------------------------------------------------

    return myParticles
end


return PARTICLES