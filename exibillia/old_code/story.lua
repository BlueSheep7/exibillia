-- User --
-- RWL --

story = {}
story.libname = "story"

story.prog = 0
story.path = "START"

story.waiting = false
story.wait_time = 0



function story.load()
	-- story.loadStory("test2")
end


function story.loadStory(name, username, profile_pic)
	
	if not username or username == "" then username = "You" end
	
	this_story = require("stories/"..name.."/story")
	
	print("Loading "..this_story.title.." by "..this_story.author)
	
	this_story.users["me"] = {name = username, pic = "me", status = "online"}
	
	for index, this in pairs (this_story.chats) do
		this.msg = {}
	end
	
	-- Auto Event Adder --
	for index, this in pairs (this_story.story) do
		
		local prog = 1
		
		while this[prog] do
			
			event = this[prog]
			
			if event[1] == "msg" or event[1] == "choice" or event[1] == "typing" or event[1] == "clear" then
				if not event.chat then event.chat = 1 end
			end
			
			if event[1] == "msg" then
				
				if event.user and event.user ~= "me" and not event.clean then
					table.insert(this, prog, {"wait", time = 1})
					prog = prog + 1
					if event.text then
						table.insert(this, prog, {"typing", chat = event.chat, user = event.user, status = true})
						prog = prog + 1
						if event.type_time then
							table.insert(this, prog, {"wait", time = event.type_time})
						else
							table.insert(this, prog, {"wait", time = math.max(#event.text / 20, 0.5)})
						end
						prog = prog + 1
						table.insert(this, prog, {"typing", chat = event.chat, user = event.user, status = false})
						prog = prog + 1
					elseif event.img then
						table.insert(this, prog, {"wait", time = 1})
						prog = prog + 1
					end
				end
				
			end
			
			prog = prog + 1
			
		end
		
	end
	
	story.img = loadImages("stories/"..name.."/images")
	
	if profile_pic then
		story.img.me = profile_pic
	end
	
	if this_story.onLoad then
		this_story.onLoad()
	end
	
	story.progress()
	
end


function story.update(dt)
	
	if story.waiting then
		
		story.wait_time = story.wait_time - dt
		if story.wait_time <= 0 then
			story.waiting = false
			story.progress()
		end
		
	end
	
end


function story.progress(path, label)
	
	story.waiting = false
	
	if not path and not label then
		
		story.prog = story.prog + 1
		
	else
		
		if path then
			story.path = path
		end
		
		if label then
			for index, this in pairs (this_story.story[story.path]) do
				if this[1] == "label" and (this[2] == label or this.label == label) then
					story.prog = index
					break
				elseif index == #this_story.story[story.path] then
					love.errhand("Unable to find label '"..label.."' in path '"..story.path.."'")
				end
			end
		else
			story.prog = 1
		end
		
	end
	
	
	if this_story.story[story.path] and this_story.story[story.path][story.prog] then
		
		event = this_story.story[story.path][story.prog]
		
		if event[1] == "msg" then
			
			local text = nil
			if event.text then
				text = story.subVariables(event.text)
				text = string.split(text, " ")
			end
			
			local message_sound = false
			if event.message_sound or event.message_sound == nil then
				message_sound = true
			end
			
			ui.sendMessage(event.user, text, event.img, message_sound)
			
			story.progress()
			
		elseif event[1] == "jump" then
			
			if event.path then
				story.path = event.path
			end
			
			if event.label then
				for index, this in pairs (this_story.story[story.path]) do
					if this[1] == "label" and (this[2] == event.label or this.label == event.label) then
						story.prog = index
						break
					elseif index == #this_story.story[story.path] then
						love.errhand("Unable to find label '"..event.label.."' in path '"..story.path.."'")
					end
				end
			else
				story.prog = 0
			end
			
			story.progress()
			
		elseif event[1] == "label" then
			
			story.progress()
			
		elseif event[1] == "choice" then
			
			if event.reply and #event.reply > 0 then
				
				this_story.chats[event.chat].question = event.question
				this_story.chats[event.chat].reply = event.reply
				
				ui.selected_reply = 1
				
			else
				
				this_story.chats[event.chat].question = nil
				this_story.chats[event.chat].reply = nil
				this_story.chats[event.chat].reply_choice = nil
				
			end
			
			if not event.pause then
				story.progress()
			end
			
		elseif event[1] == "code" then
			
			event[2]()
			
			story.progress()
			
		elseif event[1] == "wait" then
			
			story.waiting = true
			story.wait_time = event.time
			
		elseif event[1] == "typing" then
			
			if event.status then
				this_story.chats[event.chat].is_typing = event.user
			else
				this_story.chats[event.chat].is_typing = nil
			end
			
			story.progress()
			
		elseif event[1] == "clear" then
			
			this_story.chats[event.chat].msg = {}
			
			story.progress()
			
		elseif event[1] == "pause" then
			
			print("Manually paused.")
			
		else
			
			love.errhand("Unknown event type: "..event[1])
			
			story.progress()
			
		end
		
		
	else
		print("Ran out of story. Pausing.")
	end
	
end


function story.subVariables(str)
	
	out_str = ""
	
	last_pos = 1
	for pos1 = 1, #str do
		
		if string.sub(str, pos1, pos1) == "{" then
			
			out_str = out_str .. string.sub(str, last_pos, pos1-1)
			last_pos = pos1+1
			
			for pos2 = pos1, #str do
				
				if string.sub(str, pos2, pos2) == "}" then
					
					local indexes = string.split(string.sub(str, pos1+1, pos2-1), ".")
					local var = table.combineIndexes(this_story, indexes) or table.combineIndexes(_G, indexes)
					out_str = out_str .. tostring(var)
					
					pos1 = pos2+1
					last_pos = pos1
					break
					
				end
				
			end
			
		end
		
	end
	out_str = out_str .. string.sub(str, last_pos)
	
	return out_str
	
end


function story.quit()
	
	if this_story and this_story.onQuit then
		return this_story.onQuit()
	end
	
end


return story
