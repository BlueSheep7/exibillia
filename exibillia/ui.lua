-- GUI library thing by BlueSheep7 --


-- TODO:

-- touchscreen?
-- controller support
-- keyboard navigation
-- better individual element animation control
-- label text outline
-- better cursor hint edge of window detection
-- line width corrections

-- SAMPLE CODE: --
--[[
ui = require("ui")

function love.load()
	view = ui.view{w = love.graphics.getWidth(), h = love.graphics.getHeight(),
		ui.button{title = "test", x = 100, y = 100},
	}
	view:open()
end

function love.draw()
	ui.draw()
end

function love.update(dt)
	ui.update(dt)
end

function love.keypressed(key)
	ui.keypressed(key)
end

function love.mousepressed(mx, my, button)
	ui.mousepressed(mx, my, button)
end

function love.mousereleased(mx, my, button)
	ui.mousereleased(mx, my, button)
end

function love.textinput(text)
	ui.textinput(text)
end
]]


local P = {}

P.interact_weight = 0


-- Cursor --
local Cursor = {}
if love.mouse.isCursorSupported() then
	Cursor.arrow = love.mouse.getSystemCursor("arrow")
	Cursor.hand = love.mouse.getSystemCursor("hand")
	Cursor.ibeam = love.mouse.getSystemCursor("ibeam")
end
local Default_cursor = Cursor.arrow
local render_cursor, cursor_hint
local pressing, keyboard_focus


-- Fonts --
local menu_font = love.graphics.newFont(15) -- reload on scale change


-- UI Elements --
local E = {}

-- x, y, w, h, align, title, invisible, action(), font, cursor, hint
E.button = {features = {x = 0, y = 0, title = "", invisible = false, font = menu_font, cursor = "hand", can_focus = true,
	
	draw = function(self)
		if not self.enabled then return end
		local x, y = P.getAlignedCoords(self)
		local is_over = false
		if love.mouse.getX() > x - self.w/2 and love.mouse.getX() < x + self.w/2 and love.mouse.getY() > y - self.h/2 and love.mouse.getY() < y + self.h/2 then
			if self.cursor then
				render_cursor = Cursor[self.cursor]
			end
			if self.hint then
				cursor_hint = self.hint
			end
			is_over = true
		elseif keyboard_focus == self then
			is_over = true
		end
		if is_over then
			love.graphics.setColor(0.6, 0.6, 0.6)
		else
			love.graphics.setColor(0.8, 0.8, 0.8)
		end
		love.graphics.rectangle("fill", x - self.w/2, y - self.h/2, self.w, self.h)
		love.graphics.setColor(0, 0, 0)
		love.graphics.setFont(self.font)
		love.graphics.print(self.title, x - self.font:getWidth(self.title)/2, y - self.font:getHeight()/2)
	end,
	
	mouseEvent = function(self, args)
		if not self.enabled then return end
		if self.parent.tick ~= 1 then return end
		if args.button ~= 1 then return end
		local x, y = P.getAlignedCoords(self)
		if args.x > x - self.w/2 and args.x < x + self.w/2 and args.y > y - self.h/2 and args.y < y + self.h/2 then
			if args.isDown then
				pressing = self
				Sound.press:stop()
				Sound.press:play()
			elseif pressing == self then
				if self.action then
					self:action()
				end
				Sound.release:stop()
				Sound.release:play()
			end
			return true
		end
	end,
},
	create = function(self)
		self.w = self.w or self.font:getWidth(self.title) + 10
		self.h = self.h or self.font:getHeight() + 10
	end
}

-- x, y, w, h, align, text, onClick(), font, cursor, hint
E.label = {features = {x = 0, y = 0, text = "", font = menu_font,
	
	draw = function(self)
		if not self.enabled then return end
		local x, y = P.getAlignedCoords(self)
		if self.onClick and love.mouse.getX() > x - self.w/2 and love.mouse.getX() < x + self.w/2 and love.mouse.getY() > y - self.h/2 and love.mouse.getY() < y + self.h/2 then
			love.graphics.setColor(0.8, 0.8, 0.8)
			if self.cursor then
				render_cursor = Cursor[self.cursor]
			end
			if self.hint then
				cursor_hint = self.hint
			end
		else
			love.graphics.setColor(1, 1, 1)
		end
		love.graphics.setFont(self.font)
		love.graphics.print(self.text, x - self.w/2, y - self.font:getHeight()/2)
	end,
	
	mouseEvent = function(self, args)
		if not self.enabled then return end
		if not self.onClick then return end
		if self.parent.tick ~= 1 then return end
		if args.button ~= 1 then return end
		local x, y = P.getAlignedCoords(self)
		if args.x > x - self.w/2 and args.x < x + self.w/2 and args.y > y - self.h/2 and args.y < y + self.h/2 then
			if args.isDown then
				pressing = self
				Sound.press:stop()
				Sound.press:play()
			elseif pressing == self then
				if self.onClick then
					self:onClick()
				end
				Sound.release:stop()
				Sound.release:play()
			end
			return true
		end
	end,
},
create = function(self)
	self.w = self.w or self.font:getWidth(self.text)
	self.h = self.h or self.font:getHeight()
end
}


-- x, y, w, h, align, value, caret_pos, bg_text, font, cursor, hint
E.text = {features = {x = 0, y = 0, value = "", caret_pos = 0, font = menu_font, w = 0, cursor = "ibeam", tick = 0, can_focus = true,
	
	draw = function(self)
		if not self.enabled then return end
		local x, y = P.getAlignedCoords(self)
		if love.mouse.getX() > x - self.w/2 and love.mouse.getX() < x + self.w/2 and love.mouse.getY() > y - self.h/2 and love.mouse.getY() < y + self.h/2 then
			if self.cursor then
				render_cursor = Cursor[self.cursor]
			end
			if self.hint then
				cursor_hint = self.hint
			end
		end
		love.graphics.setColor(1, 1, 1)
		love.graphics.rectangle("fill", x - self.w/2, y - self.h/2, self.w, self.h)
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("line", x - self.w/2, y - self.h/2, self.w, self.h)
		love.graphics.setFont(self.font)
		love.graphics.setColor(0, 0, 0)
		love.graphics.print(self.value, x - self.w/2 + 5, y - self.font:getHeight()/2)
		if self.bg_text and #self.value == 0 and keyboard_focus ~= self then
			love.graphics.setColor(0.5, 0.5, 0.5)
			love.graphics.print(self.bg_text, x - self.w/2 + 5, y - self.font:getHeight()/2)
		end
		if keyboard_focus == self and self.tick < 1/2 then
			local c = x - self.w/2 + self.font:getWidth(string.sub(self.value, 1, self.caret_pos)) + 5
			love.graphics.line(c, y - self.h/2, c, y + self.h/2)
		end
	end,
	
	mouseEvent = function(self, args)
		if not self.enabled then return end
		if self.parent.tick ~= 1 then return end
		if args.button ~= 1 then return end
		local x, y = P.getAlignedCoords(self)
		if args.isDown and args.x > x - self.w/2 and args.x < x + self.w/2 and args.y > y - self.h/2 and args.y < y + self.h/2 then
			keyboard_focus = self
			self.tick = 0
			self.caret_pos = #self.value
			for f = 1, #self.value do
				if args.x < x - self.w/2 + self.font:getWidth(string.sub(self.value, 1, f)) - self.font:getWidth(string.sub(self.value, f, f))/2 + 5 then
					self.caret_pos = f - 1
					break
				end
			end
			return true
		end
	end,
	
	keyPressed = function(self, key)
		if self.parent.tick ~= 1 then return end
		if key == "backspace" then
			if self.caret_pos > 0 then
				self.value = string.sub(self.value, 1, self.caret_pos - 1) .. string.sub(self.value, self.caret_pos + 1, #self.value)
				self.caret_pos = self.caret_pos - 1
				self.tick = 0
			end
		elseif key == "delete" then
			if self.caret_pos < #self.value then
				self.value = string.sub(self.value, 1, self.caret_pos) .. string.sub(self.value, self.caret_pos + 2, #self.value)
				self.tick = 0
			end
		elseif key == "left" then
			self.caret_pos = math.max(self.caret_pos - 1, 0)
			self.tick = 0
		elseif key == "right" then
			self.caret_pos = math.min(self.caret_pos + 1, #self.value)
			self.tick = 0
		end
	end,
	
	textInput = function(self, text)
		if self.parent.tick ~= 1 then return end
		if self.font:getWidth(self.value .. text) <= self.w - 10 then
			self.value = string.sub(self.value, 1, self.caret_pos) .. text .. string.sub(self.value, self.caret_pos + 1, #self.value)
			self.caret_pos = self.caret_pos + #text
		end
	end,
},
create = function(self)
	self.h = self.h or self.font:getHeight() + 10
end
}

-- x, y, w, h, align, text, value, box_w, label_side, value_changed(), font, cursor, hint
E.toggle = {features = {x = 0, y = 0, value = false, text = "", font = menu_font, cursor = "hand", box_w = 20, label_side = "right", can_focus = true,
	
	draw = function(self)
		if not self.enabled then return end
		local x, y = P.getAlignedCoords(self)
		local is_over = false
		if love.mouse.getY() > y - self.h/2 and love.mouse.getY() < y + self.h/2 then
			if (self.label_side == "right" and love.mouse.getX() > x - self.w/2 and love.mouse.getX() < x + self.w/2 + 5 + self.font:getWidth(self.text))
			or (self.label_side == "left" and love.mouse.getX() > x - self.w/2 - 5 - self.font:getWidth(self.text) and love.mouse.getX() < x + self.w/2) then
				if self.cursor then
					render_cursor = Cursor[self.cursor]
				end
				if self.hint then
					cursor_hint = self.hint
				end
				is_over = true
			end
		elseif keyboard_focus == self then
			is_over = true
		end
		love.graphics.setColor(1, 1, 1)
		love.graphics.setFont(self.font)
		if self.text then
			if self.label_side == "right" then
				love.graphics.print(self.text, x + self.w/2 + 5, y - self.font:getHeight()/2)
			elseif self.label_side == "left" then
				love.graphics.print(self.text, x - self.w/2 - self.font:getWidth(self.text) - 5, y - self.font:getHeight()/2)
			end
		end
		if is_over then
			love.graphics.setColor(0.8, 0.8, 0.8)
		else
			love.graphics.setColor(1, 1, 1)
		end
		love.graphics.rectangle("fill", x - self.w/2, y - self.box_w/2, self.box_w, self.box_w)
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("line", x - self.w/2, y - self.box_w/2, self.box_w, self.box_w)
		if self.value then
			love.graphics.setColor(0, 0, 0)
			-- love.graphics.rectangle("fill", x - self.w/2 + 3, y - self.box_w/2 + 3, self.box_w - 6, self.box_w - 6)
			love.graphics.draw(Img.ui.toggle_check, x - self.w/2, y - self.box_w/2)
		end
	end,
	
	mouseEvent = function(self, args)
		if not self.enabled then return end
		if self.parent.tick ~= 1 then return end
		if args.button ~= 1 then return end
		local x, y = P.getAlignedCoords(self)
		if args.y > y - self.h/2 and args.y < y + self.h/2 then
			if (self.label_side == "right" and args.x > x - self.w/2 and args.x < x + self.w/2 + 5 + self.font:getWidth(self.text))
			or (self.label_side == "left" and args.x > x - self.w/2 - 5 - self.font:getWidth(self.text) and args.x < x + self.w/2) then
				if args.isDown then
					pressing = self
					Sound.press:stop()
					Sound.press:play()
				elseif pressing == self then
					self.value = not self.value
					if self.value_changed then
						self:value_changed()
					end
					Sound.release:stop()
					Sound.release:play()
				end
				return true
			end
		end
	end,
},
create = function(self)
	self.w = self.w or self.box_w
	self.h = self.h or math.max(self.box_w, self.font:getHeight())
end
}

-- x, y, w, h, align, value, handle_w, bar_h, valueChanged(), action(), cursor, hint
E.slider = {features = {x = 0, y = 0, value = 0, w = 0, h = 20, handle_w = 7, bar_h = 5, cursor = "hand", can_focus = true,
	
	draw = function(self)
		if not self.enabled then return end
		local x, y = P.getAlignedCoords(self)
		local is_over = false
		if love.mouse.getX() > x - self.w/2 and love.mouse.getX() < x + self.w/2 and love.mouse.getY() > y - self.h/2 and love.mouse.getY() < y + self.h/2 then
			if self.cursor then
				render_cursor = Cursor[self.cursor]
			end
			if self.hint then
				cursor_hint = self.hint
			end
			is_over = true
		elseif keyboard_focus == self then
			is_over = true
		end
		if pressing == self and self.hint then
			cursor_hint = self.hint
		end
		love.graphics.setColor(1, 1, 1)
		love.graphics.rectangle("fill", x - self.w/2, y - self.bar_h/2, self.w, self.bar_h)
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("line", x - self.w/2, y - self.bar_h/2, self.w, self.bar_h)
		if is_over then
			if pressing == self then
				love.graphics.setColor(0.4, 0.4, 0.4)
			else
				love.graphics.setColor(0.6, 0.6, 0.6)
			end
		else
			love.graphics.setColor(0.8, 0.8, 0.8)
		end
		love.graphics.rectangle("fill", x - self.w/2 + self.value * self.w - self.handle_w/2, y - self.h/2, self.handle_w, self.h)
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("line", x - self.w/2 + self.value * self.w - self.handle_w/2, y - self.h/2, self.handle_w, self.h)
	end,
	
	mouseEvent = function(self, args)
		if not self.enabled then return end
		if self.parent.tick ~= 1 then return end
		if args.button ~= 1 then return end
		local x, y = P.getAlignedCoords(self)
		if args.isDown then
			if args.x > x - self.w/2 and args.x < x + self.w/2 and args.y > y - self.h/2 and args.y < y + self.h/2 then
				pressing = self
				self.value = math.min(math.max((args.x - x) / self.w + 1/2, 0), 1)
				Sound.press:stop()
				Sound.press:play()
				return true
			end
		elseif pressing == self then
			if self.valueChanged then
				self:valueChanged()
			end
			if self.action then
				self:action()
			end
			Sound.release:stop()
			Sound.release:play()
			return true
		end
	end,
	
	update = function(self)
		local x, y = P.getAlignedCoords(self)
		self.value = math.min(math.max((love.mouse.getX() - x) / self.w + 1/2, 0), 1)
		if self.valueChanged then
			self:valueChanged()
		end
	end,
}}

-- UI Containers --

local views = {}
-- x, y, w, h, tick, open_time, close_time, executeAll(), close(), open(), toggle(), updateSize(), can_navigate
E.view = {features = {enabled = false, x = 0, y = 0, w = 0, h = 0, tick = 0, open_time = 1, close_time = 1, can_navigate = true,
	
	executeAll = function(self, func, args)
		-- if not self.enabled then return end
		for index, this in ipairs(self) do
			if type(func) == "string" and type(this[func]) == "function" then
				local result = this[func](this, args)
				if result then return result end
			elseif type(func) == "function" then
				local result = func(this)
				if result then return result end
			end
		end
	end,
	
	open = function(self)
		self.enabled = true
		if self.open_time == 0 then
			self.tick = 1
		end
	end,
	
	close = function(self)
		self.enabled = false
		if keyboard_focus and self:executeAll(function(self) if keyboard_focus == self then return true end end) then
			keyboard_focus = nil
		end
		if pressing and self:executeAll(function(self) if pressing == self then return true end end) then
			pressing = nil
		end
		if self.close_time == 0 then
			self.tick = 0
		end
	end,
	
	toggle = function(self)
		if self.enabled then
			self:close()
		else
			self:open()
		end
	end,
},
	create = function(self)
		table.insert(views, self)
		for index, this in ipairs(self) do
			this.parent = self
		end
		if self.updateSize then
			self:updateSize()
		end
		self:executeAll("updateSize")
	end
}

function P.purgeViews()
	views = {}
end

-- Finalize Objects --
for index, this in pairs(E) do
	P[index] = function(args)
		local self = {enabled = true, ui_type = index}
		for arg_index, this_arg in pairs(E[index].features) do
			self[arg_index] = this_arg
		end
		for arg_index, this_arg in pairs(args) do
			self[arg_index] = this_arg
		end
		if this.create then
			this.create(self)
		end
		return self
	end
end



-- Built In Functions

function P.load()
	
	DrawAdd(P, "ui", 10000001)
	
end


function P.draw()
	
	love.graphics.origin()
	-- love.graphics.scale(L.settings.scale)
	
	
	for index, this in ipairs(views) do
		
		if this.tick > 0 then
			this:executeAll("draw")
		end
		
	end
	
	
	-- Cursor Hint --
	love.graphics.origin()
	if cursor_hint and love.window.hasMouseFocus() then
		love.graphics.setFont(menu_font)
		if love.mouse.getX() < menu_font:getWidth(cursor_hint) + 15 then
			love.graphics.setColor(0, 0, 0, 0.5)
			love.graphics.rectangle("fill", love.mouse.getX() + 30 - 5, love.mouse.getY() + 10 - 5, menu_font:getWidth(cursor_hint) + 10, menu_font:getHeight() + 10)
			love.graphics.setColor(1, 1, 1)
			love.graphics.print(cursor_hint, love.mouse.getX() + 30, love.mouse.getY() + 10)
		else
			love.graphics.setColor(0, 0, 0, 0.5)
			love.graphics.rectangle("fill", love.mouse.getX() - menu_font:getWidth(cursor_hint) - 10 - 5, love.mouse.getY() + 10 - 5, menu_font:getWidth(cursor_hint) + 10, menu_font:getHeight() + 10)
			love.graphics.setColor(1, 1, 1)
			love.graphics.print(cursor_hint, love.mouse.getX() - menu_font:getWidth(cursor_hint) - 10, love.mouse.getY() + 10)
		end
	end
	-- Custom Cursor --
	if love.mouse.isCursorSupported() and love.mouse.getCursor() ~= render_cursor then
		love.mouse.setCursor(render_cursor)
	end
	-- Reset --
	render_cursor = Default_cursor
	cursor_hint = nil
	
end


function P.update(dt)
	
	if keyboard_focus and keyboard_focus.tick then
		keyboard_focus.tick = keyboard_focus.tick + dt
		if keyboard_focus.tick > 1 then
			keyboard_focus.tick = keyboard_focus.tick - 1
		end
	end
	
	if pressing and pressing.ui_type == "slider" and pressing.update then
		pressing:update()
	end
	
	for index, this in ipairs(views) do
		if this.enabled and this.open_time > 0 then
			this.tick = math.min(this.tick + dt / this.open_time, 1)
		elseif not this.enabled and this.close_time > 0 then
			this.tick = math.max(this.tick - dt / this.close_time, 0)
		end
	end
	
end


function P.mousepressed(mx, my, button)
	
	keyboard_focus = nil
	
	for index, this in ipairs(views) do
		if this:executeAll("mouseEvent", {isDown = true, x = mx, y = my, button = button}) then return true end
	end
	
end

function P.mousereleased(mx, my, button)
	
	for index, this in ipairs(views) do
		if this:executeAll("mouseEvent", {isDown = false, x = mx, y = my, button = button}) then break end
	end
	
	if button == 1 then
		pressing = nil
	end
	
end

function P.keypressed(key)
	
	if keyboard_focus then
		love.keyboard.setKeyRepeat(true)
		
		if keyboard_focus.parent.can_navigate and (key == "up" or key == "down" or key == "tab") then
			
			local here
			for index, this in ipairs(keyboard_focus.parent) do
				if this == keyboard_focus then
					here = index
					break
				end
			end
			
			while true do
				if key == "up" or (key == "tab" and (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift"))) then
					here = here - 1
				else
					here = here + 1
				end
				if not keyboard_focus.parent[here] then
					break
				end
				if keyboard_focus.parent[here].can_focus then
					keyboard_focus = keyboard_focus.parent[here]
					break
				end
			end
			
		elseif keyboard_focus.keyPressed then
			keyboard_focus:keyPressed(key)
		end
		
		return true
		
	else
		love.keyboard.setKeyRepeat(false)
	end
	
end

-- function P.keyreleased(key)
	
-- end

function P.textinput(text)
	
	if keyboard_focus and keyboard_focus.textInput then
		keyboard_focus:textInput(text)
	end
	
end

function P.resize(window_w, window_h)
	
	for index, this in ipairs(views) do
		if this.updateSize then
			this:updateSize()
		end
		this:executeAll("updateSize")
	end
	
end


-- Helper Functions --

function P.getAlignedCoords(self)
	if self.align == "right" then
		return self.parent.x + self.x - self.w/2, self.parent.y + self.y
	elseif self.align == "left" then
		return self.parent.x + self.x + self.w/2, self.parent.y + self.y
	else
		return self.parent.x + self.x, self.parent.y + self.y
	end
end


return P
