# MrFrost Commands

MrFrost Commands is a collection of useful commands for your FiveM server that are built on top of the qb-core resource.

## Available Commands

- `/notify`: Allows players to send a notification to a specific player with a specified duration.
- Other commands will be added in the future.

## Usage

`/notify [ID] [duration] [message]`
Where: 
- ID : is the target player id
- duration : is duration in seconds the notification will appear on the client.
- message : is the message that will be sent to the target player

## Configuration

You can change the command names and permissions in the config.lua file.
You can change or add translations in the locales folder.

## Note

These commands require the qb-core resource to be running on the server. Make sure to add it to your server's resources before using these commands.
