
-- TODO:
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
	sound = {}
	
end


function update(dt)
	
	if story_loaded then
		
		if wait_tick > 0 then
			wait_tick = wait_tick - dt
			if wait_tick <= 0 then
				wait_func()
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
		wait_func = nil
		
		variable = {}
		
		story_file = io.open("stories/"..name.."/story.txt")
		file_line_iter = story_file:lines()
		file_line_prog = 0
		labels = {}
		
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
	
	if not line or line == "" then
		return
	end
	
	-- print("Text: "..line)
	
	local continue = false
	
	-- $ Commands
	if string.sub(line, 1, 1) == "$" then
		local bar_exists = string.find(line, "|")
		if bar_exists then
			local args = removeWS(string.split(string.sub(line, bar_exists + 1), "|"))
			if Command[string.sub(line, 2, bar_exists - 1)] then
				continue = Command[string.sub(line, 2, bar_exists - 1)](args)
			else
				errhand("Unknown Command: $"..string.sub(line, 2, bar_exists - 1))
			end
		else
			if Command[string.sub(line, 2)] then
				continue = Command[string.sub(line, 2)]()
			else
				errhand("Unknown Command: $"..string.sub(line, 2))
			end
		end
	
	elseif string.sub(line, 1, 1) == "+" then
		
		continue = Command["wait"]({removeWS(string.sub(line, 2))})
		
	elseif string.sub(line, 1, 2) == "->" then
		
		continue = Command["jump"]({removeWS(string.sub(line, 3))})
		
	elseif string.sub(line, 1, 2) == "-^" then
			
		continue = Command["jump_up"]({removeWS(string.sub(line, 3))})
		
	elseif string.sub(line, 1, 1) == "?" then
			
		continue = Command["question"]({removeWS(string.sub(line, 2))})
		
	elseif string.sub(line, 1, 1) == ">" then
		
		local short = removeWS(string.sub(line, 2))
		local long = removeWS(nextValidLine())
		local label = removeWS(nextValidLine())
		
		continue = Command["choice"]({short, long, label})
		
	elseif string.sub(line, 1, 1) == "=" then
			
		continue = Command["pause"]()
		
	elseif string.sub(line, 1, 1) == "<" then
			
		continue = Command["erase"]()
		
	else
		
		local colon_pos = string.find(line, ":")
		local semicolon_pos = string.find(line, ";")
		
		if colon_pos then
			
			local args = string.split(string.sub(line, colon_pos + 1), "|")
			table.insert(args, 1, string.sub(line, 1, colon_pos - 1))
			
			continue = Command["send"](removeWS(args))
			
		elseif semicolon_pos then
			
			local args = string.split(string.sub(line, semicolon_pos + 1), "|")
			table.insert(args, 1, string.sub(line, 1, semicolon_pos - 1))
			
			continue = Command["send_plain"](removeWS(args))
			
		else
			
			errhand("Unknown Command: "..line)
			
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
	
	if args[3] then
		char[args[1]] = {name = replaceVars(args[2]), pic = love.graphics.newImage("stories/"..story_name.."/images/"..args[3])}
	else
		char[args[1]] = {name = replaceVars(args[2])}
	end
	
	return true
	
end

Command["send"] = function(args)
	
	wait_tick = 0.5
	wait_func = function()
		Command["type"]({args[1]})
		wait_tick = math.min(math.max(#args[2] / 10, 0.5), 3) -- typing indicator timing
		wait_func = function()
			Command["type"]()
			Command["send_plain"](args)
			Command["wait"]({0.5})
		end
	end
	
end

Command["send_plain"] = function(args)
	
	if args[3] then
		L.ui.sendMessage(char[args[1]], string.split(replaceVars(args[2]), " "), love.graphics.newImage("stories/"..story_name.."/images/"..args[3]))
	else
		L.ui.sendMessage(char[args[1]], string.split(replaceVars(args[2]), " "))
	end
	
	return true
	
end

Command["wait"] = function(args)
	
	if args and args[1] and args[1] ~= "" then
		args[1] = replaceVars(args[1])
		
		if not tonumber(args[1]) then
			errhand("Wait time must be a number.")
			return true
		end
		
		if tonumber(args[1]) > 0 then
			wait_tick = tonumber(args[1])
			wait_func = function() next() end
		else
			return true
		end
	else
		return true
	end
	
end

Command["jump"] = function(args)
	
	args[1] = replaceVars(args[1])
	
	while true do
		
		local line = removeWS(nextValidLine())
		if line == nil then
			errhand("Unable to jump. Label '"..args[1].."' not found.")
			break
		elseif line == "#"..args[1] then
			break
		end
		
	end
	
	wait_tick = 0
	is_typing = nil
	
	return true
	
end

Command["jump_up"] = function(args)
	
	args[1] = replaceVars(args[1])
	
	if labels[args[1]] then
		story_file = io.open("stories/"..story_name.."/story.txt")
		file_line_iter = story_file:lines()
		file_line_prog = 0
		labels = {}
		while file_line_prog < labels[args[1]] do
			nextValidLine()
		end
	else
		errhand("Unable to jump up. Label '"..args[1].."' not found.")
	end
	
	return true
	
end

Command["question"] = function(args)
	
	question = replaceVars(args[1])
	
	return true
	
end

Command["choice"] = function(args)
	
	if not replies then
		replies = {}
	end
	
	table.insert(replies, {short = replaceVars(args[1]), long = replaceVars(args[2]), command = args[3]})
	
	return true
	
end

Command["pause"] = function(args)
	
	-- do nothing lol
	
end

Command["resume"] = function(args)
	
	return true
	
end

Command["erase"] = function(args)
	
	question = nil
	replies = nil
	
	return true
	
end

Command["set"] = function(args)
	
	if not args or not args[1] or string.sub(args[1], 1, 1) ~= "@" then
		errhand("Invalid variable name.")
		return true
	end
	
	local var_name = string.sub(args[1], 2)
	
	args[2] = replaceVars(args[2])
	
	if not args[3] or args[3] == "=" then
		
		if tonumber(args[2]) then
			variable[var_name] = tonumber(args[2])
		else
			variable[var_name] = args[2]
		end
		
	else
		
		if not variable[var_name] then
			errhand("Variable '"..args[1].."' not found.")
			return true
		elseif not tonumber(variable[var_name]) then
			errhand("Unable to execute math on string '"..args[1].."'.")
			return true
		end
		
		if args[3] == "+" then
			variable[var_name] = variable[var_name] + tonumber(args[2])
		elseif args[3] == "-" then
			variable[var_name] = variable[var_name] - tonumber(args[2])
		elseif args[3] == "*" then
			variable[var_name] = variable[var_name] * tonumber(args[2])
		elseif args[3] == "/" then
			variable[var_name] = variable[var_name] / tonumber(args[2])
		elseif args[3] == "%" then
			variable[var_name] = variable[var_name] % tonumber(args[2])
		else
			errhand("Unknown math operator: "..args[3])
		end
		
	end
		
	return true
	
end

Command["if"] = function(args)
	
	local action = removeWS(nextValidLine())
	
	if not args or not args[1] or not args[2] or not args[3] then
		errhand("Missing arguments.")
		return true
	end
	
	args[1] = replaceVars(args[1])
	args[3] = replaceVars(args[3])
	
	if tonumber(args[1]) then
		args[1] = tonumber(args[1])
	end
	if tonumber(args[3]) then
		args[3] = tonumber(args[3])
	end
	
	if args[2] == "==" or args[2] == "=" then
		if args[1] == args[3] then
			interpret(action)
			return false
		end
	elseif args[2] == "!=" or args[2] == "~=" then
		if args[1] ~= args[3] then
			interpret(action)
			return false
		end
	else
		if type(args[1]) == "string" or type(args[3]) == "string" then
			errhand("Unable to do mathematical comparison on string.")
			return true
		end
		
		if args[2] == ">" then
			if args[1] > args[3] then
				interpret(action)
				return false
			end
		elseif args[2] == "<" then
			if args[1] < args[3] then
				interpret(action)
				return false
			end
		elseif args[2] == ">=" then
			if args[1] >= args[3] then
				interpret(action)
				return false
			end
		elseif args[2] == "<=" then
			if args[1] <= args[3] then
				interpret(action)
				return false
			end
		else
			errhand("Unknown comparison type: '"..args[2].."'.")
			return true
		end
		
	end
	
	return true
	
end

Command["music"] = function(args)
	
	
	-- return true
	
end

Command["sound"] = function(args)
	
	arg[1] = replaceVars(arg[1])
	
	if not sound[args[1]] then
		sound[args[1]] = love.audio.newSource("stories/"..story_name.."/sounds/"..args[1], "static")
	end
	
	sound[args[1]]:stop()
	sound[args[1]]:play()
	
	return true
	
end

Command["type"] = function(args)
	
	if args and args[1] then
		
		is_typing = char[args[1]]
		
		if args[2] then
			args[2] = replaceVars(args[2])
			
			if not tonumber(args[2]) then
				errhand("Typing time must be a number.")
				return true
			end
			
			wait_tick = tonumber(args[2])
			wait_func = function()
				is_typing = nil
				next()
			end
		else
			return true
		end
		
	else
		
		is_typing = nil
		return true
		
	end
	
end

Command["cls"] = function(args)
	
	chat_log = {}
	
	return true
	
end

Command["print"] = function(args)
	
	print(replaceVars(args[1]))
	
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
			-- blank line or comment
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
		elseif string.sub(line, 1, 1) == "#" then
			-- label
			labels[removeWS(string.sub(line, 2))] = file_line_prog
			return nextValidLine()
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

function replaceVars(str)
	
	if type(str) == "string" then
		
		for index, this in pairs (variable) do
			str = string.gsub(str, "@"..index, this)
		end
		return str
		
	elseif type(str) == "table" then
		local t = {}
		for index, this in pairs (str) do
			t[index] = replaceVars(this)
		end
		return t
		
	elseif type(str) == "number" then
		return str
	end
	
end

function errhand(str)
	love.errhand(str.." (line "..file_line_prog..")")
end


return P
