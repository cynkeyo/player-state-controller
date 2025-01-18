--!native
--!optimize 2

local RunService = game:GetService("RunService")

type ICameraState = {
    __index: ICameraState,
    new: () -> CameraState,
    fromCamera: (Camera) -> CameraState,
    SetToCamera: (self: CameraState, Camera) -> (),
    Destroy: (self: CameraState) -> ()
}

export type CameraState = typeof(setmetatable(
    {} :: {
        CFrame: CFrame,
        CameraType: Enum.CameraType
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
    self.CameraType = Enum.CameraType.Custom

    return self
end 

--[[
	@param @Camera Camera
	@return @CameraState CameraState

	Creates a new CharacterState from the @param Camera.
]]
function CameraState.fromCamera(Camera: Camera): CameraState
    local self = setmetatable({}, CameraState)
    
    self.CFrame = Camera.CFrame
    self.CameraType = Camera.CameraType

    return self
end

local SET_CFRAME_BIND = "CAMERA_STATE_SET_CFRAME"

--[[
	@param @Camera Camera

	Sets the @param Camera state to match the CameraState instance.
]]
function CameraState:SetToCamera(Camera: Camera)

    -- Set the camera CFrame to the desired state before the frame gets drawed.

    Camera.CFrame = self.CFrame
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