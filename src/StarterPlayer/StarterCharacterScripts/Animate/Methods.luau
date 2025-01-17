--!native
--!optimize 2

--Exposes the character's animator methods for saving player state, and also setting animator state.
--Without this we are forced to rely on changing the character's animations through the animator which can cause unwanted side effects.

--This module is basically a container of the animators methods, being initialized by the animator itself.

export type animatorState = {
    currentPose: string,
    currentAnimName: string,
    currentTimePosition: number,
    animFadeTime: number,
    animSpeed: number,
    jumpAnimTime: number
}

type Methods = {
    ToggleExternalState: (boolean) -> (),
    IsExposed: () -> boolean,
    SetState: (animatorState) -> (),
    GetCurrentState: () -> (animatorState),
    __exposed: boolean
}

local Methods = {} :: Methods

--[[
    Returns a boolean indicating if the animator's methods are exposed and ready for use.
]]
function Methods.AreExposed()
    return Methods.__exposed
end

return Methods