-- Debug --
-- RWL --

debugger = {}
debugger.libname = "debugger"
debugger.debugcolor = {0.8, 0.8, 0.8}

debugger.interactorder = 0
drawable_add(debugger, "overlay", 99999999)

debugger.show = false
debugger.font = love.graphics.newFont(12)
debugger.quittick = 0

debugger.story_wait_old = 0

function debugger.draw()
	
	love.graphics.origin()
	-- love.graphics.translate(-game.camx, -game.camy)
	-- love.graphics.scale(game.scale)
	
	if debugger.show then
		love.graphics.setFont(debugger.font)
		
		-- Debug Text --
		love.graphics.origin()
		love.graphics.setColor(0, 0, 0, 0.5)
		love.graphics.rectangle("fill",0,0,450,(#drawable+1)*15)
		love.graphics.setColor(1, 1, 1)
		
		-- Stats --
		love.graphics.print("FPS: "..love.timer.getFPS(), 350, 0)
		-- love.graphics.print("Mouse: "..game.mx.." , "..game.my, 350, 15)
		-- love.graphics.print("Camera: "..math.floor(game.camx).." , "..math.floor(game.camy).." : "..string.sub(game.scale, 1, 4), 350, 30)
		
		-- Interact Order --
		love.graphics.print("Interact Order:", 200, 0)
		for k,item in pairs(interacttable) do
			if item.interactorder then
				love.graphics.print(item.libname..": "..item.interactorder, 200, k * 15)
			end
		end
		
		-- Draw Order --
		love.graphics.print("Draw Order:", 0, 0)
		for k,item in pairs(drawable) do
			if item.lib.debugcolor then
				love.graphics.setColor(item.lib.debugcolor[1], item.lib.debugcolor[2], item.lib.debugcolor[3])
			else
				love.graphics.setColor(1,1,1)
			end
			if type(item.id) == "string" then
				love.graphics.print(item.lib.libname.." - "..item.id..": "..item.y, 0, k * 15)
			else
				love.graphics.print(item.lib.libname..": "..item.y, 0, k * 15)
			end
		end
		
	end
	
end

function debugger.update(dt)
	
	-- if love.keyboard.isDown("=") then
		-- game.scale = game.scale + 2 * dt
	-- end
	-- if love.keyboard.isDown("-") then
		-- game.scale = game.scale - 2 * dt
	-- end
	
	if love.keyboard.isDown("escape") then
		debugger.quittick = debugger.quittick + dt
		if debugger.quittick >= 0.5 then
			love.event.quit()
		end
	else
		debugger.quittick = 0
	end
	
	if love.keyboard.isDown("rshift") then
		debugger.time_scale = 5
	else
		debugger.time_scale = 1
	end
	
	-- if story.waiting then
	-- 	if math.ceil(story.wait_time) ~= debugger.story_wait_old then
	-- 		print("Wait time remaining: " .. math.ceil(story.wait_time))
	-- 		debugger.story_wait_old = math.ceil(story.wait_time)
	-- 	end
	-- end
	
end

function debugger.keypressed(key)
	
	if key == "f3" then
		debugger.show = not debugger.show
	end
	
	if key == "f11" then
		settings.video_fullscreen = not settings.video_fullscreen
		love.window.setFullscreen(settings.video_fullscreen)
	end
	
	if key == "f2" then
		
		settings.ui_scale = settings.ui_scale * 2
		if settings.ui_scale > 4 then
			settings.ui_scale = 0.5
		end
		ui.createUI()
		if ui.show_chat then
			ui.calc.max_scroll()
			ui.scroll = math.max(math.min(ui.scroll + y * 30, 0), ui.max_scroll)
		end
		
	end
	
end

function debugger.mousepressed(x, y, b)
	
	-- if b == 1 then
		-- love.system.setClipboardText(math.floor((love.mouse.getX() + game.camx) / game.scale)..", "..math.floor((love.mouse.getY() + game.camy) / game.scale))
	-- end
	
end

-- function debugger.wheelmoved(x, y)
	
	-- if y > 0 then
		-- game.scale = game.scale + 0.1
	-- elseif y < 0 then
		-- game.scale = game.scale - 0.1
	-- end
	
-- end

return debugger
