
return{

title = "Testing 2",
author = "BlueSheep",
description = "This is a test story.",
language = "en",

onLoad = function()
	-- this_story.variable = "stuff"
end,

onQuit = function()
	
	
	
end,

users = {
guy = {name = "DQAH063", status = "online"},
},

chats = {
{visible = true, users = {"guy"}, is_typing = nil},
-- {visible = true, users = {1}, name = "Test Group", pic = "krieg"},
},


story = {


START = {
	
	{"clear", chat = 1},
	
	{"wait", time = 2},
	{"msg", user = "guy", text = "Hey!"},
	{"wait", time = 1},
	{"msg", user = "guy", text = "uhhhh"},
	{"wait", time = 0.5},
	{"msg", user = "guy", text = "how are you?"},
	{"choice", pause = true, reply = {
		{short = "Hi",		long = "Hi.", label = "skip_good"},
		{short = "Good",	long = "Doing fine."},
	}},
	{"msg", user = "guy", text = "Good!"},
	{"msg", user = "guy", text = "Great!"},
	{"label", "skip_good"},
	{"wait", time = 0.5},
	{"msg", user = "guy", text = "sorry"},
	{"msg", user = "guy", text = "ahem"},
	{"wait", time = 2},
	{"typing", chat = 1, user = "guy", status = true},
	{"wait", time = 2},
	{"typing", chat = 1, user = "guy", status = false},
	{"wait", time = 1},
	{"msg", user = "guy", text = "I'm going to be honest with you."},
	{"msg", user = "guy", text = "I'm being employed to keep your attention."},
	{"msg", user = "guy", text = "And I'm still new at this..."},
	-- {"code", function() this_story.users.guy.name = "Rebecca" end},
	-- {"code", function() this_story.users.guy.pic = "hina" end},
	{"pause"},
	
	
	
	{"jump", path = "temp_end"},

},




temp_end = {
	
	{"msg", text = "[ALERT] Ran out of story."},
	{"choice", question = "What would you like to do?", reply = {
		{short = "[Restart]",	long = "Press Send to Restart",	path = "START"},
		{short = "[Exit]",		long = "Press Send to Exit",	path = "exit"},
	}},
	
},

exit = {
	{"code", function () love.event.quit() end}
},


},

}


--[[]
Examples:

{"msg", chat = 1, user = "friend", text = "Sample Text", img = "sample_image", message_sound = false, type_time = 2, lean = false},

{"wait", time = 1},

{"typing", chat = 1, user = "friend", status = true},

{"label", "loop_1"},
{"label", label = "loop_1"},

{"jump", path = "path_1", label = "loop_1"},

{"choice", chat = 1, question = "What do you choose?", reply = {
	{short = "Choice 1", long = "I picked Choice 1", path = "choice_1", label = "label_1"},
	{short = "Choice 2", long = "I picked Choice 2", path = "choice_2"},
	{short = "Choice 3", long = "I picked Choice 3", path = "choice_3", dont_send = true},
}},

{"code", function() print("Replace this print with whatever lua code you want.") end},

{"clear", chat = 1},

{"pause"},

]]--
