local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)

local objectPool = {}
objectPool.__index = objectPool

--[[
	Creates a new ObjectPool.

	The template is cloned whenever the pool
	doesn't have an unused object available.
]]
function objectPool.new(template: Instance)
	assert(template:IsA("Instance"), "ObjectPool template must be an Instance")

	local self = {
		template = template,

		pool = {},
		active = {},

		objectUnloaded = Signal.new(),
		objectLoaded = Signal.new(),
	}

	return setmetatable(self, objectPool)
end

--[[
	Gets an object from the pool.

	If there is an unused object available,
	it will be reused instead of cloning a new one.

	The parent is optional.
]]
function objectPool:Get(parent: Instance?): Instance
	local object = table.remove(self.pool)

	if not object then
		object = self.template:Clone()
	end

	if parent then
		object.Parent = parent
	end

	self.active[object] = true

	self.objectLoaded:Fire(object)

	return object
end

--[[
	Returns an object back to the pool.

	The object is removed from its parent
	and stored for future reuse.
]]
function objectPool:Return(object: Instance)
	if not self.active[object] then
		warn(`Attempted to return an object that isn't active: {object:GetFullName()}`)
		return
	end

	self.active[object] = nil

	object.Parent = nil

	table.insert(self.pool, object)

	self.objectUnloaded:Fire(object)
end

--[[
	Destroys all objects currently stored
	in the pool and all active objects.

	Also cleans up the signals.
]]
function objectPool:Destroy()
	for object in self.pool do
		object:Destroy()
	end

	for object in self.active do
		object:Destroy()
	end

	table.clear(self.pool)
	table.clear(self.active)

	self.objectUnloaded:Destroy()
	self.objectLoaded:Destroy()

	self.template = nil
end

return objectPool