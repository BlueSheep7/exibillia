---@diagnostic disable: lowercase-global

-- TODO:

-- Future Feature:
-- Create vscode syntax highlighting properties
-- Group chats, multiple friends
-- File error detection
-- Syntax error detection
-- Custom error handler / log
-- Text formatting (bold / italic)

local P = {}
for index, this in pairs(_G) do
	P[index] = this
end
setfenv(1, P)


-- Constants

Max_messages = 20

Headers = {"title", "author", "version", "desc", "rating", "lang"}
Command = {}


-- Built In Functions

function load()
	
	story_loaded = false
	
end


function update(dt)
	
	if story_loaded then
		
		if wait_tick > 0 then
			wait_tick = wait_tick - dt
			if wait_tick <= 0 then
				next()
			end
		end
		
	end
	
end


-- Common Functions

function loadStory(name)
	
	-- TODO: error detection
	
	if story_loaded then
		
		io.close(story_file)
		
	end
	
	if love.filesystem.isFused() then
		love.filesystem.mount(love.filesystem.getSourceBaseDirectory(), "") -- TODO: come up with file layout
	else
		
	end
	
	if love.filesystem.getInfo("stories/"..name) then
		
		-- Create default story variables
		
		story_loaded = true
		story_name = name
		progress = 1
		
		char = {}
		me = {name = "You", pic = love.graphics.newImage("stories/"..name.."/images/me.png")}
		char["me"] = me
		
		chat_log = {}
		replies = nil
		question = nil
		is_typing = nil
		
		wait_tick = 0
		
		story_file = io.open("stories/"..name.."/story.txt")
		file_line_iter = story_file:lines()
		file_line_prog = 0
		
		getHeader()
		
	else
		love.errhand("Failed to load story: "..name)
	end
	
end

function getHeader()
	
	story_info = {}
	
	while true do
		local line = nextValidLine()
		
		if string.sub(line, 1, 2) == "==" then
			-- end of header found
			next()
			break
			
		else
			
			for _, this in pairs (Headers) do
				
				if string.sub(line, 1, #this + 1) == this..":" then
					
					story_info[this] = removeWS(string.sub(line, #this + 2))
					
				end
				
			end
			
		end
	end
	
end

function next()
	
	local line = nextValidLine()
	
	if line then
		interpret(removeWS(line))
	else
		Command["end"]()
	end
	
end

function interpret(line)
	
	if not line or removeWS(line) == "" then
		return
	end
	
	print("Text: "..line)
	
	local continue = false
	
	-- $ Commands
	if string.sub(line, 1, 1) == "$" then
		local bar_exists = string.find(line, "|")
		if bar_exists then
			local args = string.split(string.sub(line, bar_exists + 1), "|")
			if Command[string.sub(line, 2, bar_exists - 1)] then
				continue = Command[string.sub(line, 2, bar_exists - 1)](args)
			else
				love.errhand("Unknown Custom Command: $"..string.sub(line, 2, bar_exists - 1).." (line "..file_line_prog..")")
			end
		else
			if Command[string.sub(line, 2)] then
				continue = Command[string.sub(line, 2)]()
			else
				love.errhand("Unknown Custom Command: $"..string.sub(line, 2).." (line "..file_line_prog..")")
			end
		end
	
	elseif string.sub(line, 1, 1) == "+" then
		
		continue = Command["wait"]({tonumber(string.sub(line, 2))})
		
	elseif string.sub(line, 1, 1) == "#" then
		
		-- TODO: store position of all labels in order to jump up
		continue = true
		
	elseif string.sub(line, 1, 2) == "->" then
		
		continue = Command["jump"]({string.sub(line, 3)})
		
	elseif string.sub(line, 1, 2) == "-^" then
			
		continue = Command["jump_up"]({string.sub(line, 3)})
		
	elseif string.sub(line, 1, 1) == "?" then
			
		continue = Command["question"]({string.sub(line, 2)})
		
	elseif string.sub(line, 1, 1) == ">" then
		
		local short = string.sub(line, 2)
		local long = nextValidLine()
		local label = nextValidLine()
		
		continue = Command["choice"]({short, long, label})
		
	elseif string.sub(line, 1, 1) == "=" then
			
		continue = Command["pause"]()
		
	elseif string.sub(line, 1, 1) == "<" then
			
		continue = Command["erase"]()
		
	else
		
		local colon_pos = string.find(line, ":")
		
		if colon_pos then
			
			local args = string.split(string.sub(line, colon_pos + 1), "|")
			table.insert(args, 1, string.sub(line, 1, colon_pos - 1))
			
			continue = Command["send"](args)
			
		else
			
			love.errhand("Unknown Command: "..line.." (line "..file_line_prog..")")
			
		end
		
	end
	
	if continue then
		next()
	end
	
end


-- Custom Commands
-- This is where you can add your own commands
-- Make sure to return true if the game should continue to the next command once the function completes

Command["char"] = function(args)
	
	args = removeWS(args)
	
	if args[3] then
		char[args[1]] = {name = args[2], pic = love.graphics.newImage("stories/"..story_name.."/images/"..args[3])}
	else
		char[args[1]] = {name = args[2]}
	end
	
	return true
	
end

Command["send"] = function(args)
	
	args = removeWS(args)
	
	L.ui.sendMessage(char[args[1]], string.split(args[2], " "), args[3], true)
	
	-- Command["wait"]({1})
	
	return true
	
	
end

Command["wait"] = function(args)
	
	wait_tick = args[1]
	
end

Command["jump"] = function(args)
	
	local label = removeWS(args[1])
	
	while true do
		
		local line = nextValidLine()
		if line == nil then
			love.errhand("Unable to jump. Label '"..label.."' not found")
			break
		elseif line == "#"..label or line == "$label|"..label then
			break
		end
		
	end
	
	wait_tick = 0
	
	return true
	
end

Command["jump_up"] = function(args)
	
	
	-- return true
	
end

Command["question"] = function(args)
	
	
	question = removeWS(args[1])
	
	return true
	
end

Command["choice"] = function(args)
	
	args = removeWS(args)
	
	if not replies then
		replies = {}
	end
	
	table.insert(replies, {short = args[1], long = args[2], command = args[3]})
	
	return true
	
end

Command["pause"] = function(args)
	
	-- do nothing lol
	print("please do not continue")
	
end

Command["erase"] = function(args)
	
	question = nil
	replies = nil
	
	return true
	
end

Command["set"] = function(args)
	
	
	-- return true
	
end

Command["if"] = function(args)
	
	
	-- return true
	
end

Command["music"] = function(args)
	
	
	-- return true
	
end

Command["sound"] = function(args)
	
	
	-- return true
	
end

Command["type"] = function(args)
	
	is_typing = char[removeWS(args[1])]
	
	return true
	
end

Command["cls"] = function(args)
	
	chat_log = {}
	
	return true
	
end

Command["print"] = function(args)
	
	print(args[1])
	
	return true
	
end

Command["end"] = function(args)
	
	print("End of story reached")
	
end


-- Helper Functions

function nextValidLine()
	
	local line = file_line_iter()
	file_line_prog = file_line_prog + 1
	
	if line then
		
		if line == "" or string.sub(line, 1, 2) == "//" then
			return nextValidLine()
		elseif string.sub(line, 1, 2) == "/*" then
			-- multiline comment
			while true do
				line = file_line_iter()
				file_line_prog = file_line_prog + 1
				if line == nil then
					return nil
				elseif string.sub(line, 1, 2) == "*/" then
					return nextValidLine()
				end
			end
		else
			return line
		end
		
	else
		return nil
	end
	
end

-- Removes leading and trailing whitespace (spaces and tabs) from either a string or a table of strings
function removeWS(str)
	
	if type(str) == "string" then
		local leading_pos = 0
		for pos = 1, #str do
			if string.sub(str, pos, pos) ~= " " and string.sub(str, pos, pos) ~= "\t" then
				leading_pos = pos
				break
			end
		end
		local trailing_pos = 0
		for pos = #str, 1, -1 do
			if string.sub(str, pos, pos) ~= " " and string.sub(str, pos, pos) ~= "\t" then
				trailing_pos = pos
				break
			end
		end
		return string.sub(str, leading_pos, trailing_pos)
		
	elseif type(str) == "table" then
		local t = {}
		for index, this in pairs (str) do
			t[index] = removeWS(this)
		end
		return t
	end
	
end


return P
