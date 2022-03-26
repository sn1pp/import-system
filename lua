getgenv().all_modules = nil
getgenv().all_modules = loadstring()
local modules = {}
function modules:Init(m_config,m_functions_names,m_functions)
	if all_modules == nil then
		getgenv().all_modules = {}
		if m_config.name ~= nil and m_config.version ~= nil and m_config.developer ~= nil and m_config.state ~= nil then
			local module_num = 1
			all_modules[tostring(module_num)] = {
				config = m_config,
				func_names = m_functions_names,
				functions = m_functions
			}
		else
			warn('The configuration is broken, if you are a developer of this module, here is an example of a working build:\nlocal config = {name = "Example", version = "v1", developer = "Dummy", state = "Stable"}\nlocal function_names = {"example"}\nlocal functions = {["1"] = function(str) print(str) end}\n\nmodules:Init(config,function_names,functions)')	
		end
	else
		if m_config.name ~= nil and m_config.version ~= nil and m_config.developer ~= nil and m_config.state ~= nil then
			local module_num = 0
			for i,v in pairs(all_modules) do
				module_num = tonumber(i)
			end
			module_num += 1
			all_modules[tostring(module_num)] = {
				config = m_config,
				func_names = m_functions_names,
				functions = m_functions
			}
		else
			warn('The configuration is broken, if you are a developer of this module, here is an example of a working build:\nlocal config = {name = "Example", version = "v1", developer = "Dummy", state = "Stable"}\nlocal function_names = {"example"}\nlocal functions = {["1"] = function(str) print(str) end}\n\nmodules:Init(config,function_names,functions)')
		end
	end
end

function modules:import(module,to_import,global,dev)
	if module == nil then warn("Please specify a module.") return end
	local base
	for i,v in pairs(all_modules) do
		if v.config ~= nil then
			if v.config.name == module or (v.config.name == module and v.config.developer == dev) then
				base = v
				break
			end
		end
	end
	if base == nil then warn('The module is broken or not found.') return end
	module = base.config.name
	local imported = (typeof(to_import) == "table" and to_import) or {"all"}
	local returned = {["info"] = function()
		warn("Module info:\nName: "..tostring(base.config.name).."\nVersion: "..tostring(base.config.version).."\nDeveloper: "..tostring(base.config.developer).."\nState: "..tostring(base.config.state))
	end}

	if table.find(imported,"all") then
		local func_count = 0
		for _,v in pairs(base.functions) do
			if typeof(v) == "function" then
				func_count += 1
				if global then
					getgenv()[base.func_names[func_count]] = v
				else
					returned[base.func_names[func_count]] = v
				end
			end
		end
	else
		local func_count = 0
		for i,v in pairs(base.functions) do
			if typeof(v) == "function" then
				func_count += 1
				if base.func_names[func_count] == imported[func_count] then
					if global then
						getgenv()[base.func_names[func_count]] = v
					else
						returned[base.func_names[func_count]] = v
					end
				end
			end
		end
	end

	return returned
end

local config = {
	name = "Example",
	version = "v1",
	developer = "Dummy",
	state = "Stable"
}
local function_names = {
	"example",
}
local functions = {
	["1"] = function(str)
		print(str)
	end,
}
modules:Init(config,function_names,functions)

local ok = modules:import("Examples",{"example"},false,"Dummy")

ok.example("test")
