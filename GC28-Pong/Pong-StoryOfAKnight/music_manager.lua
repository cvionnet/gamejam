
local MUSIC_MANAGER = {}

require("param")


function MUSIC_MANAGER.NewMusic()
    -- PROPERTIES
    local myMusic = {}

    myMusic.lstMusics = {}     -- to store all musics in the mixer
    myMusic.currentMusic = 0   -- ID of the playing music


--------------------------------------------------------------------------------------------------------
    -- METHODS
    function myMusic:update()
--[[         -- Check for all musics
        for index, music in ipairs(myMusic.lstMusics) do
            -- 1/ if playing music doesn't have full volume, volume it up (fadein)
            if index == myMusic.currentMusic then
                if music.source:getVolume() < 1 then
                    music.source:setVolume(music.source:getVolume()+0.01)
                end
            -- 2/ if other musics doesn't have volume at 0, volume it down (fadeout)
            else
                if music.source:getVolume() > 0 then
                    music.source:setVolume(music.source:getVolume()-0.01)
                end
            end
        end ]]
    end

--------------------------------------------------------------------------------------------------------
    -- Add a music in the list
    function myMusic:AddMusic(pMusic)
        local newMusic = {}
        newMusic.source = pMusic

        newMusic.source:setLooping(true)
        --newMusic.source:setVolume(0)

        table.insert(myMusic.lstMusics, newMusic)
    end


    -- Start a music using its ID
    function myMusic:PlayMusic(pNum)
        local music = myMusic.lstMusics[pNum]

--[[         -- Play music if volume is 0 and is not the actual music playing
        if music.source:getVolume() == 0 and myMusic.currentMusic ~= pNum then
            music.source:play()
        end ]]

        music.source:play()
        myMusic.currentMusic = pNum
    end
--------------------------------------------------------------------------------------------------------


    return myMusic
end


return MUSIC_MANAGER
