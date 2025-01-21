--!native
--!optimize 2

local RunService = game:GetService("RunService")
local CharacterState = require(script.CharacterState)
local CameraState = require(script.CameraState)

export type stateSetterOptions = {
    setZoom: boolean,
    setShiftLock: boolean
}

type IPlayerState = {
    __index: IPlayerState,
    new: () -> PlayerState,
    FromPlayer: (Player: Player, Character: Model) -> PlayerState,
    SetToPlayer: (self: PlayerState, Player: Player, Character: Model, options: stateSetterOptions) -> (),
    Destroy: () -> ()
}

export type CharacterState = CharacterState.CharacterState

export type CameraState = CameraState.CameraState

export type PlayerState = typeof(setmetatable(
    {} :: {
        CharacterState: CharacterState.CharacterState,
        CameraState: CameraState.CameraState
    },
    {} :: IPlayerState
))

local PlayerState = {}
PlayerState.__index = PlayerState

--[[
    @return PlayerState PlayerState

    Creates a blank PlayerState instance.
]]
function PlayerState.new(): PlayerState
    local self = setmetatable({}, PlayerState)

    self.CharacterState = CharacterState.new()
    self.PlayerState = PlayerState.new()

    return self
end

--[[
    @param @Player Player
    @param @Character Character
    @return @PlayerState PlayerState

    Creates a new PlayerState instance, that matches the @param Player camera state, and the @param Character state.
    Yields until the PostSimulation call.

	The @param Character must be a R6 rig with a custom Animate script and a Humanoid.
]]
function PlayerState.fromPlayer(Player: Player, Character: Model): PlayerState
    local self = setmetatable({}, PlayerState)

    -- Gets the state of the camera at the end of the render pipeline.

    RunService.PostSimulation:Wait()
    
    self.CameraState = CameraState.fromPlayer(Player)
    self.CharacterState = CharacterState.fromCharacter(Character) 

    return self
end

--[[
    @param @Player Player
    @param @Character Character
    @return @PlayerState PlayerState

    Matches the @param Player camera state and the @param Character state to the PlayerState instance.
    This process is deffered to the PreRender step.

	The @param Character must be a R6 rig with a custom Animate script and a Humanoid.
]]
function PlayerState:SetToPlayer(Player: Player, Character: Model, options: stateSetterOptions)
    local setZoom = nil
    local setShiftLock = nil

    if options then
        setZoom = options.setZoom
        setShiftLock = options.setShiftLock
    end

    -- Sets the state at the beginning of the frame.
    self.CameraState:SetToPlayer(Player, setZoom, setShiftLock)

    RunService.PreRender:Once(function()
        self.CharacterState:SetToCharacter(Character)
    end)
end

--[[
    Destroys the PlayerState instance.
]]
function PlayerState:Destroy()
    self.CharacterState:Destroy()
    self.CameraState:Destroy()

    table.clear(self)
    setmetatable(self, nil)
    table.freeze(self)
end

return PlayerState