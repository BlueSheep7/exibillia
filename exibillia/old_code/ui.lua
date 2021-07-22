-- UI --
-- RWL --

ui = {}
ui.libname = "ui"

drawable_add(ui, "ui", 1)
ui.interactorder = 1

-- Constants --
ui.font_size = 15
ui.profile_size = 40
ui.padding = 30
ui.friend_list_w = 250
ui.reply_box_h = 50
ui.text_spacing = ui.font_size + 10
ui.scroll_bar_h = 150
ui.type_speed = 60 -- characters per second
ui.auto_scroll_speed = 1000
ui.caret_speed = 0.5
ui.caret_tick = 0
ui.caret_show = true
ui.profile_settings_w = 400
ui.profile_settings_h = 150


-- ui.fallback_font = love.graphics.newFont("fonts/YasashisaGothicBold-V2.otf", 24)
-- ui.font:setFallbacks(ui.fallback_font)

ui.cursor = {}
ui.cursor.arrow = love.mouse.getSystemCursor("arrow")
ui.cursor.hand = love.mouse.getSystemCursor("hand")

love.graphics.setBackgroundColor(60/255, 60/255, 60/255)


-- is run whenever scale is changed
function ui.createUI()
	
	ui.font = love.graphics.newFont(ui.font_size * settings.ui_scale)
	
end

function ui.load()
	
	ui.chat_open = 1
	ui.scroll = 0
	ui.max_scroll = 0
	ui.type_tick = 0
	ui.type_prog = 0
	ui.backspacing = false
	ui.auto_scrolling = false
	ui.type_sound_tick = 0
	ui.selected_reply = 1
	
	ui.show_chat = false
	ui.show_profile_settings = true
	
	ui.username = ""
	
	ui.selected_story = "test2"
	
end


function ui.draw(layer)
	
	
	love.graphics.origin()
	love.graphics.setColor(60/255, 60/255, 60/255)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	-- love.graphics.translate(ui.getCamX(), ui.getCamY())
	love.graphics.scale(ui.getScale())
	
	love.graphics.setFont(ui.font)
	
	love.mouse.setCursor(ui.cursor.arrow)
	mx = (love.mouse.getX() - ui.getCamX()) / ui.getScale()
	my = (love.mouse.getY() - ui.getCamY()) / ui.getScale()
	
	
	if ui.show_chat then
		
		-- Friends List --
		
		love.graphics.setColor(50/255, 50/255, 50/255)
		love.graphics.rectangle("fill", 0, 0, ui.friend_list_w, ui.getResY())
		
		love.graphics.setColor(1, 1, 1)
		ui.print("Friends", ui.padding, ui.padding)
		
		local y = 0
		for index, this in pairs (this_story.chats) do
			if this.visible then
				
				y = y + 1
				
				love.graphics.setColor(50/255, 50/255, 50/255)
				if ui.chat_open == index then
					love.graphics.setColor(60/255, 60/255, 60/255)
					love.graphics.rectangle("fill", ui.padding/2, (y-1) * 50 - 25 + ui.padding*3, ui.friend_list_w - ui.padding/2, 50)
				elseif mx > ui.padding/2 and mx < ui.friend_list_w and my >= (y-1) * 50 - 25 + ui.padding*3 and my < (y-1) * 50 + 25 + ui.padding*3 then
					love.graphics.setColor(57/255, 57/255, 57/255)
					love.graphics.rectangle("fill", ui.padding/2, (y-1) * 50 - 25 + ui.padding*3, ui.friend_list_w - ui.padding/2, 50)
				end
				
				local r, g, b, a = love.graphics.getColor()
				
				love.graphics.setColor(1, 1, 1)
				if this.name then
					ui.print(this.name, ui.padding + ui.profile_size + 5, (y-1) * 50 + ui.padding*3)
				else
					ui.print(this_story.users[this.users[1]].name, ui.padding + ui.profile_size + 5, (y-1) * 50 + ui.padding*3)
				end
				
				love.graphics.setColor(1, 1, 1)
				local pp
				if this.pic then
					pp = story.img[this.pic]
				elseif this_story.users[this.users[1]].pic then
					pp = story.img[this_story.users[this.users[1]].pic]
				else
					pp = img.ui.default_profile
				end
				love.graphics.draw(pp, ui.padding, (y-1) * 50 + ui.padding*3, 0, ui.profile_size / pp:getWidth(), ui.profile_size / pp:getHeight(), 0, pp:getHeight()/2)

				love.graphics.setColor(r, g, b)
				love.graphics.draw(img.ui.profile_border, ui.padding, (y-1) * 50 + ui.padding*3, 0, ui.profile_size / img.ui.profile_border:getWidth(), ui.profile_size / img.ui.profile_border:getHeight(), 0, img.ui.profile_border:getHeight()/2)
				
			end
		end
		
		
		-- Chat --
		
		if ui.chat_open > 0 and ui.chat_open <= #this_story.chats then
			
			-- messages --
			local y = 0
			local last_user = -1
			for index_msg, this_msg in pairs (this_story.chats[ui.chat_open].msg) do
				
				if last_user ~= this_msg.user then
					
					y = y + 1
					
					if this_msg.user then
						love.graphics.setColor(1, 1, 1)
						local pp
						if this_story.users[this_msg.user].pic then
							pp = story.img[this_story.users[this_msg.user].pic]
						else
							pp = img.ui.default_profile
						end
						love.graphics.draw(pp, ui.friend_list_w + ui.padding, y * ui.text_spacing + ui.scroll + ui.padding - ui.font_size/2, 0, ui.profile_size / pp:getWidth(), ui.profile_size / pp:getHeight(), 0, 0)
						
						love.graphics.setColor(60/255, 60/255, 60/255)
						love.graphics.draw(img.ui.profile_border, ui.friend_list_w + ui.padding, y * ui.text_spacing + ui.scroll + ui.padding - ui.font_size/2, 0, ui.profile_size / img.ui.profile_border:getWidth(), ui.profile_size / img.ui.profile_border:getHeight(), 0, 0)
						
						love.graphics.setColor(1, 1, 1)
						ui.print(this_story.users[this_msg.user].name, ui.friend_list_w + ui.padding*3/2 + ui.profile_size, y * ui.text_spacing + ui.scroll + ui.padding)
					end
					
					y = y + 1
					
				end
				
				local x = 0
				if this_msg.text then
					love.graphics.setColor(1, 1, 1)
					for index_word, this_word in pairs (this_msg.text) do
						
						if x + ui.font:getWidth(this_word)/settings.ui_scale > ui.getResX() - ui.friend_list_w - ui.padding*5/2 - ui.profile_size then
							y = y + 1
							x = 0
						end
						ui.print(this_word, ui.friend_list_w + ui.padding*3/2 + ui.profile_size + x, y * ui.text_spacing + ui.scroll + ui.padding)
						x = x + ui.font:getWidth(this_word.." ")/settings.ui_scale
						
					end
					
					y = y + 1
				end
				
				if this_msg.img then
					
					love.graphics.draw(story.img[this_msg.img], ui.friend_list_w + ui.padding*3/2 + ui.profile_size, y * ui.text_spacing + ui.scroll + ui.padding)
					y = y + math.ceil(story.img[this_msg.img]:getHeight() / ui.text_spacing) + 1
					
				end
				
				last_user = this_msg.user
				
			end
			
			-- reply box --
			love.graphics.setColor(60/255, 60/255, 60/255)
			love.graphics.rectangle("fill", ui.friend_list_w, ui.getResY() - ui.reply_box_h - ui.padding, ui.getResX() - ui.friend_list_w, ui.reply_box_h + ui.padding)
			love.graphics.setColor(70/255, 70/255, 70/255)
			love.graphics.rectangle("fill", ui.friend_list_w + ui.padding, ui.getResY() - ui.padding - ui.reply_box_h, ui.getResX() - ui.friend_list_w - ui.padding*2, ui.reply_box_h, 5)
			
			love.graphics.setColor(1, 1, 1)
			
			if this_story.chats[ui.chat_open].reply then -- Show reply options --
				
				if not this_story.chats[ui.chat_open].reply_choice then
					if this_story.chats[ui.chat_open].question then
						ui.print(this_story.chats[ui.chat_open].question, ui.friend_list_w + ui.padding*3/2, ui.getResY() - ui.padding - ui.reply_box_h/2)
						x = ui.font:getWidth(this_story.chats[ui.chat_open].question)/settings.ui_scale + ui.padding
					else
						x = 0
					end
					
					for index, this in pairs (this_story.chats[ui.chat_open].reply) do
						
						-- hand cursor
						if ui.isWithin(mx, my, ui.friend_list_w + ui.padding*2 + x, ui.getResY() - ui.padding - ui.reply_box_h/2 - ui.font_size/2, ui.font:getWidth(this.short)/settings.ui_scale, ui.font_size) then
							love.mouse.setCursor(ui.cursor.hand)
							ui.selected_reply = index
						end
						
						-- selected reply underline
						if ui.selected_reply == index then
							love.graphics.line(ui.friend_list_w + ui.padding*2 + x, ui.getResY() - ui.padding - ui.reply_box_h/2 + ui.font_size * settings.ui_scale / 2, ui.friend_list_w + ui.padding*2 + x + ui.font:getWidth(this.short) / settings.ui_scale, ui.getResY() - ui.padding - ui.reply_box_h/2 + ui.font_size * settings.ui_scale / 2)
						end
						
						ui.print(this.short, ui.friend_list_w + ui.padding*2 + x, ui.getResY() - ui.padding - ui.reply_box_h/2)
						
						x = x + ui.font:getWidth(this.short)/settings.ui_scale + ui.padding
						
					end
					
				else -- Show typed text --
					
					ui.print(string.sub(this_story.chats[ui.chat_open].reply[this_story.chats[ui.chat_open].reply_choice].long, 1, ui.type_prog), ui.friend_list_w + ui.padding*3/2, ui.getResY() - ui.padding - ui.reply_box_h/2)
					
					-- send button --
					if ui.isWithin(mx, my, ui.getResX() - ui.padding*3/2 - img.ui.send:getWidth(), ui.getResY() - ui.padding - ui.reply_box_h/2 - img.ui.send:getHeight()/2, img.ui.send:getWidth(), img.ui.send:getHeight()) then
						love.mouse.setCursor(ui.cursor.hand)
						love.graphics.setColor(0, 0, 0, 0.1)
						love.graphics.rectangle("fill", ui.getResX() - ui.padding*3/2 - img.ui.send:getWidth(), ui.getResY() - ui.padding - ui.reply_box_h/2 - img.ui.send:getHeight()/2, img.ui.send:getWidth(), img.ui.send:getHeight())
					end
					love.graphics.setColor(1, 1, 1, 0.7)
					love.graphics.draw(img.ui.send, ui.getResX() - ui.padding*3/2 - img.ui.send:getWidth(), ui.getResY() - ui.padding - ui.reply_box_h/2 - img.ui.send:getHeight()/2)
					
					-- backspace button --
					if ui.isWithin(mx, my, ui.getResX() - ui.padding*2 - img.ui.backspace:getWidth() - img.ui.x:getWidth(), ui.getResY() - ui.padding - ui.reply_box_h/2 - img.ui.backspace:getHeight()/2, img.ui.backspace:getWidth(), img.ui.backspace:getHeight()) then
						love.mouse.setCursor(ui.cursor.hand)
						love.graphics.setColor(0, 0, 0, 0.1)
						love.graphics.rectangle("fill", ui.getResX() - ui.padding*2 - img.ui.backspace:getWidth() - img.ui.x:getWidth(), ui.getResY() - ui.padding - ui.reply_box_h/2 - img.ui.backspace:getHeight()/2, img.ui.backspace:getWidth(), img.ui.backspace:getHeight())
					end
					love.graphics.setColor(1, 1, 1, 0.7)
					love.graphics.draw(img.ui.backspace, ui.getResX() - ui.padding*2 - img.ui.backspace:getWidth() - img.ui.x:getWidth(), ui.getResY() - ui.padding - ui.reply_box_h/2 - img.ui.backspace:getHeight()/2)
					
				end
				
			end
			
			-- typing --
			if this_story.chats[ui.chat_open].is_typing then
				love.graphics.setColor(1, 1, 1, 0.8)
				ui.print(this_story.users[this_story.chats[ui.chat_open].is_typing].name.." is typing...", ui.friend_list_w + ui.padding, ui.getResY() - ui.padding/2)
			end
			
			-- scroll bar --
			if ui.max_scroll < 0 then
				love.graphics.setColor(50/255, 50/255, 50/255)
				h = (ui.getResY() - ui.reply_box_h - ui.padding - ui.scroll_bar_h) * (ui.scroll / ui.max_scroll)
				love.graphics.rectangle("fill", ui.getResX() - 15, h, 10, ui.scroll_bar_h)
			end
			
		end
		
	end
	
	if ui.show_profile_settings then
		
		love.graphics.setColor(40/255, 40/255, 40/255)
		
		love.graphics.rectangle("fill", ui.getResX()/2 - ui.profile_settings_w/2, ui.getResY()/2 - ui.profile_settings_h/2, ui.profile_settings_w, ui.profile_settings_h, 5)
		
		-- profile pic
		if ui.profile_pic then
			love.graphics.setColor(1, 1, 1)
			love.graphics.draw(ui.profile_pic, ui.getResX()/2 - ui.profile_settings_w/2 + 25, ui.getResY()/2 - 100/2, 0, 100 / ui.profile_pic:getWidth(), 100 / ui.profile_pic:getHeight())
		else
			love.graphics.setColor(60/255, 60/255, 60/255)
			love.graphics.rectangle("fill", ui.getResX()/2 - ui.profile_settings_w/2 + 25, ui.getResY()/2 - 100/2, 100, 100)
			love.graphics.setColor(40/255, 40/255, 40/255)
			love.graphics.draw(img.ui.default_profile, ui.getResX()/2 - ui.profile_settings_w/2 + 25, ui.getResY()/2 - 100/2)
		end
		
		-- username text box
		love.graphics.setColor(60/255, 60/255, 60/255)
		love.graphics.rectangle("fill", ui.getResX()/2 - 50, ui.getResY()/2 - 100/2, ui.profile_settings_w - 50 - 100 - 25, ui.font_size*2)
		
		if #ui.username > 0 then
			love.graphics.setColor(1, 1, 1)
			ui.print(ui.username, ui.getResX()/2 - 50 + 10, ui.getResY()/2 - 100/2 + ui.font_size)
		else
			love.graphics.setColor(1, 1, 1, 0.7)
			ui.print("username", ui.getResX()/2 - 50 + 10, ui.getResY()/2 - 100/2 + ui.font_size)
		end
		if ui.caret_show then
			love.graphics.rectangle("fill", ui.getResX()/2 - 50 + 11 + ui.font:getWidth(ui.username) / settings.ui_scale, ui.getResY()/2 - 100/2 + ui.font_size/2, 1, ui.font_size)
		end
		
		-- start button
		love.graphics.setColor(60/255, 60/255, 60/255)
		love.graphics.rectangle("fill", ui.getResX()/2 + ui.profile_settings_w/2 - 100 - 25, ui.getResY()/2 + ui.profile_settings_h/2 - 30 - 25, 100, 30)
		if mx > ui.getResX()/2 + ui.profile_settings_w/2 - 100 - 25 and mx < ui.getResX()/2 + ui.profile_settings_w/2 - 100 - 25 + 100 and my > ui.getResY()/2 + ui.profile_settings_h/2 - 30 - 25 and my < ui.getResY()/2 + ui.profile_settings_h/2 - 30 - 25 + 30 then
			love.graphics.setColor(1, 1, 1)
		else
			love.graphics.setColor(1, 1, 1, 0.7)
		end
		ui.print("Play", ui.getResX()/2 + ui.profile_settings_w/2 - 100/2 - 25 - ui.font:getWidth("Play")/2/settings.ui_scale, ui.getResY()/2 + ui.profile_settings_h/2 - 30/2 - 25)
		
	end
	
end

function ui.update(dt)
	
	-- Caret --
	ui.caret_tick = ui.caret_tick + dt
	if ui.caret_tick > ui.caret_speed then
		ui.caret_tick = ui.caret_tick - ui.caret_speed
		ui.caret_show = not ui.caret_show
	end
	
	if ui.show_chat then
		
		if this_story.chats[ui.chat_open].reply_choice then
			ui.type_tick = ui.type_tick + dt * ui.type_speed
			if ui.type_tick >= 1 then
				
				ui.type_tick = ui.type_tick - 1
				
				if not ui.backspacing then
					
					if ui.type_prog < #this_story.chats[ui.chat_open].reply[this_story.chats[ui.chat_open].reply_choice].long then
						
						ui.type_prog = math.min(ui.type_prog + 1, #this_story.chats[ui.chat_open].reply[this_story.chats[ui.chat_open].reply_choice].long)
						
						ui.type_sound_tick = ui.type_sound_tick - dt
						if ui.type_sound_tick <= 0 then
							ui.type_sound_tick = math.random(1, 10) / 150
							ui.playKeyboardSound()
						end
						
					end
					
				else
					
					
					if ui.type_prog > 0 then
						ui.type_prog = math.max(ui.type_prog - 1, 0)
					else
						this_story.chats[ui.chat_open].reply_choice = nil
						sound.key_release:stop()
						sound.key_release:play()
					end
					
				end
				
			end
		end
		
		if ui.auto_scrolling then
			
			if ui.scroll == ui.max_scroll then
				ui.auto_scrolling = false
			else
				ui.scroll = math.max(ui.scroll - dt * ui.auto_scroll_speed, ui.max_scroll)
			end
			
		end
		
	end
	
end


-- Calc Functions --
ui.calc = {}

function ui.calc.max_scroll()
	
	y = 0
	last_user = -1
	for index_msg, this_msg in pairs (this_story.chats[ui.chat_open].msg) do
		
		if last_user ~= this_msg.user then
			
			y = y + 1
			y = y + 1
			
		end
		
		x = 0
		if this_msg.text then
			for index_word, this_word in pairs (this_msg.text) do
				
				if x + ui.font:getWidth(this_word)/settings.ui_scale > ui.getResX() - ui.friend_list_w - ui.padding*5/2 - ui.profile_size then
					y = y + 1
					x = 0
				end
				x = x + ui.font:getWidth(this_word.." ")/settings.ui_scale
				
			end
			y = y + 1
		end
		
		if this_msg.img then
			
			love.graphics.draw(story.img[this_msg.img], ui.friend_list_w + ui.padding*3/2 + ui.profile_size, y * ui.text_spacing + ui.scroll + ui.padding)
			y = y + math.ceil(story.img[this_msg.img]:getHeight() / ui.text_spacing) + 1
			
		end
		
		last_user = this_msg.user
		
	end
	
	ui.max_scroll = -y * ui.text_spacing + ui.getResY() - ui.reply_box_h - ui.padding*2
	
	-- ui.scroll = math.max(math.min(ui.scroll + y * 30, 0), ui.max_scroll)
	
end


-- Input Functions --

function ui.mousepressed(mx_true, my_true, button)
	
	mx = (mx_true - ui.getCamX()) / ui.getScale()
	my = (my_true - ui.getCamY()) / ui.getScale()
	
	if ui.show_profile_settings then
		
		if mx > ui.getResX()/2 + ui.profile_settings_w/2 - 100 - 25 and mx < ui.getResX()/2 + ui.profile_settings_w/2 - 100 - 25 + 100 and my > ui.getResY()/2 + ui.profile_settings_h/2 - 30 - 25 and my < ui.getResY()/2 + ui.profile_settings_h/2 - 30 - 25 + 30 then
			
			story.loadStory(ui.selected_story, ui.username, ui.profile_pic)
			
			ui.show_profile_settings = false
			ui.show_chat = true
			
		end
		
		return true
		
	end
	
	if ui.show_chat then
		
		if button == 1 then
			
			-- friends list --
			if mx > ui.padding/2 and mx < ui.friend_list_w then
				y = 0
				for index, this in pairs (this_story.chats) do
					if this.visible then
						y = y + 1
						if my >= (y-1) * 50 - 25 + ui.padding*3 and my < (y-1) * 50 + 25 + ui.padding*3 then
							ui.chat_open = index
							ui.calc.max_scroll()
							ui.scroll = ui.max_scroll
							
							return true
						end
					end
				end
			end
			
			if this_story.chats[ui.chat_open].reply then
				if not this_story.chats[ui.chat_open].reply_choice then
					
					-- reply box --
					if this_story.chats[ui.chat_open].question then
						x = ui.font:getWidth(this_story.chats[ui.chat_open].question)/settings.ui_scale + ui.padding
					else
						x = 0
					end
					for index, this in pairs (this_story.chats[ui.chat_open].reply) do
						
						if ui.isWithin(mx, my, ui.friend_list_w + ui.padding*2 + x, ui.getResY() - ui.padding - ui.reply_box_h/2 - ui.font_size/2, ui.font:getWidth(this.short)/settings.ui_scale, ui.font_size) then
							
							ui.selectReply(index)
							
							return true
							
						end
						x = x + ui.font:getWidth(this.short)/settings.ui_scale + ui.padding
						
					end
				
				else
					
					-- send button --
					if ui.isWithin(mx, my, ui.getResX() - ui.padding*3/2 - img.ui.send:getWidth(), ui.getResY() - ui.padding - ui.reply_box_h/2 - img.ui.send:getHeight()/2, img.ui.send:getWidth(), img.ui.send:getHeight()) then
						
						ui.sendReply()
						
						return true
						
					end
					
				end
			end
			
			-- delete msg button --
			if ui.isWithin(mx, my, ui.getResX() - ui.padding*2 - img.ui.send:getWidth() - img.ui.x:getWidth(), ui.getResY() - ui.padding - ui.reply_box_h/2 - img.ui.send:getHeight()/2, img.ui.send:getWidth(), img.ui.send:getHeight()) then
				
				ui.backspaceReply()
				
				return true
				
			end
			
		end
		
	end
	
end

-- function ui.mousereleased(mx_true, my_true, button)
	
	-- mx = (mx_true - ui.getCamX()) / ui.getScale()
	-- my = (my_true - ui.getCamY()) / ui.getScale()
	
	-- if button == 1 then
		
		
		
	-- end
	
-- end


function ui.wheelmoved(x, y)
	
	if ui.show_chat then
		
		ui.calc.max_scroll()
		ui.scroll = math.max(math.min(ui.scroll + y * 30, 0), ui.max_scroll)
		
	end
	
end


function love.resize(w, h)
	
	if ui.show_chat then
		
		if ui.scroll == ui.max_scroll then
			ui.calc.max_scroll()
			ui.scroll = ui.max_scroll
		else
			ui.calc.max_scroll()
			ui.scroll = math.max(math.min(ui.scroll, 0), ui.max_scroll)
		end
		
	end
	
	
end


function ui.keypressed(key)
	
	if ui.show_profile_settings then
		
		love.keyboard.setKeyRepeat(true)
		
		if key == "backspace" then
			ui.username = string.sub(ui.username, 1, #ui.username - 1)
		end
		
		return true
		
	end
	
	if ui.show_chat then
		
		love.keyboard.setKeyRepeat(false)
		
		if this_story.chats[ui.chat_open].reply then
			
			if not this_story.chats[ui.chat_open].reply_choice then
				
				-- reply choices --
				if key == settings.key_ui_right then
					if ui.selected_reply < #this_story.chats[ui.chat_open].reply then
						ui.selected_reply = ui.selected_reply + 1
						ui.playKeyboardSound()
						return true
					end
				elseif key == settings.key_ui_left then
					if ui.selected_reply > 1 then
						ui.selected_reply = math.max(ui.selected_reply - 1, 1)
						ui.playKeyboardSound()
						return true
					end
				elseif key == settings.key_ui_enter then
					ui.selectReply(ui.selected_reply)
					return true
				end
				
			else
				
				-- reply preview --
				if key == settings.key_ui_enter then
					ui.sendReply()
					return true
				elseif key == settings.key_ui_backspace then
					ui.backspaceReply()
					return true
				end
				
			end
			
		end
		
	end
	
end


function ui.textinput(text)
	
	if ui.show_profile_settings then
		
		ui.username = ui.username .. text
		
		return true
		
	end
	
end


function love.filedropped(file)
	
	local file_name = string.lower(file:getFilename())
	if string.sub(file_name, #file_name - 3) == ".png" or string.sub(file_name, #file_name - 3) == ".bmp" or string.sub(file_name, #file_name - 3) == ".tga" or string.sub(file_name, #file_name - 3) == ".jpg" or string.sub(file_name, #file_name - 4) == ".jpeg" then
		ui.profile_pic = love.graphics.newImage(file)
	end
	
end


-- Common Functions --

function ui.getCamX()
	return 0
end
function ui.getCamY()
	return 0
end
function ui.getScale()
	return settings.ui_scale
end
function ui.getResX()
	return love.graphics.getWidth() / settings.ui_scale
end
function ui.getResY()
	return love.graphics.getHeight() / settings.ui_scale
end

function ui.isWithin(xc, yc, x, y, w, h)
	if xc > x and xc < x + w and yc > y and yc < y + h then
		return true
	end
	return false
end

function ui.print(text, x, y)
	love.graphics.print(text, x, y, 0, 1/settings.ui_scale, 1/settings.ui_scale, 0, ui.font:getHeight()/2)
end

function ui.selectReply(index)
	this_story.chats[ui.chat_open].reply_choice = index
	ui.type_prog = 0
	ui.type_tick = 0
	ui.type_sound_tick = 0
	ui.backspacing = false
end

function ui.sendReply()
	
	choice = this_story.chats[ui.chat_open].reply[this_story.chats[ui.chat_open].reply_choice]
	
	if not choice.dont_send then
		
		ui.sendMessage("me", string.split(choice.long, " "))
		
		sound.key_enter:stop()
		sound.key_enter:play()
		
	end
	
	this_story.chats[ui.chat_open].reply_choice = nil
	this_story.chats[ui.chat_open].reply = nil
	
	story.progress(choice.path, choice.label)
	
end

function ui.sendMessage(user, msg, img, message_sound)
	
	table.insert(this_story.chats[ui.chat_open].msg, {user = user, text = msg, img = img})
	
	if ui.auto_scrolling or ui.scroll == ui.max_scroll then
		ui.calc.max_scroll()
		ui.auto_scrolling = true
	else
		ui.calc.max_scroll()
		ui.scroll = math.max(math.min(ui.scroll, 0), ui.max_scroll)
	end
	
	if message_sound then
		sound.chat:stop()
		sound.chat:play()
	end
	
end

function ui.backspaceReply()
	ui.backspacing = true
	ui.type_tick = -15
	ui.type_prog = math.max(ui.type_prog - 1, 0)
	sound.key_hold:stop()
	sound.key_hold:play()
end

function ui.playKeyboardSound()
	
	local r = math.random(1,3)
	sound["key_click_"..r]:stop()
	sound["key_click_"..r]:play()
	
end


return ui
