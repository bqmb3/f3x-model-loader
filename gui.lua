local F3X = loadstring(game:HttpGet("https://raw.githubusercontent.com/bqmb3/f3x-wrapper/main/loader.lua",true))()
local ModelLoader = loadstring(game:HttpGet("https://raw.githubusercontent.com/bqmb3/f3x-model-loader/main/main.lua",true))()
local ArrayField = loadstring(game:HttpGet('https://raw.githubusercontent.com/UI-Interface/ArrayField/main/Source.lua'))()
local plr = game:GetService("Players").LocalPlayer
local http = game:GetService("HttpService")

local Window = ArrayField:CreateWindow({
    Name = "Model Loader by bqmb3",
    LoadingTitle = "f3x-model-loader",
    LoadingSubtitle = "by bqmb3",
    ConfigurationSaving = { Enabled = false },
    Discord = {
       Enabled = true,
       Invite = "hhKKS9VGnR",
       RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Key = {"null"}
    }
})

local AnchorAll
function loadObjects(objects)
    local parts = ModelLoader:LoadObjects(objects, workspace, {["AnchorAll"] = AnchorAll.CurrentValue})
    ArrayField:Notify({
        Title = "Model Loader",
        Content = "Loaded "..#parts.." parts.",
        Duration = 5,
        Actions = {
            Teleport = {
                Name = "Teleport to model",
                Callback = function()
                    if parts[1] then
                        local char = plr.Character or plr.CharacterAdded:Wait()
                        char.HumanoidRootPart.CFrame = parts[1].CFrame
                    else
                        ArrayField:Notify({
                            Title = "Error",
                            Content = "Failed to teleport: Model does not have a part.",
                            Duration = 0
                        })
                    end
                end
            },
            Cancel = {
                Name = "Undo",
                Callback = function()
                    F3X:RemoveParts(parts)
                    ArrayField:Notify({
                        Title = "Model Loader",
                        Content = "Removed "..#parts.. " parts.",
                        Duration = 0
                    })
                end
            }
        },
    })
end

local loading = false
local Tab = Window:CreateTab("Load model")
local Input Input = Tab:CreateInput({
    Name = "Model Id",
    PlaceholderText = "rbxassetid://...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        if loading then
            Input:Set("")
            return ArrayField:Notify({
                Title = "Error",
                Content = "Another model is currently loading. Please wait.",
                Duration = 5,
            })
        end
        local ModelId = "rbxassetid://" .. Text:gsub('%D+', '')
        local success, objects = pcall(function()
            return game:GetObjects(ModelId)
        end)
        if not success then
            Input:Set("")
            return ArrayField:Notify({
                Title = "Error",
                Content = "You must set a valid asset ID",
                Duration = 5,
            })
        end
        loading = true
        Input:Set(ModelId)
        loading = false
    end,
})

AnchorAll = Tab:CreateToggle({
    Name = "Anchor all",
    CurrentValue = false,
    Callback = function() end
})

local searchResults = {}

local toolbox = Window:CreateTab("Toolbox")
local searching = false
toolbox:CreateInput({
    Name = "Model",
    PlaceholderText = "Search",
    RemoveTextAfterFocusLost = false,
    Callback = function(query)
        if searching then
            return ArrayField:Notify({
                Title = "Error",
                Content = 'Currently searching "'..searching..'", please wait.',
                Duration = 5,
            })
        end
        searching = query
        for _, btn in ipairs(searchResults) do
            btn:Destroy()
        end
        local searchResult = game:HttpGet("https://search.roblox.com/catalog/json?Category=6&Keyword="..http:UrlEncode(query))
        searchResult = http:JSONDecode(searchResult)
        for _, asset in ipairs(searchResult) do
            table.insert(searchResults, toolbox:CreateButton({
                Name = asset.Name.." by "..asset.Creator,
                Interact = 'Load',
                Callback = function()
                    loadObjects(game:GetObjects("rbxassetid://" .. tostring(asset.AssetId)))
                end,
            })) 
        end
        searching = false
    end,
})