--!native
--!optimize 2

local PlayerState = require(script.PlayerState)

type IPlayerStateController = {
    __index: IPlayerStateController,
    new: () -> PlayerStateController,
    init: (self: PlayerStateController, Player: Player) -> (),
    GetCurrentState: (self: PlayerStateController) -> PlayerState.PlayerState?,
    SetState: (self: PlayerStateController, PlayerState: PlayerState.PlayerState) -> (),
}

export type PlayerStateController = typeof(setmetatable(
    {} :: {
        SetZoom: boolean,
        SetShiftLock: boolean,
    },
    {} :: IPlayerStateController
))

local PlayerStateController = {}
PlayerStateController.__index = PlayerStateController

--[[
    Creates a new blank PlayerStateController instance.
]]
function PlayerStateController.new()
    local self = setmetatable({}, PlayerStateController)

    -- private members
    self.__Player = nil
    self.__Character = nil
    self.__CharacterAddedConnection = nil
    self.__initialized = false

    self.SetZoom = true
    self.SetShiftLock = true

    return self
end

--[[
    @param @Player Player

    Initializes the PlayerStateController with the @param Player.
]]
function PlayerStateController:init(Player: Player)
    local function loadCharacter(Character)
        --Wait until the character is fully loaded before updating the character member to the new one.
        local Humanoid = Character:WaitForChild("Humanoid")
        local Animate = Character:WaitForChild("Animate")
        local AnimateMethods = Animate:WaitForChild("Methods")

        Humanoid.Died:Once(function()
            -- Set the character member to nil 
            self.__Character = nil
        end)

        self.__Character = Character
    end

    self.__Player = Player
    self.__CharacterAddedConnection = Player.CharacterAdded:Connect(loadCharacter)

    if Player.Character then
        loadCharacter(Player.Character)
    end

    self.__initialized = true
end

--[[
    Saves the player's current state to the SavedState member.
]]
function PlayerStateController:GetCurrentState()
    assert(self.__initialized, "PlayerStateController must be initialized before calling this method.")

    if not self.__Character then
        return nil
    end

    return PlayerState.fromPlayer(self.__Player, self.__Character)
end

--[[
    @param @PlayerState PlayerState

    Sets the player's state to the @param PlayerState.
]]
function PlayerStateController:SetState(PlayerState: PlayerState.PlayerState)
    assert(self.__initialized, "PlayerStateController must be initialized before calling this method.")
    assert(PlayerState, "Missing argument 1, no PlayerState object passed.")

    if not self.__Character then
        return
    end

    local options: PlayerState.stateSetterOptions = {
        setZoom = self.SetZoom,
        setShiftLock = self.SetShiftLock
    } 

    PlayerState:SetToPlayer(self.__Player, self.__Character, options)
end

--[[
    Destroys the PlayerStateController instance.
]]
function PlayerStateController:Destroy()
    self.__CharacterAddedConnection:Disconnect()

    table.clear(self)
    setmetatable(self, nil)
    table.freeze(self)
end

return PlayerStateController