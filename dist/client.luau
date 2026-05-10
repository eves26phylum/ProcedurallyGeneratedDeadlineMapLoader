-- bundled with deadline-ts (no you cannot use rbxts modules right now)
function assert(condition, messageIfFalse)
    if not condition then error(messageIfFalse or _VERSION.." assertion error") end
end
local unpack = table.unpack
local old_require = require
local __modulesFolder = {}
local __modulesCachedValues = {}

local function newFakeInstance(pathSegs)
	pathSegs = pathSegs or {}
	local inst = {}
	inst.__path = pathSegs
	inst.Name = pathSegs[#pathSegs] or ""
	inst.WaitForChild = function(self, name)
		local newPath = {}
		for i = 1, #pathSegs do newPath[i] = pathSegs[i] end
		newPath[#newPath + 1] = name
		return newFakeInstance(newPath)
	end
	if #pathSegs > 1 then
		local parentSegs = {}
		for i = 1, #pathSegs - 1 do parentSegs[i] = pathSegs[i] end
		inst.Parent = newFakeInstance(parentSegs)
	else
		inst.Parent = {
			__path = {},
			Name = "",
			WaitForChild = function(self, name) return newFakeInstance({ name }) end,
		}
		inst.is_fake_instance = true
	end
	return inst
end
local old_game = game
local game = {
	GetService = function(self, name)
		local inst = newFakeInstance({ name })
		inst.__isService = true
		return inst
	end,
}

local require = function(_ref)
	return {
		import = function(_ctx, startModule, ...)
			local current = startModule.__isService and newFakeInstance({}) or startModule
			for i = 1, select("#", ...) do
				local seg = select(i, ...)
				if seg ~= "TS" then
					current = current:WaitForChild(seg)
				end
			end

			local pathSegs = current.__path
			local cacheKey = table.concat(pathSegs, "\0")

			if __modulesCachedValues[cacheKey] ~= nil then
				return __modulesCachedValues[cacheKey]
			end

			local folder = __modulesFolder
			for _, seg in ipairs(pathSegs) do
				folder = folder[seg]
				if folder == nil then
					error("TS.import: module not found at path \"" .. table.concat(pathSegs, "/") .. "\"")
				end
			end

			local result = folder()
			__modulesCachedValues[cacheKey] = result
			return result
		end,
	}
end

task.defer(function()
	local script
	script = newFakeInstance({"main"})
	-- Compiled with roblox-ts v3.0.0
	-- !deadline-ts.customFinishSector_FinishModulesEnd
	local require = old_require
	local old_require = nil
	local newFakeInstance = nil
	local game = old_game
	local old_game = nil
	local __modulesFolder = nil
	set_require_domain("https://raw.githubusercontent.com/eves26phylum/ProcedurallyGeneratedDeadlineMap_TS/main/deadlineout/")
	require("client.luau")

end)
