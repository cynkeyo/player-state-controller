--[[
	PlayerModule - This module requires and instantiates the camera and control modules,
	and provides getters for developers to access methods on these singletons without
	having to modify Roblox-supplied scripts.

	2018 PlayerScripts Update - AllYourBlox

    The following scripts in the module were edited to work correctly with the player-state-controller class and or add important features:
    - MouseLockController, CameraModule -> mobile shiftlock support
    - ControlModule -> set player's Humanoid AutoJumpEnabled property to false upon CharacterAdded
    - TransparencyController -> change character opacity instantly
    - BaseCamera, ZoomController -> change zoom state

    All the changes made to this module can be tracked within the github repository (cynkeyo/player-state-controller) after the commit #2a291dc
--]]

local PlayerModule = {}
PlayerModule.__index = PlayerModule

function PlayerModule.new()
	local self = setmetatable({},PlayerModule)
	self.cameras = require(script:WaitForChild("CameraModule"))
	self.controls = require(script:WaitForChild("ControlModule"))
	
	return self
end

function PlayerModule:GetCameras()
	return self.cameras
end

function PlayerModule:GetControls()
	return self.controls
end

function PlayerModule:GetClickToMoveController()
	return self.controls:GetClickToMoveController()
end

return PlayerModule.new()
