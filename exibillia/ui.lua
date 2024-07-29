
-- TODO:
-- sfx mute button
-- colour theme
-- multiple chats
-- speed modifier
-- first msg doesnt scroll bug
-- emoji support
-- send sound effect

local P = {}
for index, this in pairs(_G) do
	P[index] = this
end
setfenv(1, P)

interact_weight = -1
DrawAdd(P, "ui", -1)

-- Constants
Scale = 1
Font_size = 15
Title_font_size = 50
Profile_size = 40
Padding = 30
Friend_list_w = 250
Reply_box_h = 50
Text_spacing = Font_size + 10
Scroll_bar_h = 150
Type_speed = 60 -- characters per second
Auto_scroll_speed = 1000
Caret_speed = 0.5
Profile_settings_w = 400
Profile_settings_h = 150
Title_time = 3

Cursor = {}
Cursor.arrow = love.mouse.getSystemCursor("arrow")
Cursor.hand = love.mouse.getSystemCursor("hand")

-- must be re-loaded if scale is changed
Main_font = love.graphics.newFont(Font_size * Scale)
Title_font = love.graphics.newFont(Title_font_size * Scale)

-- Built In Functions

function load()
	
	show_chat = false
	show_profile_settings = true
	
	caret_tick = 0
	caret_show = true
	scroll = 0
	max_scroll = 0
	type_tick = 0
	type_prog = 0
	backspacing = false
	auto_scrolling = false
	type_sound_tick = 0
	selected_reply = 1
	typed_reply = nil
	title_text = nil
	title_sub_text = nil
	title_tick = Title_time
	
	username = ""
	selected_story = "test_horror"
	
end

function draw()

	love.graphics.origin()
	love.graphics.setColor(60/255, 60/255, 60/255)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	-- love.graphics.translate(getCamX(), getCamY())
	love.graphics.scale(Scale)
	
	love.graphics.setFont(Main_font)
	
	love.mouse.setCursor(Cursor.arrow)
	mx = (love.mouse.getX() - getCamX()) / Scale
	my = (love.mouse.getY() - getCamY()) / Scale
	
	-- Friends List --
		
	love.graphics.setColor(50/255, 50/255, 50/255)
	love.graphics.rectangle("fill", 0, 0, Friend_list_w, getResY())
	
	love.graphics.setColor(1, 1, 1)
	printF("Friends", Padding, Padding)
	
	-- Chat --
	if show_chat then
		
		local y = 0
		local last_user
		for index_msg, this_msg in pairs (L.story.chat_log) do
			
			if last_user ~= this_msg.user then
				
				y = y + 1
				
				if this_msg.user then
					love.graphics.setColor(1, 1, 1)
					local pp
					if this_msg.user.pic then
						pp = this_msg.user.pic
					else
						pp = Img.ui.default_profile
					end
					love.graphics.draw(pp, Friend_list_w + Padding, y * Text_spacing + scroll + Padding - Font_size/2, 0, Profile_size / pp:getWidth(), Profile_size / pp:getHeight(), 0, 0)
					
					love.graphics.setColor(60/255, 60/255, 60/255)
					love.graphics.draw(Img.ui.profile_border, Friend_list_w + Padding, y * Text_spacing + scroll + Padding - Font_size/2, 0, Profile_size / Img.ui.profile_border:getWidth(), Profile_size / Img.ui.profile_border:getHeight(), 0, 0)
					
					love.graphics.setColor(1, 1, 1)
					printF(this_msg.user.name, Friend_list_w + Padding*3/2 + Profile_size, y * Text_spacing + scroll + Padding)
				end
				
				y = y + 1
				
			end
			
			local x = 0
			if this_msg.text then
				love.graphics.setColor(1, 1, 1)
				for index_word, this_word in pairs (this_msg.text) do
					
					if x + Main_font:getWidth(this_word)/Scale > getResX() - Friend_list_w - Padding*5/2 - Profile_size then
						y = y + 1
						x = 0
					end
					printF(this_word, Friend_list_w + Padding*3/2 + Profile_size + x, y * Text_spacing + scroll + Padding)
					x = x + Main_font:getWidth(this_word.." ")/Scale
					
				end
				
				y = y + 1
			end
			
			if this_msg.img then
				
				love.graphics.draw(this_msg.img, Friend_list_w + Padding*3/2 + Profile_size, y * Text_spacing + scroll + Padding)
				y = y + math.ceil(this_msg.img:getHeight() / Text_spacing) + 1
				
			end
			
			last_user = this_msg.user
			
		end
		
		-- reply box --
		love.graphics.setColor(60/255, 60/255, 60/255)
		love.graphics.rectangle("fill", Friend_list_w, getResY() - Reply_box_h - Padding, getResX() - Friend_list_w, Reply_box_h + Padding)
		love.graphics.setColor(70/255, 70/255, 70/255)
		love.graphics.rectangle("fill", Friend_list_w + Padding, getResY() - Padding - Reply_box_h, getResX() - Friend_list_w - Padding*2, Reply_box_h, 5)
		
		love.graphics.setColor(1, 1, 1)
		
		if L.story.replies then -- Show reply options --
			
			if not typed_reply then
				if L.story.question then
					printF(L.story.question, Friend_list_w + Padding*3/2, getResY() - Padding - Reply_box_h/2)
					x = Main_font:getWidth(L.story.question)/Scale + Padding
				else
					x = 0
				end
				
				for index, this in pairs (L.story.replies) do
					
					-- hand cursor
					if isWithin(mx, my, Friend_list_w + Padding*2 + x, getResY() - Padding - Reply_box_h/2 - Font_size/2, Main_font:getWidth(this.short)/Scale, Font_size) then
						love.mouse.setCursor(Cursor.hand)
						selected_reply = index
					end
					
					-- selected reply underline
					if selected_reply == index then
						love.graphics.line(Friend_list_w + Padding*2 + x, getResY() - Padding - Reply_box_h/2 + Font_size * Scale / 2, Friend_list_w + Padding*2 + x + Main_font:getWidth(this.short) / Scale, getResY() - Padding - Reply_box_h/2 + Font_size * Scale / 2)
					end
					
					printF(this.short, Friend_list_w + Padding*2 + x, getResY() - Padding - Reply_box_h/2)
					
					x = x + Main_font:getWidth(this.short)/Scale + Padding
					
				end
				
			else -- Show typed text --
				
				printF(string.sub(L.story.replies[typed_reply].long, 1, type_prog), Friend_list_w + Padding*3/2, getResY() - Padding - Reply_box_h/2)
				
				-- send button --
				if isWithin(mx, my, getResX() - Padding*3/2 - Img.ui.send:getWidth(), getResY() - Padding - Reply_box_h/2 - Img.ui.send:getHeight()/2, Img.ui.send:getWidth(), Img.ui.send:getHeight()) then
					love.mouse.setCursor(Cursor.hand)
					love.graphics.setColor(0, 0, 0, 0.1)
					love.graphics.rectangle("fill", getResX() - Padding*3/2 - Img.ui.send:getWidth(), getResY() - Padding - Reply_box_h/2 - Img.ui.send:getHeight()/2, Img.ui.send:getWidth(), Img.ui.send:getHeight())
				end
				love.graphics.setColor(1, 1, 1, 0.7)
				love.graphics.draw(Img.ui.send, getResX() - Padding*3/2 - Img.ui.send:getWidth(), getResY() - Padding - Reply_box_h/2 - Img.ui.send:getHeight()/2)
				
				-- backspace button --
				if isWithin(mx, my, getResX() - Padding*2 - Img.ui.backspace:getWidth() - Img.ui.x:getWidth(), getResY() - Padding - Reply_box_h/2 - Img.ui.backspace:getHeight()/2, Img.ui.backspace:getWidth(), Img.ui.backspace:getHeight()) then
					love.mouse.setCursor(Cursor.hand)
					love.graphics.setColor(0, 0, 0, 0.1)
					love.graphics.rectangle("fill", getResX() - Padding*2 - Img.ui.backspace:getWidth() - Img.ui.x:getWidth(), getResY() - Padding - Reply_box_h/2 - Img.ui.backspace:getHeight()/2, Img.ui.backspace:getWidth(), Img.ui.backspace:getHeight())
				end
				love.graphics.setColor(1, 1, 1, 0.7)
				love.graphics.draw(Img.ui.backspace, getResX() - Padding*2 - Img.ui.backspace:getWidth() - Img.ui.x:getWidth(), getResY() - Padding - Reply_box_h/2 - Img.ui.backspace:getHeight()/2)
				
			end
			
		end
		
		-- typing --
		if L.story.is_typing then
			love.graphics.setColor(1, 1, 1, 0.8)
			printF(L.story.is_typing.name.." is typing...", Friend_list_w + Padding, getResY() - Padding/2)
		end
		
		-- scroll bar --
		if max_scroll < 0 then
			love.graphics.setColor(50/255, 50/255, 50/255)
			h = (getResY() - Reply_box_h - Padding - Scroll_bar_h) * (scroll / max_scroll)
			love.graphics.rectangle("fill", getResX() - 15, h, 10, Scroll_bar_h)
		end
		
	end
	
	if show_profile_settings then
		
		love.graphics.setColor(40/255, 40/255, 40/255)
		
		love.graphics.rectangle("fill", getResX()/2 - Profile_settings_w/2, getResY()/2 - Profile_settings_h/2, Profile_settings_w, Profile_settings_h, 5)
		
		-- profile pic
		if profile_pic then
			love.graphics.setColor(1, 1, 1)
			love.graphics.draw(profile_pic, getResX()/2 - Profile_settings_w/2 + 25, getResY()/2 - 100/2, 0, 100 / profile_pic:getWidth(), 100 / profile_pic:getHeight())
		else
			love.graphics.setColor(60/255, 60/255, 60/255)
			love.graphics.rectangle("fill", getResX()/2 - Profile_settings_w/2 + 25, getResY()/2 - 100/2, 100, 100)
			love.graphics.setColor(40/255, 40/255, 40/255)
			love.graphics.draw(Img.ui.default_profile, getResX()/2 - Profile_settings_w/2 + 25, getResY()/2 - 100/2)
			love.graphics.setColor(1, 1, 1)
			love.graphics.setFont(Main_font)
			love.graphics.printf("Drag an image file here if you want", getResX()/2 - Profile_settings_w/2 + 25, getResY()/2 - 100/2, 100, "center")
		end
		
		-- username text box
		love.graphics.setColor(60/255, 60/255, 60/255)
		love.graphics.rectangle("fill", getResX()/2 - 50, getResY()/2 - 100/2, Profile_settings_w - 50 - 100 - 25, Font_size*2)
		
		if #username > 0 then
			love.graphics.setColor(1, 1, 1)
			printF(username, getResX()/2 - 50 + 10, getResY()/2 - 100/2 + Font_size)
		else
			love.graphics.setColor(1, 1, 1, 0.7)
			printF("username", getResX()/2 - 50 + 10, getResY()/2 - 100/2 + Font_size)
		end
		if caret_show then
			love.graphics.rectangle("fill", getResX()/2 - 50 + 11 + Main_font:getWidth(username) / Scale, getResY()/2 - 100/2 + Font_size/2, 1, Font_size)
		end
		
		-- start button
		love.graphics.setColor(60/255, 60/255, 60/255)
		love.graphics.rectangle("fill", getResX()/2 + Profile_settings_w/2 - 100 - 25, getResY()/2 + Profile_settings_h/2 - 30 - 25, 100, 30)
		if mx > getResX()/2 + Profile_settings_w/2 - 100 - 25 and mx < getResX()/2 + Profile_settings_w/2 - 100 - 25 + 100 and my > getResY()/2 + Profile_settings_h/2 - 30 - 25 and my < getResY()/2 + Profile_settings_h/2 - 30 - 25 + 30 then
			love.graphics.setColor(1, 1, 1)
		else
			love.graphics.setColor(1, 1, 1, 0.7)
		end
		printF("Play", getResX()/2 + Profile_settings_w/2 - 100/2 - 25 - Main_font:getWidth("Play")/2/Scale, getResY()/2 + Profile_settings_h/2 - 30/2 - 25)
		
	end
	
	-- Title Card --
	if title_tick < Title_time then
		
		love.graphics.setColor(0, 0, 0, math.min((Title_time - title_tick)*3 / Title_time, 1))
		love.graphics.rectangle("fill", 0, 0, getResX(), getResY())
		
		love.graphics.setColor(1, 1, 1, math.min((Title_time - title_tick)*3 / Title_time, 1))
		love.graphics.setFont(Title_font)
		
		if title_text then
			love.graphics.print(title_text, getResX()/2 - Title_font:getWidth(title_text)/2, getResY()/2 - Title_font_size/2)
		end
		
		if title_sub_text then
			love.graphics.printf(title_sub_text, 0, getResY()/2 + Title_font_size/2 * 2, getResX() * 2, "center", 0, 0.5, 0.5)
		end
		
	end
	
end

function update(dt)
	
	-- Caret --
	caret_tick = caret_tick + dt
	if caret_tick > Caret_speed then
		caret_tick = caret_tick - Caret_speed
		caret_show = not caret_show
	end
	
	-- Title Card --
	if title_tick < Title_time then
		title_tick = title_tick + dt
		
		if title_tick >= Title_time then
			L.story.next()
		end
	end
	
	if show_chat then
		
		if typed_reply then
			type_tick = type_tick + dt * Type_speed
			if type_tick >= 1 then
				
				type_tick = type_tick - 1
				
				if not backspacing then
					
					if type_prog < #L.story.replies[typed_reply].long then
						
						type_prog = math.min(type_prog + 1, #L.story.replies[typed_reply].long)
						
						type_sound_tick = type_sound_tick - dt
						if type_sound_tick <= 0 then
							type_sound_tick = math.random(1, 10) / 150
							playKeyboardSound()
						end
						
					end
					
				else
					
					
					if type_prog > 0 then
						type_prog = math.max(type_prog - 1, 0)
					else
						typed_reply = nil
						Sound.key_release:stop()
						Sound.key_release:play()
					end
					
				end
				
			end
		end
		
		if auto_scrolling then
			
			if scroll == max_scroll then
				auto_scrolling = false
			else
				scroll = math.max(scroll - dt * Auto_scroll_speed, max_scroll)
			end
			
		end
		
	end
	
end

-- Calc Functions --
Calc = {}

function Calc.max_scroll()
	
	local y = 0
	local last_user
	for index_msg, this_msg in pairs (L.story.chat_log) do
		
		if last_user ~= this_msg.user then
			
			y = y + 1
			
			y = y + 1
			
		end
		
		local x = 0
		if this_msg.text then
			for index_word, this_word in pairs (this_msg.text) do
				
				if x + Main_font:getWidth(this_word)/Scale > getResX() - Friend_list_w - Padding*5/2 - Profile_size then
					y = y + 1
					x = 0
				end
				x = x + Main_font:getWidth(this_word.." ")/Scale
				
			end
			
			y = y + 1
		end
		
		if this_msg.img then
			
			y = y + math.ceil(this_msg.img:getHeight() / Text_spacing) + 1
			
		end
		
		last_user = this_msg.user
		
	end
	
	max_scroll = -y * Text_spacing + getResY() - Reply_box_h - Padding*2
	
end


-- Input Functions --

function mousepressed(mx_true, my_true, button)
	
	local mx = (mx_true - getCamX()) / Scale
	local my = (my_true - getCamY()) / Scale
	
	if show_profile_settings then
		
		if mx > getResX()/2 + Profile_settings_w/2 - 100 - 25 and mx < getResX()/2 + Profile_settings_w/2 - 100 - 25 + 100 and my > getResY()/2 + Profile_settings_h/2 - 30 - 25 and my < getResY()/2 + Profile_settings_h/2 - 30 - 25 + 30 then
			
			L.story.loadStory(selected_story, username, profile_pic)
			
			show_profile_settings = false
			show_chat = true
			
		end
		
		return true
		
	end
	
	if show_chat then
		
		if button == 1 then
			
			-- friends list --
			-- if mx > Padding/2 and mx < Friend_list_w then
			-- 	local y = 0
			-- 	for index, this in pairs (L.story.chats) do
			-- 		if this.visible then
			-- 			y = y + 1
			-- 			if my >= (y-1) * 50 - 25 + Padding*3 and my < (y-1) * 50 + 25 + Padding*3 then
			-- 				chat_open = index
			-- 				Calc.max_scroll()
			-- 				scroll = max_scroll
							
			-- 				return true
			-- 			end
			-- 		end
			-- 	end
			-- end
			
			if L.story.replies then
				
				if not typed_reply then
					
					-- reply box --
					local x
					if L.story.question then
						x = Main_font:getWidth(L.story.question)/Scale + Padding
					else
						x = 0
					end
					for index, this in pairs (L.story.replies) do
						
						if isWithin(mx, my, Friend_list_w + Padding*2 + x, getResY() - Padding - Reply_box_h/2 - Font_size/2, Main_font:getWidth(this.short)/Scale, Font_size) then
							
							selectReply(index)
							
							return true
							
						end
						x = x + Main_font:getWidth(this.short)/Scale + Padding
						
					end
				
				else
					
					-- send button --
					if isWithin(mx, my, getResX() - Padding*3/2 - Img.ui.send:getWidth(), getResY() - Padding - Reply_box_h/2 - Img.ui.send:getHeight()/2, Img.ui.send:getWidth(), Img.ui.send:getHeight()) then
						
						sendReply()
						
						return true
						
					end
					
					-- delete msg button --
					if isWithin(mx, my, getResX() - Padding*2 - Img.ui.send:getWidth() - Img.ui.x:getWidth(), getResY() - Padding - Reply_box_h/2 - Img.ui.send:getHeight()/2, Img.ui.send:getWidth(), Img.ui.send:getHeight()) then
						
						backspaceReply()
						
						return true
						
					end
					
				end
				
				
			end
			
		end
		
	end
	
end

-- function mousereleased(mx_true, my_true, button)
	
	-- mx = (mx_true - getCamX()) / Scale
	-- my = (my_true - getCamY()) / Scale
	
	-- if button == 1 then
		
		
		
	-- end
	
-- end


function wheelmoved(x, y)
	
	if show_chat then
		
		Calc.max_scroll()
		scroll = math.max(math.min(scroll + y * 30, 0), max_scroll)
		
	end
	
end


function resize(w, h)
	
	if show_chat then
		
		if scroll == max_scroll then
			Calc.max_scroll()
			scroll = max_scroll
		else
			Calc.max_scroll()
			scroll = math.max(math.min(scroll, 0), max_scroll)
		end
		
	end
	
	
end


function keypressed(key)
	
	if show_profile_settings then
		
		love.keyboard.setKeyRepeat(true)
		
		if key == "backspace" then
			username = string.sub(username, 1, #username - 1)
		elseif key == "return" then
			L.story.loadStory(selected_story, username, profile_pic)
			
			show_profile_settings = false
			show_chat = true
		end
		
		return true
		
	end
	
	if show_chat then
		
		--DEBUG
		if key == "space" then
			L.story.next()
		end
		
		love.keyboard.setKeyRepeat(false)
		
		if L.story.replies then
			
			if not typed_reply then
				
				-- reply choices --
				if key == L.settings.key_ui_right then
					if selected_reply < #L.story.replies then
						selected_reply = selected_reply + 1
						playKeyboardSound()
						return true
					end
				elseif key == L.settings.key_ui_left then
					if selected_reply > 1 then
						selected_reply = math.max(selected_reply - 1, 1)
						playKeyboardSound()
						return true
					end
				elseif key == L.settings.key_ui_enter then
					selectReply(selected_reply)
					return true
				end
				
			else
				
				-- reply preview --
				if key == L.settings.key_ui_enter then
					sendReply()
					return true
				elseif key == L.settings.key_ui_backspace then
					backspaceReply()
					return true
				end
				
			end
			
		end
		
	end
	
end


function textinput(text)
	
	if show_profile_settings then
		
		username = username .. text
		
		return true
		
	end
	
end


function filedropped(file)
	
	local file_name = string.lower(file:getFilename())
	if string.sub(file_name, #file_name - 3) == ".png" or string.sub(file_name, #file_name - 3) == ".bmp" or string.sub(file_name, #file_name - 3) == ".tga" or string.sub(file_name, #file_name - 3) == ".jpg" or string.sub(file_name, #file_name - 4) == ".jpeg" then
		profile_pic = love.graphics.newImage(file)
	end
	
end


-- Common Functions

function selectReply(index)
	typed_reply = index
	type_prog = 0
	type_tick = 0
	type_sound_tick = 0
	backspacing = false
end

function sendReply()
	
	local choice = L.story.replies[typed_reply]
	
	sendMessage(L.story.me, string.split(choice.long, " "))
	
	Sound.key_enter:stop()
	Sound.key_enter:play()
	
	local command = L.story.replies[typed_reply].command
	
	selected_reply = 1
	typed_reply = nil
	L.story.Command["erase"]()
	
	L.story.interpret(command)
	
end

function sendMessage(user, msg, img)
	
	table.insert(L.story.chat_log, {user = user, text = msg, img = img})
	-- Calc.max_scroll()
	
	if auto_scrolling or scroll == max_scroll then
		Calc.max_scroll()
		auto_scrolling = true
	else
		Calc.max_scroll()
		scroll = math.max(math.min(scroll, 0), max_scroll)
	end
	
	if user ~= L.story.me then
		Sound.chat:stop()
		Sound.chat:play()
	end
	
end

function backspaceReply()
	backspacing = true
	type_tick = -15 -- for keyboard repeat realism
	type_prog = math.max(type_prog - 1, 0)
	Sound.key_hold:stop()
	Sound.key_hold:play()
end

function playKeyboardSound()
	
	local r = math.random(1,3)
	Sound["key_click_"..r]:stop()
	Sound["key_click_"..r]:play()
	
end


-- Helper Functions

function getCamX()
	return 0
end
function getCamY()
	return 0
end
function getResX()
	return love.graphics.getWidth() / Scale
end
function getResY()
	return love.graphics.getHeight() / Scale
end

function isWithin(xc, yc, x, y, w, h)
	if xc > x and xc < x + w and yc > y and yc < y + h then
		return true
	end
	return false
end

function printF(text, x, y)
	love.graphics.print(text, x, y, 0, 1/Scale, 1/Scale, 0, Main_font:getHeight()/2)
	-- print(text)
end


return P
