local GUI = {}

-- Create a Group
function GUI.NewGroup()
    -- PROPERTIES
    local myGroup = {}
    myGroup.elements = {}       -- A Group contains 1 or many Elements

    -- METHODS
    -- Declare some common methods for every Group
    function myGroup:addElement(pElement)
        table.insert(self.elements, pElement)
    end

    -- Hide all Elements in the Group
    function myGroup:setVisibility(pVisibility)
        for i, v in pairs(myGroup.elements) do
            v:setVisibility(pVisibility)        -- Call the Element method
        end
    end

    function myGroup:draw()
        love.graphics.push()    --  Allow to setColor, add transformations ... only on GUI during the draw()

        for i, v in pairs(myGroup.elements) do
            v:draw()        -- Call the Element method
        end

        love.graphics.pop()
    end

    function myGroup:update(dt)
        for i, v in pairs(myGroup.elements) do
            v:update(dt)        -- Call the Element method
        end
    end

    return myGroup
end


-- Create an Element
function GUI.NewElement(pX, pY)
    -- PROPERTIES
    local myElement = {}
    myElement.x = pX
    myElement.y = pY

    -- METHODS
    -- Declare some common methods for every Element
    function myElement:setVisibility(pVisibility)
        self.visible = pVisibility
    end

    function myElement:draw()
        --print("newElement / draw / Not implemented")
    end

    function myElement:update(dt)
        --print("newElement / update / Not implemented")
    end

    return myElement
end


-- Create a Panel
function GUI.NewPanel(pX, pY, pW, pH, pColorOut)
    -- PROPERTIES
    local myPanel = GUI.NewElement(pX, pY)
    myPanel.width = pW
    myPanel.height = pH
    myPanel.img = nil
    myPanel.isHover = false

    if pColor == nil then       -- Draw in white if parameter is empty
        myPanel.colorOut = {255, 255, 255}
    else
        myPanel.colorOut = pColorOut
    end

    myPanel.lstEvents = {}       -- Used to call Events (ig : button click). Link an event to a method


    -- METHODS
    function myPanel:setImage(pImage)
        self.img = pImage
        self.width = pImage:getWidth()
        self.height = pImage:getHeight()
    end

    function myPanel:draw()
        if self.visible == false then return end
        self:drawPanel()
    end

    function myPanel:drawPanel()
        love.graphics.setColor(self.colorOut[1]/255, self.colorOut[2]/255, self.colorOut[3]/255)
        if self.img == nil then
            -- Draw a rectangle (= the panel)
            love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
        else
            -- Draw the image
            love.graphics.draw(self.img, self.x, self.y)
        end
    end

    function myPanel:update(dt)
        self:updatePanel()
    end

    function myPanel:updatePanel(dt)
        -- Mouse HOVER
        local mx,my = love.mouse.getPosition()
        if (mx >= self.x and mx <= (self.x + self.width)) and (my >= self.y and my <= (self.y + self.height)) then
            if self.isHover == false then       -- to change the state only once
                self.isHover = true

                -- To react to Events
                if self.lstEvents["hover"] ~= nil then
                    self.lstEvents["hover"]("begin")        -- ("begin")  = parameter of the event method    ( onPanelHover(pState) )
                end
            end
        else
            if self.isHover then       -- to change the state only once
                self.isHover = false

                -- To react to Events
                if self.lstEvents["hover"] ~= nil then
                    self.lstEvents["hover"]("end")
                end                
            end
        end
    end

    -- For Events, called from the main.lua
    function myPanel:setEvent(pEventType, pFunction)
        self.lstEvents[pEventType] = pFunction
    end

    return myPanel
end


-- Create a ProgressBar
function GUI.NewProgressBar(pX, pY, pW, pH, pMaxValue, pColorOut, pColorIn, pVertical)
    -- PROPERTIES
    local myProgressBar = GUI.NewPanel(pX, pY, pW, pH, pColorOut)
    myProgressBar.max = pMaxValue
    myProgressBar.value = pMaxValue

    if pColorIn == nil then       -- Draw in white if parameter is empty
        myProgressBar.colorIn = {255, 255, 255}
    else
        myProgressBar.colorIn = pColorIn
    end

    -- To display a vertical progressbar
    if pVertical == nil then
        myProgressBar.isVertical = false
    else
        myProgressBar.isVertical = pVertical
    end

    myProgressBar.imgOut = nil
    myProgressBar.imgIn = nil


    -- METHODS
    function myProgressBar:draw()
        if self.visible == false then return end
        self:drawProgressBar()

        -- DEBUG
        if DEBUG_MODE == true then
            love.graphics.setColor(1,0,0)
            love.graphics.circle("fill", self.x, self.y, 5)
            love.graphics.setColor(1,1,1)

            love.graphics.print("x:"..tostring(math.floor(self.x)).." / y:"..tostring(math.floor(self.y)), self.x, self.y-10)
        end
    end

    function myProgressBar:drawProgressBar()
        love.graphics.setColor(1,1,1)   -- "reset" default color

        -- Calculate bar size in pixels  (eg for horizontal : value max = 100    width bar = 300   => if value = 30 :  30/100=0.3  then  0.3*300=90 pixels )
        local barSize

        -- Draw a rectangle if no image has been provided
        if self.imgOut ~= nil or self.imgIn ~= nil then
            barSize = (self.value / self.max) * self.width

            if self.isVertical == false then
                love.graphics.draw(self.imgOut, self.x, self.y)     -- Outer panel

                -- Inner panel : use a Quad to crop the image
                local barQuad = love.graphics.newQuad(0, 0, barSize, self.height, self.width, self.height)
                love.graphics.draw(self.imgIn, barQuad, self.x, self.y)
            else
                love.graphics.draw(self.imgOut, self.x, self.y, math.rad(-90), 1, 1, self.width)     -- Outer panel, rotate verticaly

                -- Inner panel : use a Quad to crop the image
                local barQuad = love.graphics.newQuad(0, 0, barSize, self.height, self.width, self.height)
                love.graphics.draw(self.imgIn, barQuad, self.x, self.y, math.rad(-90), 1, 1, self.width)
            end
        else
            barSize = (self.value / self.max) * self.height

            self:drawPanel()    -- Outer panel

            -- Inner panel
            love.graphics.setColor(self.colorIn[1]/255, self.colorIn[2]/255, self.colorIn[3]/255)
            if self.isVertical == false then
                love.graphics.rectangle("fill", self.x+1, self.y+1, barSize-2, self.height-2)
            else
                -- To make the rectangle go down, set the y point at the left-bottom of the rectangle and inverse the height (-barsize)
                love.graphics.rectangle("fill", self.x+1, self.y+self.height+1, self.width-2, - barSize-2)
            end
        end
    end

    function myProgressBar:setValue(pValue)
        if pValue >= 0 and pValue <= self.max then
            self.value = pValue
        end
    end

    function myProgressBar:setImages(pImgOut, pImgIn)
        self.imgOut = love.graphics.newImage(pImgOut)
        self.imgIn = love.graphics.newImage(pImgIn)

        -- Adapt panel size to the image size and center label
        self.width = self.imgOut:getWidth()
        self.height = self.imgOut:getHeight()
    end

    return myProgressBar
end


return GUI
