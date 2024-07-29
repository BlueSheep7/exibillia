
-- TODO:


local P = {}
for index, this in pairs(_G) do
	P[index] = this
end
setfenv(1, P)

interact_weight = 1
DrawAdd(P, "game", 1)

-- Constants


-- Built In Functions

function load()
	
	show_game = false
	
end

function draw()

	if not show_game then
		return
	end
		
	love.graphics.rectangle("fill", 0, 0, 100, 100)
	
	
end

function update(dt)
	
	if not show_game then
		return
	end
	
	
end

function mousepressed(mx_true, my_true, button)
	
	
	
end


-- Custom Commands --

L.story.Command["start_game"] = function(args)
	
	show_game = true
	
end



return P
