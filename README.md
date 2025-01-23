Provides a player state controller class that allows seamless saving and setting of the current player's state. It works by using a forked modified PlayerModule and Animate script, with exposed internal methods.

# Table of Contents
* [Setup](#Setup)
* [How to use](#how-to-use)
* [Known Issues](#known-issues)

# Setup

Get the latest version in [Releases](https://github.com/cynkeyo/player-state-controller/releases/), or simply get the model from [Roblox](https://create.roblox.com/store/asset/138108270501265/playerstatecontroller).

Simply place the Animate script inside StarterCharacterScripts, and place the PlayerModule script inside StarterPlayerScripts.

# How to use

Saving state and setting it to player:
```lua
local PlayerStateControllerClass = require("path to the module")
local Player = game:GetService("Players").LocalPlayer

local playerStateController = PlayerStateController.new()
local savedState = nil

playerStateController:init(Player)

savedState = playerStateController:GetCurrentState()
playerStateController:SetState(SavedState)
```

# Known Issues

* There is a delay of one frame for the Camera to be in the correct state position, causing a jitter.
