# Format spec

## Folder structure

```none
stories/
    *.zip/
        images/
        music/
        sounds/
		thumbnail.png
        story.txt
```

# story.txt format

## Header

```none
title: [Title]
author: [Author(s)]
version: [Version] (x.x.x)
desc: [Description]
rating: [Age Rating] (number)
lang: [Language] (ISO code)

=== (end of header)
```

## Create a user

```none
$char|[internal_username]|[username]|[picture_path](optional)
```
Note: Use the keyword 'me' when referencing the player's username, picture, etc.

## Sending messages

```none
[internal_username](optional):[message_text]|[image_path](optional)

or

$send|[internal_username](optional)|[message_text]|[image_path](optional)
```

When using this command, the game will automatically show that the user is typing before each message. To send a message without any automation, use this instead:

```none
[internal_username](optional);[message_text]|[image_path](optional)

or

$send_plain|[internal_username](optional)|[message_text]|[image_path](optional)
```

Note: Leave the username blank to send a user-less / system message.

Note: To send a message as the player, use the internal username "me".

## Wait

```none
+[wait_time]

or

$wait|[wait_time]
```

# Flow control

## Labels

```none
#[label_name]
```

## Jump downwards

```none
->[label_name]

or

$jump|[label_name]
```

## Jump upwards

```none
-^[label_name]

or

$jump_up|[label_name]
```

⚠️Important: Avoid jumping upwards as it may be resource intensive, especially in larger story files!

## Create / change the choice question

```none
?[text of the question being asked]

or

$question|[text of the question being asked]
```

Note: Creating a question is not required for creating a choice.

## Create / add choice options

```none
>   [clickable text 1]	(text that the person clicks on)
    [sent text 1]		(text that actually ends up sending)
    [command 1]			(command / jump to be executed)
>   [clickable text 2]
    [sent text 2]
          				(must leave a blank line here to not run a command)
... (as many choices as needed)

or

$choice|[clickable text 1]|[sent text 1]|[command 1]
$choice|[clickable text 2]|[sent text 2]
... (as many choices as needed)
```

## Pause when you've ran out of script and you need the player to choose

```none
=

or

$pause
```
⚠️Important: If you do not put this after a choice, the game will continue running commands!

## Clear choice question and options

```none
<

or

$erase
```

# Logic

## Store

```none
$set|@[name_of_variable]|[value]
```

Note: Variables can only store numbers.

## Compare

```none
$if|@[name_of_variable]|== or > or <|[value]
	[command to be executed]
```
Note: If multiple commands are needed, utilize the jump operator.

## Recall

```none
bla bla bla @[name_of_variable] bla bla bla
```
Note: Variables may be placed inside of any command.

# Audio

## Change music

```none
$music|[music_filename]|[transition_time](in seconds)
```

## Play sound effect

```none
$sound|[sound_filename]
```

# Misc

## Custom typing indicator

```none
$type|[internal_username]|[typing_time](in seconds)
```

## Clear chat

```none
$cls
```

## Console log

```none
$print|[debug text to print to the console]
```

## End

```none
$end
```

Note: The story will also end once it reaches the end of the file and runs out of commands.

## Comments

```c
// single line comment

/*
multiline comment
*/
```

Note: Comments must be on their own line.