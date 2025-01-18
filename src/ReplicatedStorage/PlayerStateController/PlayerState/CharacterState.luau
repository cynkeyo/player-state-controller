--!native
--!optimize 2

local RunService = game:GetService("RunService")

type AnimatorMethods = {
	ToggleExternalState: (boolean) -> (),
	IsExposed: () -> boolean,
	SetState: (animatorState) -> (),
	GetCurrentState: () -> animatorState,
	__exposed: boolean,
}

export type animatorState = {
	currentPose: string,
	currentAnimName: string,
	currentTimePosition: number,
	animFadeTime: number,
	animSpeed: number,
	jumpAnimTime: number,
}

type motorTransforms = {
	RootJoint: CFrame,
	Neck: CFrame,
	LeftShoulder: CFrame,
	LeftHip: CFrame,
	RightShoulder: CFrame,
	RightHip: CFrame,
}

type ICharacterState = {
	__index: ICharacterState,
	new: () -> CharacterState,
	fromCharacter: (Character: Model) -> CharacterState,
	SetToCharacter: (self: CharacterState, Character: Model) -> (),
	Destroy: (self: CharacterState) -> (),
}

export type CharacterState = typeof(setmetatable(
	{} :: {
		RootCFrame: CFrame,
		RootLinearVelocity: Vector3,
		RootAngularVelocity: Vector3,
		HumanoidState: Enum.HumanoidStateType,
		AnimatorState: animatorState,
		Motor6DTransforms: motorTransforms,
	},
	{} :: ICharacterState
))

local CharacterState = {}
CharacterState.__index = CharacterState

local function createMotorTransforms(): motorTransforms
	return {
		RootJoint = CFrame.new(),
		Neck = CFrame.new(),
		RightHip = CFrame.new(),
		RightShoulder = CFrame.new(),
		LeftHip = CFrame.new(),
		LeftShoulder = CFrame.new(),
	}
end

--[[
	@return @CharacterState CharacterState

	Creates a new blank CharacterState
]]
function CharacterState.new(): CharacterState
	local self = setmetatable({}, CharacterState)

	self.RootCFrame = CFrame.new()
	self.RootLinearVelocity = Vector3.new()
	self.RootAngularVelocity = Vector3.new()
	self.HumanoidState = Enum.HumanoidStateType.None
	self.Motor6DTransforms = createMotorTransforms()
	self.AnimatorState = {
		currentPose = "Standing",
		currentAnimName = "idle",
		currentTimePosition = 0,
		animFadeTime = 0.1,
		animSpeed = 1,
	}

	return self
end

local function getCharacterComponents(Character): (Humanoid, BasePart, LocalScript)
	local Humanoid = Character:FindFirstChild("Humanoid")

	if not Humanoid then
		error("Couldn't find a Humanoid for the provided character.")
	end

	local Animator = Character:FindFirstChild("Animate")

	return Humanoid, Humanoid.RootPart, Animator
end

-- These will be the parts that will have their body state saved.
local RIG_PARTS = {
	HumanoidRootPart = "HumanoidRootPart",
	Torso = "Torso",
	LeftLeg = "Left Leg",
	LeftArm = "Left Arm",
	RightLeg = "Right Leg",
	RightArm = "Right Arm",
	Head = "Right Arm",
}

local function getMotorTransformsFromCharacter(Character): motorTransforms
	local Torso = Character.Torso
	local HumanoidRootPart = Character.HumanoidRootPart

	return {
		RootJoint = HumanoidRootPart.RootJoint.Transform,
		Neck = Torso.Neck.Transform,
		RightHip = Torso["Right Hip"].Transform,
		RightShoulder = Torso["Right Shoulder"].Transform,
		LeftHip = Torso["Left Hip"].Transform,
		LeftShoulder = Torso["Left Shoulder"].Transform,
	}
end

--[[
	@param @Model Character
	@return @CharacterState CharacterState

	Creates a new CharacterState from the @param Character.

	The @param Character must be a R6 rig with a custom Animate script and a Humanoid.

	Custom animate script found at https://github.com/cynkeyo/player-state-controller.
]]
function CharacterState.fromCharacter(Character)
	local Humanoid, RootPart, Animator = getCharacterComponents(Character)

	local AnimatorMethods: AnimatorMethods = require(Animator.Methods)

	local self = setmetatable({}, CharacterState)

	RunService.PostSimulation:Wait()

	self.Motor6DTransforms = getMotorTransformsFromCharacter(Character)
	self.RootCFrame = RootPart.CFrame
	self.RootLinearVelocity = RootPart.AssemblyLinearVelocity
	self.RootAngularVelocity = RootPart.AssemblyAngularVelocity
	self.HumanoidState = Humanoid:GetState()
	self.AnimatorState = AnimatorMethods.GetCurrentState()

	return self
end

local function setCharacterMotors(Character, motorTransforms: motorTransforms)
	local Torso = Character.Torso
	local HumanoidRootPart = Character.HumanoidRootPart

	HumanoidRootPart.RootJoint.Transform = motorTransforms.RootJoint
	Torso.Neck.Transform = motorTransforms.Neck
	Torso["Right Hip"].Transform = motorTransforms.RightHip
	Torso["Right Shoulder"].Transform = motorTransforms.RightShoulder
	Torso["Left Hip"].Transform = motorTransforms.LeftHip
	Torso["Left Shoulder"].Transform = motorTransforms.LeftShoulder
end

--[[
	@param @Model Character

	Sets the @param Character state to match the CharacterState instance.

	This process is deffered to the next PreRender call.

	The @param Character must be a R6 rig with a custom Animate script and a Humanoid.
]]
function CharacterState:SetToCharacter(Character)
	local Humanoid, RootPart, Animator = getCharacterComponents(Character)

	local AnimatorMethods: AnimatorMethods = require(Animator.Methods)

	-- As we enter the next frame, override all of the engine changes with our desired saved state.
	-- This has to be deffered to the next PreRender call since otherwise we can't ensure a consistent entry point
	-- A consistent entry point is needed to set character state accurately.

	RunService.PreRender:Once(function()
		AnimatorMethods.ToggleExternalState(false)

		RootPart.CFrame = self.RootCFrame

		setCharacterMotors(Character, self.Motor6DTransforms)

		RootPart.AssemblyLinearVelocity = self.RootLinearVelocity
		RootPart.AssemblyAngularVelocity = self.RootAngularVelocity

		Humanoid:ChangeState(self.HumanoidState)

		AnimatorMethods.SetState(self.AnimatorState)

		-- This wait is needed since otherwise deffered connections will fire, playing unwanted animations.

		RunService.PreRender:Wait()

		AnimatorMethods.ToggleExternalState(true)
	end)
end

--[[
	Destroys the CharacterState instance.
]]
function CharacterState:Destroy()
	table.clear(self)
	setmetatable(self, nil)
	table.freeze(self)
end

return CharacterState
