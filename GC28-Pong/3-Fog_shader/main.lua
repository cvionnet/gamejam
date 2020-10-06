-- Display console trace during execution
io.stdout:setvbuf('no')

-- For pixel art (set scaling filters interpolation - https://love2d.org/wiki/FilterMode)
love.graphics.setDefaultFilter("nearest")
local scaleZoom = 8

-- To debug step by step in ZeroBraneStudio
if arg[#arg] == "-debug" then require("mobdebug").start() end

math.randomseed(love.timer.getTime())

--------------------------------------------------------------------------------------------------------

local time = 0

local bg = love.graphics.newImage("noise.png")
local hero = love.graphics.newImage("hero.png")

local image_data
local image


local shader = love.graphics.newShader([[
    extern vec3 fog_color = vec3(0.35, 0.48, 0.95);
    extern int octaves = 4;
    extern vec2 speed = vec2(0.0, 1.0);
    extern float time;

    float rand(vec2 coord)
    {
        return fract(sin(dot(coord, vec2(56, 78)) * 1000.0) * 1000.0);
    }

    float noise(vec2 coord)
    {
        vec2 i = floor(coord); //get the whole number
        vec2 f = fract(coord); //get the fraction number
        float a = rand(i); //top-left
        float b = rand(i + vec2(1.0, 0.0)); //top-right
        float c = rand(i + vec2(0.0, 1.0)); //bottom-left
        float d = rand(i + vec2(1.0, 1.0)); //bottom-right
        vec2 cubic = f * f * (3.0 - 2.0 * f);
        return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y; //interpolate
    }

    float fbm(vec2 coord) //fractal brownian motion
    {
        float value = 0.0;
        float scale = 0.5;
        for (int i = 0; i < octaves; i++)
        {
            value += noise(coord) * scale;
            coord *= 2.0;
            scale *= 0.5;
        }
        return value;
    }

    vec4 effect(vec4 color, Image texture, vec2 tc, vec2 sc)
    {
        vec2 coord = tc * 20.0;
        vec2 motion = vec2(fbm(coord + vec2(time * speed.x, time * speed.y)));
        float final = fbm(coord + motion);
        return vec4(fog_color, final * 0.5);
    }
]])

--------------------------------------------------------------------------------------------------------

function love.load()
    xScreenSize = love.graphics.getWidth() / scaleZoom
    yScreenSize = love.graphics.getHeight() / scaleZoom


    local fog_color = {0.35, 0.48, 0.95} --{0.1, 0.0, 0.0}
    local octaves = 1
    local speed = {0.5, 0.9}

    shader:send("fog_color", fog_color)
    shader:send("octaves", octaves)
    shader:send("speed", speed)

	image_data = love.image.newImageData(love.graphics.getWidth(), love.graphics.getHeight())
	image = love.graphics.newImage(image_data)
end


function love.update(dt)
	time = time + dt
    shader:send("time", time)
end




function love.draw()
    love.graphics.draw(hero, 50, 50, 0, 2, 2)



    -- save state
    local fg_r, fg_g, fg_b, fg_a = love.graphics.getColor()
--    love.graphics.setColor(fg_r, fg_g, fg_b, fg_a)
--    love.graphics.setBlendMode("alpha")


    love.graphics.setShader(shader)    -- apply the shader
    love.graphics.draw(bg, time, 1)
--    love.graphics.rectangle("fill", 1, 1, 400, 400)
    love.graphics.setShader()       -- disable the shader




    love.graphics.draw(hero, 100, 50, 0, 2, 2)
end





function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

--------------------------------------------------------------------------------------------------------

--[[ 
function love.draw()
    love.graphics.draw(hero, 50, 50, 0, 2, 2)




    -- save state
    local canvas = love.graphics.getCanvas()
    local shader = love.graphics.getShader()
    local fg_r, fg_g, fg_b, fg_a = love.graphics.getColor()

    love.graphics.clear(love.graphics.getBackgroundColor())

    -- draw scene to front buffer
    local front, back = love.graphics.newCanvas(400,400), love.graphics.newCanvas(400,400)
    buffer(front, back)
    love.graphics.setCanvas(front, back)

    -- save more state
    local blendmode = love.graphics.getBlendMode()

    -- process all shaders
    love.graphics.setColor(fg_r, fg_g, fg_b, fg_a)
    love.graphics.setBlendMode("alpha", "premultiplied")



    buffer(front, back)
    love.graphics.setCanvas(front)
    love.graphics.clear()

    love.graphics.setShader(shader)    -- apply the shader
    --love.graphics.draw(bg)
    love.graphics.draw(back)
--    love.graphics.rectangle("fill", 1, 1, 400, 400)
--    love.graphics.setShader()       -- disable the shader




    -- present result
    love.graphics.setShader()
    love.graphics.setCanvas(canvas)
    love.graphics.draw(front,0,0)

    -- restore state
    love.graphics.setBlendMode(blendmode)
    love.graphics.setShader(shader)








    love.graphics.draw(hero, 100, 50, 0, 2, 2)
end


function buffer (front, back)
    back, front = front, back
    return front, back
end

 ]]
