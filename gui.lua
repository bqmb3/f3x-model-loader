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

local Tab = Window:CreateTab("Load model")
local Input Input = Tab:CreateInput({
    Name = "Model Id",
    PlaceholderText = "rbxassetid://...",
    OnEnter = true,
    RemoveTextAfterFocusLost = false,
    NumbersOnly = true,
    Callback = function(Text)
        local ModelId = "rbxassetid://" .. Text
        local success, objects = pcall(function()
            return game:GetObjects(ModelId)
        end)
        if not success then
            ArrayField:Notify({
                Title = "Error",
                Content = "You must set a valid asset ID",
                Duration = 5,
            })
            return error("Invalid asset ID")
        end
        Input:Lock("Loading...")
        loadObjects(objects)
        Input:Unlock()
    end,
})

AnchorAll = Tab:CreateToggle({
    Name = "Anchor all",
    CurrentValue = false,
    Callback = function() end
})

local searchResults = {}

local toolbox = Window:CreateTab("Toolbox")
local searchBar searchBar = toolbox:CreateInput({
    Name = "Model",
    PlaceholderText = "Search",
    OnEnter = true,
    RemoveTextAfterFocusLost = false,
    Callback = function(query)
        searchBar:Lock("Searching...")
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
        searchBar:Unlock()
    end,
})