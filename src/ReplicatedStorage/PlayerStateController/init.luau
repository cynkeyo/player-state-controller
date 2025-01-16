--!native
--!optimize 2
--!strict

local PlayerState = require(script.PlayerState)

type IPlayerStateController = {
    __index: IPlayerStateController,
    new: () -> PlayerStateController,
    GetPlayerState: (self: PlayerStateController) -> PlayerState.PlayerState,
    SetPlayerState: (self: PlayerStateController, PlayerState.PlayerState) -> (),
}

export type PlayerStateController = typeof(setmetatable(
    {} :: {
        Humanoid: Humanoid?,
        Camera: Camera?
    },
    {} :: IPlayerStateController
))

local PlayerStateController: IPlayerStateController = {} :: IPlayerStateController
PlayerStateController.__index = PlayerStateController

function PlayerStateController.new()
    local self: PlayerStateController = setmetatable({}, PlayerStateController)

    return self
end

function PlayerStateController:GetPlayerState()

end

return PlayerStateController