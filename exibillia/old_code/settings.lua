-- Settings --
-- RWL --

settings = {}
settings.libname = "settings"

settings.version = "1.0"


settings.effect_volume = 1/2
settings.music_volume = 1/4

settings.video_fullscreen = false

settings.ui_scale = 1.2

settings.key_ui_left = "left"
settings.key_ui_right = "right"
settings.key_ui_up = "up"
settings.key_ui_down = "down"
settings.key_ui_enter = "return"
settings.key_ui_backspace = "backspace"

function settings.load()
	
	dat = love.filesystem.read("settings.cfg")
	
	if dat then
		
		dat_tbl = string.split(dat, "\n")
		
		for index, this in pairs (dat_tbl) do
			
			info = string.split(this, "=")
			
			
			if settings[info[1]] then
				if type(settings[info[1]]) == "string" then
					settings[info[1]] = tostring(info[2])
					
				elseif type(settings[info[1]]) == "number" then
					settings[info[1]] = tonumber(info[2])
					
				elseif type(settings[info[1]]) == "boolean" then
					settings[info[1]] = info[2] == "true"
					
				end
			end
			
		end
		
	else
		
		settings.save()
		
	end
	
	
	-- volume --
	for index, this in pairs (sound) do
		this:setVolume(settings.effect_volume)
	end
	
	for index, this in pairs (music) do
		this:setVolume(settings.music_volume)
	end
	
	-- ui --
	ui.createUI()
	
end

function settings.save()
	
	dat = ""
	
	for index, this in pairs (settings) do
		
		if index ~= "libname" and type(this) ~= "function" then
			dat = dat ..index .."="..tostring(this).."\n"
		end
		
	end
	
	love.filesystem.write("settings.cfg", dat)
	
end


return settings
