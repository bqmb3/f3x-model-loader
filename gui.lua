local F3X = loadstring(game:HttpGet("https://raw.githubusercontent.com/bqmb3/f3x-wrapper/main/loader.lua",true))()
local ModelLoader = loadstring(game:HttpGet("https://raw.githubusercontent.com/bqmb3/f3x-model-loader/main/main.lua",true))()
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local plr = game:GetService("Players").LocalPlayer

local Window = Rayfield:CreateWindow({
    Name = "Model Loader by bqmb3",
    LoadingTitle = "f3x-model-loader",
    LoadingSubtitle = "by bqmb3",
    ConfigurationSaving = { Enabled = false },
    Discord = {
       Enabled = true,
       Invite = "hhKKS9VGnR",
       RememberJoins = true
    },
    KeySystem = false
})
local loading = false
local Tab = Window:CreateTab("Load model")
local AnchorAll
local Input Input = Tab:CreateInput({
    Name = "Model Id",
    PlaceholderText = "rbxassetid://...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        if loading then
            Input:Set("")
            return Rayfield:Notify({
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
            return Rayfield:Notify({
                Title = "Error",
                Content = "You must set a valid asset ID",
                Duration = 5,
            })
        end
        loading = true
        Input:Set(ModelId)
        local parts = ModelLoader:LoadObjects(objects, workspace, {["AnchorAll"] = AnchorAll.CurrentValue})
        loading = false
        Rayfield:Notify({
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
                            Rayfield:Notify({
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
                        Rayfield:Notify({
                            Title = "Model Loader",
                            Content = "Removed "..#parts.. " parts.",
                            Duration = 0
                        })
                    end
                }
            },
         })
    end,
})

AnchorAll = Tab:CreateToggle({
    Name = "Anchor all",
    CurrentValue = false,
    Callback = function() end
})