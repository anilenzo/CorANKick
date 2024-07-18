if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Kick
Kick = hookmetamethod(game.Players.LocalPlayer, "__namecall", function(Self, ...)
	if getnamecallmethod() == "Kick" then
		return
	end
	return Kick(Self, ...)
end)

--// Cache

local getgenv, getnamecallmethod, hookmetamethod, hookfunction, newcclosure, checkcaller, lower, gsub, match
	= getgenv, getnamecallmethod, hookmetamethod, hookfunction, newcclosure, checkcaller, string.lower, string.gsub, string.match;

--// Loaded check

if getgenv().ED_AntiKick then
	return
end

--// Variables

local cloneref = cloneref or function(...) return ... end -- PR NOTE: use for extra protection
local clonefunction = clonefunction or function(...) return ... end
local Players, LocalPlayer, StarterGui = cloneref(game:GetService("Players")), cloneref(game:GetService("Players").LocalPlayer), cloneref(game:GetService("StarterGui"))

local SetCore = clonefunction(StarterGui.SetCore)
local GetDebugId = clonefunction(game.GetDebugId)
local FindFirstChild = clonefunction(game.FindFirstChild) -- PR NOTE: this will be used to prevent kick baits relating to Unable to cast value to std::string

local compareinstances = (compareinstances and function(ins1, ins2)
		if typeof(ins1) == "Instance" and typeof(ins2) == "Instance" then
			return compareinstances(ins1, ins2);
		end
	end)
or
function(ins1, ins2)
	return (typeof(ins1) == "Instance" and typeof(ins2) == "Instance") and GetDebugId(ins1) == GetDebugId(ins2);
end;

local function CanCastToSTDString(val)
	-- PR NOTE: using FindFirstChild, this will make sure invalid arguments like newproxy() are sent through
	local success, err = pcall(FindFirstChild, game, val);
	return success --and not match(err, "Unable to cast value to std::string");
end

--// Global Variables

getgenv().ED_AntiKick = {
	Enabled = true, -- Set to false if you want to disable the Anti-Kick.
	SendNotifications = true, -- Set to true if you want to get notified for every event
	CheckCaller = false -- Set to true if you want to disable kicking by other executed scripts
}

--// Main

local OldNamecall;
OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
	local self, message = ...
	local method = getnamecallmethod()
	
	if ((getgenv().ED_AntiKick.CheckCaller and not checkcaller()) or true) and compareinstances(self, LocalPlayer) and gsub(method, "^%l", string.upper) == "Kick" and ED_AntiKick.Enabled then
		if CanCastToSTDString(message) then
			if getgenv().ED_AntiKick.SendNotifications then
				SetCore(StarterGui, "SendNotification", { -- PR NOTE: prevent stack overflow :)
					Title = "Exunys Developer",
					Text = "The script has successfully intercepted an attempted kick.",
					Icon = "rbxassetid://6238540373",
					Duration = 2,
				})
			end

			return; -- PR NOTE: calling :Kick() should return 0 args but returning nil will return 1 arg, bad news...
		end
	end

	return OldNamecall(...)
end))

local OldFunction;
OldFunction = hookfunction(LocalPlayer.Kick, function(...)
	local self, message = ...

	if ((getgenv().ED_AntiKick.CheckCaller and not checkcaller()) or true) and compareinstances(self, LocalPlayer) and ED_AntiKick.Enabled then
		if CanCastToSTDString(message) then
			if getgenv().ED_AntiKick.SendNotifications then
				SetCore(StarterGui, "SendNotification", { -- PR NOTE: prevent stack overflow :)
					Title = "Exunys Developer",
					Text = "The script has successfully intercepted an attempted kick.",
					Icon = "rbxassetid://6238540373",
					Duration = 2,
				})
			end

			return;
		end
	end
end)

if getgenv().ED_AntiKick.SendNotifications then
	StarterGui:SetCore("SendNotification", {
		Title = "Exunys Developer",
		Text = "Anti-Kick script loaded!",
		Icon = "rbxassetid://6238537240",
		Duration = 3,
	})
end

assert(getrawmetatable)
grm = getrawmetatable(game)
setreadonly(grm, false)
old = grm.__namecall
grm.__namecall = newcclosure(function(self, ...)
    local args = {...}
    if tostring(args[1]) == "TeleportDetect" then
        return
    elseif tostring(args[1]) == "CHECKER_1" then
        return
    elseif tostring(args[1]) == "CHECKER" then
        return
    elseif tostring(args[1]) == "GUI_CHECK" then
        return
    elseif tostring(args[1]) == "OneMoreTime" then
        return
    elseif tostring(args[1]) == "checkingSPEED" then
        return
    elseif tostring(args[1]) == "BANREMOTE" then
        return
    elseif tostring(args[1]) == "PERMAIDBAN" then
        return
    elseif tostring(args[1]) == "KICKREMOTE" then
        return
    elseif tostring(args[1]) == "BR_KICKPC" then
        return
    elseif tostring(args[1]) == "BR_KICKMOBILE" then
        return
    end
    return old(self, ...)
end)

local old
old = hookmetamethod(
    game,
    "__namecall",
    function(self, ...)
        local method = tostring(getnamecallmethod())
        if string.lower(method) == "kick" then
            return wait(9e9)
        end
        return old(self, ...)
    end
)

if getrawmetatable then
	function formatargs(getArgs,v)
		if #getArgs == 0 then 
			return "" 
		end
		
		local collectArgs = {}
		for k,v in next,getArgs do
			local argument = ""
			if type(v) == "string" then
				argument = "\""..v.."\""
			elseif type(v) == "table" then
				argument = "{" .. formatargs(v,true) .. "}"
			else
				argument = tostring(v)
			end
			if v and type(k) ~= "number" then
				table.insert(collectArgs,k.."="..argument)
			else
				table.insert(collectArgs,argument)
			end
		end
		return table.concat(collectArgs, ", ")
	end
	
	kicknum = 0
	local game_meta = getrawmetatable(game)
	local game_namecall = game_meta.__namecall
	local game_index = game_meta.__index
	local w = (setreadonly or fullaccess or make_writeable)
	pcall(w, game_meta, false)
	game_meta.__namecall = function(out, ...)
		local args = {...}
		local Method = args[#args]
		args[#args] = nil
		
		if Method == "Kick" and out == LP then
			kicknum = kicknum + 1
			warn("Blocked client-kick attempt "..kicknum)
			return
		end
		
		if antiremotes then
			if Method == "FireServer" or Method == "InvokeServer" then
				if out.Name ~= "CharacterSoundEvent" and out.Name ~= "SayMessageRequest" and out.Name ~= "AddCharacterLoadedEvent" and out.Name ~= "RemoveCharacterEvent" and out.Name ~= "DefaultServerSoundEvent" and out.Parent ~= "DefaultChatSystemChatEvents" then
					warn("Blocked remote: "..out.Name.." // Method: "..Method)
					return
				end
			end
		else
			if Method == "FireServer" or Method == "InvokeServer" then
				for i,noremote in pairs(blockedremotes) do
					if out.Name == noremote and out.Name ~= "SayMessageRequest" then
						warn("Blocked remote: "..out.Name.." // Method: "..Method)
						return
					end
				end
			end
		end
		
		if spyingremotes then
			if Method == "FireServer" or Method == "InvokeServer" then
				if out.Name ~= "CharacterSoundEvent" and out.Name ~= "AddCharacterLoadedEvent" and out.Name ~= "RemoveCharacterEvent" and out.Name ~= "DefaultServerSoundEvent" and out.Name ~= "SayMessageRequest" then
					local arguments = {}
					for i = 1,#args do
						arguments[i] = args[i]
					end
					local getScript = getfenv(2).script
					if getScript == nil then
						getScript = "??? (Not Found) ???"
					end
					warn("<> <> <> A "..out.ClassName.." has been fired! How to fire:\ngame."..out:GetFullName()..":"..Method.."("..formatargs(arguments)..")\n\nFired from script: ".. tostring(getScript:GetFullName()))
				end
			end
		end
		
		return game_namecall(out, ...)
	end
end
