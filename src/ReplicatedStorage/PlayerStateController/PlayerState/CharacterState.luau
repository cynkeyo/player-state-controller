--!native
--!optimize 2
--!strict

type animationState = {
	looped: boolean,
	priority: Enum.AnimationPriority,
	speed: number,
	timePosition: number,
	targetWeight: number,
	animationObject: Animation,
}

type animatorState = {
	playingAnimationStates: { animationState },
}

type humanoidState = {
	stateType: Enum.HumanoidStateType,
	animatorState: animatorState,
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
		HumanoidState: humanoidState,
	},
	{} :: ICharacterState
))

local CharacterState: ICharacterState = {} :: ICharacterState
CharacterState.__index = CharacterState

local function createAnimationState()
	return {
		looped = false,
		priority = Enum.AnimationPriority.Idle,
		speed = 1,
		timePosition = 0,
		targetWeight = 0,
		animationObject = Instance.new("Animation"),
	}
end

local function createAnimatorState()
	return {
		playingAnimationStates = {},
	}
end

local function createHumanoidState()
	return {
		stateType = Enum.HumanoidStateType.None,
		animatorState = createAnimatorState(),
	}
end

function CharacterState.new()
	local self = setmetatable({}, CharacterState)

	self.RootCFrame = CFrame.new()
	self.RootLinearVelocity = Vector3.new()
	self.RootAngularVelocity = Vector3.new()
	self.HumanoidState = createHumanoidState()

	return self
end

-- holy boilerplate lol
local function getCharacterComponents(Character: Model): (Humanoid, BasePart, Animator)
	if not Character:IsA("Model") then
		error("The passed character isn't of type Model.")
	end

	local Humanoid: Instance? = Character:FindFirstChild("Humanoid")

	if not Humanoid then
		error("The passed Character doesn't have a Humanoid")
	end

	if not Humanoid:IsA("Humanoid") then
		error("Found a Humanoid instance, but isn't of type Humanoid.")
	end

	local RootPart = Humanoid.RootPart

	if not RootPart then
		error("Character doesn't have a root part.")
	end

	local Animator: Instance? = Humanoid:FindFirstChild("Animator")

	if not Animator then
		error("Humanoid doesn't have an animator")
	end

	if not Animator:IsA("Animator") then
		error("Found an Animator, but isn't of type Animator.")
	end

	return Humanoid, RootPart, Animator
end

local function createAnimatorStateFromAnimator(Animator: Animator)
	if not Animator then
		error("Expected a Animator instance, got nil.")
	end

	local animatorState = createAnimatorState()
	local playingAnimationStates = animatorState.playingAnimationStates

	for _, AnimationTrack in pairs(Animator:GetPlayingAnimationTracks()) do
		local animationState = createAnimationState()

		animationState.targetWeight = AnimationTrack.WeightTarget
		animationState.looped = AnimationTrack.Looped
		animationState.priority = AnimationTrack.Priority
		animationState.speed = AnimationTrack.Speed
		animationState.timePosition = AnimationTrack.Speed
		animationState.animationObject = AnimationTrack.Animation:Clone() -- Mutation of the original object will also change this animation if it isn't cloned

		table.insert(playingAnimationStates, animationState)
	end

	return animatorState
end

function CharacterState.fromCharacter(Character)
	local Humanoid, RootPart, Animator = getCharacterComponents(Character)

	local self = CharacterState.new()

	local animatorState = createAnimatorStateFromAnimator(Animator)

	local humanoidState = createHumanoidState()
	humanoidState.stateType = Humanoid:GetState()
	humanoidState.animatorState = animatorState

	self.RootCFrame = RootPart.CFrame
	self.RootLinearVelocity = RootPart.AssemblyLinearVelocity
	self.RootAngularVelocity = RootPart.AssemblyAngularVelocity
	self.HumanoidState = humanoidState

	return self
end

local function clearAnimatorAnimations(Animator: Animator)
	if not Animator then
		error("Expected a Animator instance, got nil.")
	end

	for _, AnimationTrack in pairs(Animator:GetPlayingAnimationTracks()) do
		AnimationTrack:Stop(0)
	end
end

local function playAnimationsFromAnimatorState(Animator: Animator, animatorState: animatorState)
	if not Animator then
		error("Expected a Animator instance, got nil.")
	end

	if not animatorState then
		error("Expected an animator state object, got nil.")
	end

	local playingAnimationStates = animatorState.playingAnimationStates

	for _, animationState in pairs(playingAnimationStates) do
		local animationTrack = Animator:LoadAnimation(animationState.animationObject)

		animationTrack:Play(0, animationState.targetWeight, animationState.speed)
		animationTrack.TimePosition = animationState.timePosition
	end
end

function CharacterState:SetToCharacter(Character)
	local Humanoid, RootPart, Animator = getCharacterComponents(Character)

	local humanoidState = self.HumanoidState
	local animatorState = humanoidState.animatorState

	clearAnimatorAnimations(Animator)

	RootPart.CFrame = self.RootCFrame
	RootPart.AssemblyLinearVelocity = self.RootLinearVelocity
	RootPart.AssemblyAngularVelocity = self.RootAngularVelocity

	playAnimationsFromAnimatorState(Animator, animatorState)

	Humanoid:ChangeState(humanoidState.stateType)
end

function CharacterState:Destroy()
	table.freeze(self)
	table.clear(self)
	setmetatable(self, nil)
end

return CharacterState
