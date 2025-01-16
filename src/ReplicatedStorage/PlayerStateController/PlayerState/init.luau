--!native
--!optimize 2
--!strict


type IPlayerState = {
    __index: IPlayerState,
    new: () -> PlayerState,
    Destroy: () -> (),
}

export type PlayerState = typeof(setmetatable(
    {} :: {
        
    },
    {} :: IPlayerState
))

local PlayerState: IPlayerState = {} :: IPlayerState
PlayerState.__index = PlayerState

return PlayerState