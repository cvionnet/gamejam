
--[[
-- NEW SCRIPT TEMPLATE

--local defmath = require("defmath.defmath")	-- to use https://github.com/subsoap/defmath
--require("src.scripts.utils.utils")

function init(self)
	--msg.post(".", "acquire_input_focus")
end

function update(self, dt) end
function on_message(self, message_id, message, sender) end
function on_input(self, action_id, action) end
function final(self) end
function on_reload(self) end

]]
-------------------------------------------------------------------------------------------------------------


-- GAME SPECIFIC ------------------------------------------------------------------------------------------------------

--* HOW TO USE : to get access to the functions, add:      require "my_directory.utils"

DEBUG_MODE = true

ZOOM_LEVEL = 1

--* HOW TO USE : add hashes of keys defined in file "game.input_binding"
INPUT = {
	-- TOUCH
	TOUCH = hash("touch")
}

--* HOW TO USE : add hashes of most called hash in the the game  (update score ...)
GAME = {
	BAG = hash("bag"),
	GIFT = hash("gift"),
	GIFT_IN_BAG = hash("gift_in_bag"),

	BORDER = hash("border"),
	BORDER_LEFT = hash("/borderleft"),
	BORDER_RIGHT = hash("/borderright")
}


-- SYSTEM -------------------------------------------------------------------------------------------------------------

gameWidth = tonumber(sys.get_config("display.width"))
gameHeight = tonumber(sys.get_config("display.height"))

--math.randomseed(100000 * (socket.gettime() % 1))
math.randomseed(socket.gettime()) math.random() math.random()

MESSAGE = {
	-- COLLISIONS
	CONTACT = hash("contact_point_response"),
	COLLISION = hash("collision_response"),
	TRIGGER = hash("trigger_response"),
	RAYCAST_HIT = hash("ray_cast_response"),
	RAYCAST_MISS = hash("ray_cast_missed"),

	-- SPRITE
	ANIM_PLAY = hash("animation_play"),
	ANIM_DONE = hash("animation_done"),

	-- PROXY
	PROXY_LOAD = hash("proxy_loaded"),
	PROXY_UNLOAD = hash("proxy_unloaded")
}


-- METHODS ------------------------------------------------------------------------------------------------------------

-- If Debug mode is active, allow to display FPS, profiler and debug collision
--* HOW TO USE:
-- 		- add these lines in the on_input()
--			if action_id == hash("debug_profiler") and action.released then	Debug_Tools(self, "PROFILER")
--			elseif action_id == hash("debug_collision") and action.released then Debug_Tools(self, "COLLISION")
--			end
-- Return : pStatus = ON or OFF
function Debug_Tools(self, pCommand, pStatus)
	if DEBUG_MODE == true then
		if pCommand == "FPS" then
			if pStatus == "ON" then
				print("TODO: add dynamically the metrics/fps.go and metrics/mem.go")
			elseif pStatus == "OFF" then
				print("TODO: delete dynamically the metrics/fps.go and metrics/mem.go")
			end
		end

		if pCommand == "PROFILER" then
			msg.post("@system:", "toggle_profile")
		end

		if pCommand == "COLLISION" then
			msg.post("@system:", "toggle_physics_debug")

			--if self.show_debug then msg.post("main:/loader", "set_time_step", { factor = 1, mode = 0 })
			--else msg.post("main:/loader", "set_time_step", { factor = 0.1, mode = 1 })
			--end
		end
	end
end


-- Set the zoom level
-- Use with Orthographic plugin (https://github.com/britzl/defold-orthographic)
function Camera_Set_Zoom_Level()
	-- Set zoom factor depending of device
	-- TODO : GO Zoom property  :  FIXED_ZOOM
	--[[
	if sys.get_sys_info().system_name == "Android" or sys.get_sys_info().system_name == "iPhone OS" then
		ZOOM_LEVEL = 10
	else
		ZOOM_LEVEL = 6
	end
	msg.post("/camera#script", "zoom_to", { zoom = ZOOM_LEVEL } )
	]]

	ZOOM_LEVEL = go.get("/camera#script", "zoom")
end



-- ******************************************************************************************************* --
-- * Resolving kinematic collisions (https://defold.com/manuals/physics/#resolving-kinematic-collisions) *
-- ******************************************************************************************************* --
--* HOW TO USE:
-- 		- add this line at the end of the init() and update() methods :      self.collisionResolving = vmath.vector3()
--		- call the method in the on_message()   (at the end, if a collision occurs)
--						(...)
--						-- Apply compensation
--						local comp = ResolveKinematicCollisions(self, message)
--						go.set_position(go.get_position() + comp)
--						self.collisionResolving = self.collisionResolving + comp
-- Return : the compensation to apply on the game object (a vector3)
function ResolveKinematicCollisions(self, message)
	-- Get the info needed to move out of collision. We might	get several contact points back and have to calculate
	-- how to move out of all of them by accumulating a correction vector for this frame:
	local comp = vmath.vector3()
	if message.distance > 0 then
		-- First, project the accumulated correction onto the penetration vector
		local proj = vmath.project(self.collisionResolving, message.normal * message.distance)
		if proj < 1 then
			-- Only care for projections that does not overshoot
			comp = (message.distance - message.distance * proj) * message.normal
		end
	end
	return comp
end




--[[
-- Method to debug message send  (override the msg.post default method)
-- source : https://forum.defold.com/t/could-not-send-message-unknown-from-game-unknown-unknown-to-unknown-unknown/64789

local msg_post = msg.post

msg.post = function(receiver, message_id, message)
	local ok, err = pcall(msg_post, receiver, message_id, message)
	if not ok then
		print("Unable to send message", message_id, " to ", receiver)
		print(err)
	end
end
]]

