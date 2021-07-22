---@diagnostic disable: lowercase-global

-- TODO:
-- decide where to save config

local P = {}
for index, this in pairs(_G) do
	P[index] = this
end
setfenv(1, P)


-- Constants

Version = 1.0

-- Built In Functions

function load()
	
	
	-- Defaults
	
	effect_volume = 1/4
	music_volume = 1/4
	
	video_fullscreen = false
	
	ui_scale = 1.2
	
	key_ui_left = "left"
	key_ui_right = "right"
	key_ui_up = "up"
	key_ui_down = "down"
	key_ui_enter = "return"
	key_ui_backspace = "backspace"
	
	
	-- Load settings from config file
	local dat = love.filesystem.read("settings.cfg")
	
	if dat then
		
		local dat_tbl = string.split(dat, "\n")
		
		for index, this in pairs (dat_tbl) do
			
			local info = string.split(this, "=")
			
			
			if L.settings[info[1]] then
				if type(L.settings[info[1]]) == "string" then
					L.settings[info[1]] = tostring(info[2])
					
				elseif type(L.settings[info[1]]) == "number" then
					L.settings[info[1]] = tonumber(info[2])
					
				elseif type(L.settings[info[1]]) == "boolean" then
					L.settings[info[1]] = info[2] == "true"
					
				end
			end
			
		end
		
	else
		
		save()
		
	end
	
	
	-- volume --
	for index, this in pairs (Sound) do
		this:setVolume(effect_volume)
	end
	
	for index, this in pairs (Music) do
		this:setVolume(music_volume)
	end
	
	L.ui.Scale = ui_scale
	
end


-- Common Functions

function save()
	
	local dat = ""
	
	for index, this in pairs (L.settings) do
		
		if type(this) ~= "function" then
			dat = dat ..index .."="..tostring(this).."\n"
		end
		
	end
	
	love.filesystem.write("settings.cfg", dat)
	
end


return P
