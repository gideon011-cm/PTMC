local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ObjectPool = require(ReplicatedStorage.Shared.Modules.Classes.ObjectPool)

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Models = Assets:WaitForChild("Models")

local HealthGui = Models:WaitForChild("HealthbarUI")

local DAMAGE_BAR_DELAY = 0.8

local HEALTH_TWEEN_INFO = TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local DAMAGE_TWEEN_INFO = TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local HIGHLIGHT_IN_TWEEN_INFO = TweenInfo.new(
	0.08,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.Out
)

local HIGHLIGHT_OUT_TWEEN_INFO = TweenInfo.new(
	0.4,
	Enum.EasingStyle.Quint,
	Enum.EasingDirection.Out
)

local LOW_HEALTH_COLOR = Color3.fromRGB(255, 45, 55)
local MID_HEALTH_COLOR = Color3.fromRGB(255, 170, 35)
local HIGH_HEALTH_COLOR = Color3.fromRGB(45, 255, 125)
local DAMAGE_HIGHLIGHT_COLOR = Color3.fromRGB(243, 100, 107)

type HealthBar = {
	Model: Model,
	Gui: Instance,
	HighlightTemplate: Highlight?,
	HighlightPool: any?,
	HealthConnection: RBXScriptConnection,
	DestroyConnection: RBXScriptConnection,
	Destroy: (self: HealthBar) -> (),
	_Update: (self: HealthBar) -> (),
	_PulseHighlight: (self: HealthBar) -> (),
	_ScheduleDamageBar: (self: HealthBar, healthPercent: number) -> (),
	_destroyed: boolean,
	_updateId: number,
	_lastHealthPercent: number?,
	_healthTween: Tween?,
	_damageTween: Tween?,
	_stackedDamagePercent: number?,
}

local HealthBar = {}
HealthBar.__index = HealthBar

local function getHealthPercent(model: Model): number
	local health = model:GetAttribute("Health")
	local maxHealth = model:GetAttribute("MaxHealth")

	if maxHealth <= 0 then
		return 0
	end

	return math.clamp(health / maxHealth, 0, 1)
end

function HealthBar.new(model: Model, adornee : BasePart): HealthBar
	local gui = HealthGui:Clone()
	gui.Adornee = adornee or nil
	gui.Parent = model

	local highlight = gui.Highlight
	local highlightTemplate = nil
	local highlightPool = nil
	if highlight and highlight:IsA("Highlight") then
		highlightTemplate = highlight:Clone()
		highlightTemplate.Adornee = nil
		highlightTemplate.Parent = nil
		highlightPool = ObjectPool.new(highlightTemplate)
		highlight:Destroy()
	end

	local self = setmetatable({
		Model = model,
		Gui = gui,
		HighlightTemplate = highlightTemplate,
		HighlightPool = highlightPool,
		_destroyed = false,
		_updateId = 0,
		_lastHealthPercent = nil,
		_healthTween = nil,
		_damageTween = nil,
		_stackedDamagePercent = nil,
	}, HealthBar)

	self.HealthConnection = model:GetAttributeChangedSignal("Health"):Connect(function()
		self:_Update()
	end)

	self.DestroyConnection = model.Destroying:Connect(function()
		self:Destroy()
	end)

	self:_Update()

	return self
end

function HealthBar:_PulseHighlight()
	local highlightPool = self.HighlightPool
	if not highlightPool then
		return
	end

	local highlight = highlightPool:Get(self.Model) :: Highlight
	highlight.Adornee = self.Model
	highlight.FillColor = DAMAGE_HIGHLIGHT_COLOR
	highlight.FillTransparency = 0
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded

	local fadeIn = TweenService:Create(highlight, HIGHLIGHT_IN_TWEEN_INFO, {
		FillTransparency = 0.4,
		OutlineTransparency = 0.3,
	})

	fadeIn:Play()
	fadeIn.Completed:Once(function()
		if self._destroyed then
			return
		end

		local fadeOut = TweenService:Create(highlight, HIGHLIGHT_OUT_TWEEN_INFO, {
			FillTransparency = 1,
			OutlineTransparency = 1,
		})

		fadeOut:Play()
		fadeOut.Completed:Once(function()
			if self._destroyed then
				return
			end

			highlight.Adornee = nil
			highlightPool:Return(highlight)
		end)
	end)
end

function HealthBar:_ScheduleDamageBar(healthPercent: number)
	self._updateId += 1
	local updateId = self._updateId
	local white = self.Gui.Frame.White
	if not white or not white:IsA("GuiObject") then
		return
	end

	if self._damageTween then
		self._damageTween:Cancel()
		self._damageTween = nil
	end

	task.delay(DAMAGE_BAR_DELAY, function()
		if self._destroyed or self._updateId ~= updateId then
			return
		end

		self._damageTween = TweenService:Create(white, DAMAGE_TWEEN_INFO, {
			Size = UDim2.fromScale(healthPercent, 1),
		})
		self._damageTween:Play()
		self._damageTween.Completed:Once(function()
			if self._updateId == updateId then
				self._stackedDamagePercent = nil
			end
		end)
	end)
end

local function getHealthColor(healthPercent: number): Color3
	if healthPercent <= 0.5 then
		return LOW_HEALTH_COLOR:Lerp(MID_HEALTH_COLOR, healthPercent / 0.5)
	end

	return MID_HEALTH_COLOR:Lerp(HIGH_HEALTH_COLOR, (healthPercent - 0.5) / 0.5)
end

function HealthBar:_Update()
	local healthPercent = getHealthPercent(self.Model)
	local bar = self.Gui.Frame.Bar
	local white = self.Gui.Frame.White

	if not bar or not bar:IsA("GuiObject") then
		return
	end

	local oldHealthPercent = self._lastHealthPercent
	self._lastHealthPercent = healthPercent

	if self._healthTween then
		self._healthTween:Cancel()
	end

	self._healthTween = TweenService:Create(bar, HEALTH_TWEEN_INFO, {
		Size = UDim2.fromScale(healthPercent, 1),
		BackgroundColor3 = getHealthColor(healthPercent),
	})

	self._healthTween:Play()

	if oldHealthPercent == nil then
		if white and white:IsA("GuiObject") then
			white.Size = UDim2.fromScale(healthPercent, 1)
		end

		return
	end

	if white and white:IsA("GuiObject") then
		if healthPercent < oldHealthPercent then
			self:_PulseHighlight()
			self._stackedDamagePercent = math.max(self._stackedDamagePercent or 0, oldHealthPercent)
			white.Size = UDim2.fromScale(self._stackedDamagePercent, 1)
		else
			self._stackedDamagePercent = nil
			white.Size = UDim2.fromScale(healthPercent, 1)
		end
	end

	self:_ScheduleDamageBar(healthPercent)
end

function HealthBar:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true
	self._updateId += 1

	if self.HealthConnection then
		self.HealthConnection:Disconnect()
	end

	if self.DestroyConnection then
		self.DestroyConnection:Disconnect()
	end

	if self._damageTween then
		self._damageTween:Cancel()
	end

	if self._healthTween then
		self._healthTween:Cancel()
	end

	if self.HighlightPool then
		self.HighlightPool:Destroy()
	end

	if self.HighlightTemplate then
		self.HighlightTemplate:Destroy()
	end

	self.Gui:Destroy()
end

return HealthBar
