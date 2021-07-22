-- Library Manager
-- Last Updated: 22/07/2021 --


local debug_mode = true
local debug_toggle_key = "f3"
local debug_time_scale = 3
local debug_time_key = "rshift"
local debug_quit_tick = 0
local debug_font = love.graphics.newFont(12)


utf8 = require("utf8")
math.randomseed(os.time())
math.random()


-- Global Helper Functions --

function table.clone(t) -- deep-copy a table
    if type(t) ~= "table" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            target[k] = table.clone(v)
        else
            target[k] = v
        end
    end
    setmetatable(target, meta)
    return target
end

function string.split(str, splitter)
	local t = {}
	local c = 1
	local lastc = 1
	while c <= #str - #splitter + 1 do
		if string.sub(str, c, c + #splitter - 1) == splitter then
			table.insert(t, string.sub(str, lastc, c-1))
			c = c + #splitter
			lastc = c
		else
			c = c + 1
		end
	end
	table.insert(t, string.sub(str, lastc, #str))
	return t
end

function LoadImages(path)
	
	local img = {}
	local files = love.filesystem.getDirectoryItems(path)
	
	for _, this in pairs (files) do
		if love.filesystem.getInfo(path.."/"..this).type == "directory" then
			img[this] = LoadImages(path.."/"..this)
			
		elseif string.sub(this, #this - 3) == ".png" or string.sub(this, #this - 3) == ".jpg" or string.sub(this, #this - 3) == ".gif" then
			img[string.sub(this, 1, #this - 4)] = love.graphics.newImage(path.."/"..this)
			
		end
	end
	
	return img
	
end

function LoadSounds(path, stream_type)
	
	local sound = {}
	local files = love.filesystem.getDirectoryItems(path)
	
	for _, this in pairs (files) do
		if love.filesystem.getInfo(path.."/"..this).type == "directory" then
			sound[this] = LoadSounds(path.."/"..this, stream_type)
			
		elseif string.sub(this, #this - 3) == ".ogg" or string.sub(this, #this - 3) == ".wav" or string.sub(this, #this - 3) == ".mp3" then
			sound[string.sub(this, 1, #this - 4)] = love.audio.newSource(path.."/"..this, stream_type)
			if string.sub(this, #this - 8, #this - 4) == "_loop" then
				sound[string.sub(this, 1, #this - 4)]:setLooping(true)
			end
			
		end
	end
	
	return sound
	
end

function LoadFonts(path)
	
	local font = {}
	local files = love.filesystem.getDirectoryItems(path)
	
	for _, this in pairs (files) do
		if love.filesystem.getInfo(path.."/"..this).type == "directory" then
			font[this] = LoadFonts(path.."/"..this)
			
		elseif string.sub(this, #this - 3) == ".ttf" or string.sub(this, #this - 3) == ".ttc" or string.sub(this, #this - 3) == ".otf" then
			font[string.sub(this, 1, #this - 4)] = love.graphics.newFont(path.."/"..this)
			
		end
	end
	
	return font
	
end

function StopAllAudio(tbl)
	for k,v in pairs (tbl) do
		if type(v) == "table" then
			StopAllAudio(v)
		else
			v:stop()
		end
	end
end


-- Draw Functions --
-- Add items to draw_table along with it's origin library in order for the draw function inside the library to be called.
-- Items will be drawn in order of y value

local draw_table = {}

function DrawAdd(lib, id, y, args)
	if #draw_table == 0 or y > draw_table[#draw_table].y then
		table.insert(draw_table, {library = lib, id = id, y = y, args = args})
	else
		for drawindex, drawvalue in pairs(draw_table) do
			if y < drawvalue.y then
				table.insert(draw_table, drawindex, {library = lib, id = id, y = y, args = args})
				break
			end
		end
	end
end

function DrawRemove(id)
	for drawindex, drawvalue in pairs(draw_table) do
		if drawvalue.id == id then
			table.remove(draw_table, drawindex)
			-- break
		end
	end
end

function DrawPurge(lib)
	for drawindex, drawvalue in pairs(draw_table) do
		if drawvalue.library == lib then
			table.remove(draw_table, drawindex)
		end
	end
end

function DrawUpdateY(id, y) -- SUPER INEFFICIENT. PLEASE REDO --
	for drawindex, drawvalue in pairs(draw_table) do
		if drawvalue.id == id then
			local moved = drawvalue
			table.remove(draw_table, drawindex)
			if #draw_table == 0 or y > draw_table[#draw_table].y then
				table.insert(draw_table, {library = moved.lib, id = moved.id, y = y, args = moved.args})
			else
				for drawindex, drawvalue in pairs(draw_table) do
					if y < drawvalue.y then
						table.insert(draw_table, drawindex, {library = moved.lib, id = moved.id, y = y, args = moved.args})
						break
					end
				end
			end
			break
		end
	end
end


-- Load in assets --

local t

t = os.clock()
io.write("Loading images...")
Img = LoadImages("graphics")
print("done. ("..(os.clock()-t).."s)")

t = os.clock()
io.write("Loading music and sounds...")
Sound = LoadSounds("sounds", "static")
Music = LoadSounds("music", "stream")
print("done. ("..(os.clock()-t).."s)")

t = os.clock()
io.write("Loading fonts...")
Font = LoadFonts("fonts")
print("done. ("..(os.clock()-t).."s)")


-- Load Libraries --
L = {}
local file = love.filesystem.getDirectoryItems("")
local name, package
for _, this in pairs(file) do
	if string.sub(this, #this - 3) == ".lua" then
		if this ~= "main.lua" and this ~= "conf.lua" then
			t = os.clock()
			name = string.sub(this, 1, #this - 4)
			io.write("Loading library: "..this.."...")
			package = require(name)
			if package ~= true then
				L[name] = package
				L[name].name = name
			end
			print("done. ("..(os.clock()-t).."s)")
		end
	end
end


-- Interact Table --
-- Each library may give itself a value of importance to determine the order in which the libraries' interaction functions are called
-- The smaller the value of interact_weight, the earlier the library is called upon
local interact_table = {}
for L_index, L_value in pairs(L) do
	if L_value.interact_weight then
		
		if #interact_table == 0 or L_value.interact_weight > interact_table[#interact_table].interact_weight then
			table.insert(interact_table, L_value)
		elseif L_value.interact_weight == interact_table[#interact_table].interact_weight then
			love.errhand("Overlap found in interact table at "..L_index.." ("..L_value.interact_weight..")")
		else
			for index, this in pairs(interact_table) do
				if L_value.interact_weight == this.interact_weight then
					love.errhand("Overlap found in interact table at "..L_index)
				elseif L_value.interact_weight < this.interact_weight then
					table.insert(interact_table, index, L_value)
					break
				end
			end
		end
		
	end
end


function love.load(args)
	for _, this in pairs(L) do
		if this.load then
			this.load(args)
		end
	end
end

function love.draw()
	
	for _, this in pairs(draw_table) do
		if this.library.draw then
			this.library.draw(this.id, this.args)
		end
	end
	
	if debug_mode then
		for _, this in pairs(draw_table) do
			if this.library.drawDebug then
				this.library.drawDebug(this.id, this.args)
			end
		end
		
		love.graphics.origin()
		love.graphics.setFont(debug_font)
		love.graphics.setColor(0, 0, 0, 0.5)
		love.graphics.rectangle("fill", 0, 0, 450, (#draw_table+1) * 15)
		love.graphics.setColor(1, 1, 1)
		
		-- Stats --
		love.graphics.print("FPS: "..love.timer.getFPS(), 350, 0)
		
		-- Interact Table --
		love.graphics.print("Interact Table:", 200, 0)
		for index, this in pairs(interact_table) do
			if this.interact_weight then
				love.graphics.print(this.name..": "..this.interact_weight, 200, index * 15)
			end
		end
		
		-- Draw Table --
		love.graphics.print("Draw Table:", 0, 0)
		for index, this in pairs(draw_table) do
			if this.library.debug_color then
				love.graphics.setColor(this.library.debug_color[1], this.library.debug_color[2], this.library.debug_color[3])
			else
				love.graphics.setColor(1, 1, 1)
			end
			if type(this.id) == "string" then
				love.graphics.print(this.library.name.." - "..this.id..": "..this.y, 0, index * 15)
			else
				love.graphics.print(this.library.name..": "..this.y, 0, index * 15)
			end
		end
	end
	
end

function love.update(dt)
	
	if debug_mode then
		if love.keyboard.isDown("escape") then
			debug_quit_tick = debug_quit_tick + dt
			if debug_quit_tick > 0.5 then
				love.event.quit()
			end
		else
			debug_quit_tick = 0
		end
		if love.keyboard.isDown(debug_time_key) then
			dt = dt * debug_time_scale
		end
	end
	
	for _, this in pairs(L) do
		if this.update then
			this.update(dt)
		end
	end
	
end

function love.keypressed(key)
	if key == debug_toggle_key then
		debug_mode = not debug_mode
	end
	for _, this in pairs(interact_table) do
		if this.keypressed then
			if this.keypressed(key) then break end
		end
	end
end

function love.keyreleased(key)
	for _, this in pairs(interact_table) do
		if this.keyreleased then
			this.keyreleased(key)
		end
	end
end

function love.textinput(text)
	for _, this in pairs(interact_table) do
		if this.textinput then
			if this.textinput(text) then break end
		end
	end
end

function love.mousepressed(x, y, b)
	for _, this in pairs(interact_table) do
		if this.mousepressed then
			if this.mousepressed(x, y, b) then break end
		end
	end
end

function love.mousereleased(x, y, b)
	for _, this in pairs(interact_table) do
		if this.mousereleased then
			this.mousereleased(x, y, b)
		end
	end
end

function love.wheelmoved(x, y)
	for _, this in pairs(interact_table) do
		if this.wheelmoved then
			if this.wheelmoved(x, y) then break end
		end
	end
end

function love.resize(w, h)
	for _, this in pairs(L) do
		if this.resize then
			this.resize(w, h)
		end
	end
end

function love.filedropped(f)
	for _, this in pairs(L) do
		if this.filedropped then
			this.filedropped(f)
		end
	end
end

function love.quit()
	for _, this in pairs(L) do
		if this.quit then
			if this.quit() then
				return true
			end
		end
	end
	return false
end


