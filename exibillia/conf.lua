-- RWL --

function love.conf(t)
	
	t.identity = "Dont Panic"
	t.window.title = "Don't Panic"
	t.window.icon = "graphics/icon.png"
	
	t.window.resizable = true
	t.window.width = 1920*2/3
	t.window.height = 1080*2/3
	-- t.window.fullscreen = true
	-- t.window.vsync = false
	t.console = true
	
end
