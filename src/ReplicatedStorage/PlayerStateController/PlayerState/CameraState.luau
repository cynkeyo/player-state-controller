--!native
--!optimize 2

local RunService = game:GetService("RunService")

type AbstractCameraController = {
    SetCameraToSubjectDistance: (self: any, desiredSubjectDistance: number, instant: boolean?) -> (),
    GetCameraToSubjectDistance: (self: any) -> number
}

type AbstractMouseLockController = {
    GetIsMouseLocked: (self: any) -> boolean,
    DoMouseLockSwitch: (self: any, name: any, state: Enum.UserInputState) -> ()
}

type AbstractCameraModule = {
    activeCameraController: AbstractCameraController,
    activeMouseLockController: AbstractMouseLockController
}

type AbstractPlayerModule = {
    GetCameras: (self: any) -> AbstractCameraModule 
}

type ICameraState = {
    __index: ICameraState,
    new: () -> CameraState,
    fromPlayer: (Player) -> CameraState,
    SetToPlayer: (self: CameraState, Player) -> (),
    Destroy: (self: CameraState) -> ()
}

export type CameraState = typeof(setmetatable(
    {} :: {
        CFrame: CFrame,
        SubjectDistance: number,
        MouseLocked: boolean
    },
    {} :: ICameraState
))

local CameraState = {}
CameraState.__index = CameraState

--[[
	@return @CameraState CameraState 

	Creates a new blank CameraState
]]
function CameraState.new(): CameraState
    local self = setmetatable({}, CameraState)

    self.CFrame = CFrame.new()
    self.SubjectDistance = 10
    self.MouseLocked = false

    return self
end 

local function getCameraModuleFromPlayer(Player: Player): AbstractCameraModule 
    local SingletonPlayerModule: AbstractPlayerModule = require(Player.PlayerScripts:FindFirstChild("PlayerModule"))

    return SingletonPlayerModule:GetCameras() 
end

--[[
	@param @Camera Camera
	@return @CameraState CameraState

	Creates a new CharacterState from the @param Camera.
]]
function CameraState.fromPlayer(Player: Player): CameraState
    local self = setmetatable({}, CameraState)
    
    local CameraModule = getCameraModuleFromPlayer(Player)

    local CameraController = CameraModule.activeCameraController
    local MouseLockController = CameraModule.activeMouseLockController

    self.CFrame = workspace.CurrentCamera.CFrame
    self.SubjectDistance = CameraController:GetCameraToSubjectDistance()
    self.MouseLocked = MouseLockController:GetIsMouseLocked()

    return self
end

--[[
	@param @Camera Camera

	Sets the @param Camera state to match the CameraState instance.
]]
function CameraState:SetToPlayer(Player: Player)
    local Camera = workspace.CurrentCamera

    local CameraModule = getCameraModuleFromPlayer(Player)

    local CameraController = CameraModule.activeCameraController
    local MouseLockController = CameraModule.activeMouseLockController

    Camera.CFrame = self.CFrame
    CameraController:SetCameraToSubjectDistance(self.SubjectDistance, true)
    
    if MouseLockController:GetIsMouseLocked() ~= self.MouseLocked then
        MouseLockController:DoMouseLockSwitch(nil, Enum.UserInputState.Begin)
    end
end

--[[
    Destroys the CameraState instance.
]]
function CameraState:Destroy()
    table.clear(self)
    setmetatable(self, nil)
    table.freeze(self)
end

return CameraState