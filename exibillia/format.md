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
Note: Use the keyword 'me' when referencing the player

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

⚠️Important: Avoid jumping upwards as it may be resource intensive, especially in larger story files! Also be aware that loops may break immersion.

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

Note: You may use ditto marks (") as the send text if the send text is the same as the clickable text.

⚠️Important: If you do not put a pause this after a choice, the game will continue running commands!

## Pause

```none
=

or

$pause
```

## Resume

```none
+

or

$resume
```

## Clear choice question and options

```none
<

or

$erase
```

Note: This is done automatically when the player submits a choice.

# Logic

## Store

```none
$set|%[name_of_variable]%|[value]|[mathematical operator](defaults to =)
```

Note: The mathimatical operator can be any of these: '=' '+' '-' '*' '/' '%'

Note: Variables can be a number or string.

## Compare

```none
$if|[value or variable]}|[comparison operator]|[value or variable]
	[command to be executed]
```
Note: The comparison operator can be any of these: '==' '!=' '>' '<' '>=' '<='

Note: If multiple commands are needed, utilize the jump command.

## Recall

```none
me: Looks like %[name_of_variable]% seconds have passed.
```
Note: Variables may be used inside of most commands.

# Audio

## Play sound effect

```none
$sound|[sound_file_path]
```

Note: Don't forget the sound file's file extension.

## Start / change music

```none
$music|[music_file_path](optional)|[transition_time](in seconds)(optional)
```

## Stop / fade out music

```none
$music_stop|[fade_out_time](in seconds)(optional)
```

## Queue a song to play after the current one is finished

```none
$music_q|[music_file_path]
```

# Misc

## Custom typing indicator

```none
$type|[internal_username]|[typing_time](in seconds)(optional)
```

Note: To clear the typing indicator, simply do not include a username or typing time.

## Clear chat

```none
$clear
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

Note: Comments must be on their own line, separate from commands.