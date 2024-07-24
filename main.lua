--- This module loads client-side or external models by rebuilding them using F3X.
-- @module f3x-model-loader
-- @author bqmb3
-- @license MIT
-- @copyright bqmb3 2024

local ModelLoader = {}
local F3X = loadstring(game:HttpGet("https://raw.githubusercontent.com/bqmb3/f3x-wrapper/main/loader.lua",true))()

local classNameMappings = {
    ["TrussPart"] = "Truss",
    ["WedgePart"] = "Wedge",
    ["CornerWedgePart"] = "Corner",
    ["Seat"] = "Seat",
    ["VehicleSeat"] = "VehicleSeat",
    ["SpawnLocation"] = "SpawnLocation"
}

local shapeMappings = {
    [Enum.PartType.Cylinder] = "Cylinder",
    [Enum.PartType.Ball] = "Ball",
    [Enum.PartType.Wedge] = "Wedge",
    [Enum.PartType.CornerWedge] = "Corner"
}

--- Loads client-side objects
-- @tparam {Instance,...} objects Table of objects to load
-- @tparam[opt=workspace] Instance parent Parent of loaded parts
-- @treturn {Instance,...} Loaded parts
function ModelLoader:LoadObjects(objects, parent)
    local totalParts = {}
    local goal = 0
    parent = parent or workspace

    local partsToRename = {}
    local partNames = {}
    local partResizes = {}
    local partColors = {}
    local partSurfaces = {}
    local partLights = {}
    local partLightProperties = {}
    local partDecorations = {}
    local partDecorationProperties = {}
    local partMeshes = {}
    local partMeshProperties = {}
    local partTextures = {}
    local partTextureProperties = {}
    local partAnchor = {}
    local partCollisions = {}
    local partMaterials = {}

    for _, obj in ipairs(objects) do
        for _, desc in ipairs(obj:GetDescendants()) do
            if desc:IsA("BasePart") then
                goal += 1
                table.insert(partsToRename, desc)
                table.insert(partNames, desc.Name)
                coroutine.wrap(function()
                    local partType = "Normal"
                    if classNameMappings[desc.ClassName] then
                        partType = classNameMappings[desc.ClassName]
                    elseif desc:IsA("Part") and shapeMappings[desc.Shape] then
                        partType = shapeMappings[desc.Shape]
                    end
                    local part = F3X:CreatePart(partType, desc.CFrame, parent)
                    table.insert(partResizes, {["Part"] = part, ["CFrame"] = desc.CFrame, ["Size"] = desc.Size})
                    table.insert(partColors, {["Part"] = part, ["Color"] = desc.Color})
                    table.insert(partSurfaces, {["Part"] = part, {
                        ["Top"] = desc.TopSurface,
                        ["Front"] = desc.FrontSurface,
                        ["Bottom"] = desc.BottomSurface,
                        ["Right"] = desc.RightSurface,
                        ["Left"] = desc.LeftSurface,
                        ["Back"] = desc.BackSurface
                    }})

                    local SpotLight = desc:FindFirstChildOfClass("SpotLight")
                    local PointLight = desc:FindFirstChildOfClass("PointLight")
                    local SurfaceLight = desc:FindFirstChildOfClass("SurfaceLight")
                    if SpotLight then
                        table.insert(partLights, {["Part"] = part, ["LightType"] = "SpotLight"})
                        table.insert(partLightProperties, {
                            ["Part"] = part,
                            ["LightType"] = "SpotLight",
                            ["Angle"] = SpotLight.Angle,
                            ["Brightness"] = SpotLight.Brightness,
                            ["Color"] = SpotLight.Color,
                            ["Face"] = SpotLight.Face,
                            ["Range"] = SpotLight.Range,
                            ["Shadows"] = SpotLight.Shadows
                        })
                    end
                    if PointLight then
                        table.insert(partLights, {["Part"] = part, ["LightType"] = "PointLight"})
                        table.insert(partLightProperties, {
                            ["Part"] = part,
                            ["LightType"] = "PointLight",
                            ["Brightness"] = PointLight.Brightness,
                            ["Color"] = PointLight.Color,
                            ["Shadows"] = PointLight.Shadows
                        })
                    end
                    if SurfaceLight then
                        table.insert(partLights, {["Part"] = part, ["LightType"] = "SurfaceLight"})
                        table.insert(partLightProperties, {
                            ["Part"] = part,
                            ["LightType"] = "SurfaceLight",
                            ["Angle"] = SurfaceLight.Angle,
                            ["Brightness"] = SurfaceLight.Brightness,
                            ["Color"] = SurfaceLight.Color,
                            ["Face"] = SurfaceLight.Face,
                            ["Range"] = SurfaceLight.Range,
                            ["Shadows"] = SurfaceLight.Shadows
                        })
                    end

                    local Smoke = desc:FindFirstChildOfClass("Smoke")
                    local Fire = desc:FindFirstChildOfClass("Fire")
                    local Sparkles = desc:FindFirstChildOfClass("Sparkles")
                    if Smoke then
                        table.insert(partDecorations, {["Part"] = part, ["DecorationType"] = "Smoke"})
                        table.insert(partDecorationProperties, {
                            ["Part"] = part,
                            ["DecorationType"] = "Smoke",
                            ["Color"] = Smoke.Color,
                            ["Opacity"] = Smoke.Opacity,
                            ["RiseVelocity"] = Smoke.RiseVelocity,
                            ["Size"] = Smoke.Size
                        })
                    end
                    if Fire then
                        table.insert(partDecorations, {["Part"] = part, ["DecorationType"] = "Fire"})
                        table.insert(partDecorationProperties, {
                            ["Part"] = part,
                            ["DecorationType"] = "Fire",
                            ["Color"] = Fire.Color,
                            ["SecondaryColor"] = Fire.SecondaryColor,
                            ["Size"] = Fire.Size
                        })
                    end
                    if Sparkles then
                        table.insert(partDecorations, {["Part"] = part, ["DecorationType"] = "Sparkles"})
                        table.insert(partDecorationProperties, {
                            ["Part"] = part,
                            ["DecorationType"] = "Sparkles",
                            ["SparkleColor"] = Sparkles.SparkleColor
                        })
                    end

                    if desc:IsA("MeshPart") and desc.MeshId ~= "" then
                        table.insert(partMeshes, {["Part"] = part})
                        table.insert(partMeshProperties, {
                            ["Part"] = part,
                            ["MeshType"] = Enum.MeshType.FileMesh,
                            ["MeshId"] = desc.MeshId,
                            ["TextureId"] = desc.TextureId
                        })
                    end
                    local BlockMesh = desc:FindFirstChildOfClass("BlockMesh")
                    local SpecialMesh = desc:FindFirstChildOfClass("SpecialMesh")
                    if BlockMesh then
                        table.insert(partMeshes, {["Part"] = part})
                        table.insert(partMeshProperties, {
                            ["Part"] = part,
                            ["MeshType"] = Enum.MeshType.Brick,
                            ["Scale"] = BlockMesh.Scale,
                            ["Offset"] = BlockMesh.Offset,
                            ["VertexColor"] = BlockMesh.VertexColor
                        })
                    end
                    if SpecialMesh then
                        table.insert(partMeshes, {["Part"] = part})
                        table.insert(partMeshProperties, {
                            ["Part"] = part,
                            ["MeshType"] = SpecialMesh.MeshType,
                            ["MeshId"] = SpecialMesh.MeshId,
                            ["TextureId"] = SpecialMesh.TextureId,
                            ["Scale"] = SpecialMesh.Scale,
                            ["Offset"] = SpecialMesh.Offset,
                            ["VertexColor"] = SpecialMesh.VertexColor
                        })
                    end

                    for _, texture in ipairs(desc:GetChildren()) do
                        if texture:IsA("Texture") then
                            table.insert(partTextures, {["Part"] = part, ["Face"] = texture.Face, ["TextureType"] = "Texture"})
                            table.insert(partTextureProperties, {
                                ["Part"] = part,
                                ["Face"] = texture.Face,
                                ["TextureType"] = "Texture",
                                ["Texture"] = texture.Texture,
                                ["Transparency"] = texture.Transparency,
                                ["StudsPerTileU"] = texture.StudsPerTileU,
                                ["StudsPerTileV"] = texture.StudsPerTileV
                            })
                        elseif texture:IsA("Decal") then
                            table.insert(partTextures, {["Part"] = part, ["Face"] = texture.Face, ["TextureType"] = "Decal"})
                            table.insert(partTextureProperties, {
                                ["Part"] = part,
                                ["Face"] = texture.Face,
                                ["TextureType"] = "Decal",
                                ["Texture"] = texture.Texture,
                                ["Transparency"] = texture.Transparency
                            })
                        end
                    end

                    if not desc.Anchored then
                        table.insert(partAnchor, {["Part"] = part, ["Anchored"] = false})
                    end

                    if not desc.CanCollide then
                        table.insert(partCollisions, {["Part"] = part, ["CanCollide"] = false})
                    end

                    table.insert(partMaterials, {
                        ["Part"] = part,
                        ["Material"] = desc.Material,
                        ["Transparency"] = desc.Transparency,
                        ["Reflectance"] = desc.Reflectance
                    })

                    table.insert(totalParts, part)
                end)()
            end
        end
    end

    repeat task.wait() until #totalParts == goal

    local tasks = {
        function() F3X:SetNames(partsToRename, partNames) end,
        function() F3X:ResizeParts(partResizes) end,
        function() F3X:SetColors(partColors) end,
        function() F3X:SetPartsSurfaces(partSurfaces) end,
        
        function()
            F3X:CreateLights(partLights)
            F3X:SetLights(partLightProperties)
        end,
        
        function()
            F3X:CreateDecorations(partDecorations)
            F3X:SetDecorations(partDecorationProperties)
        end,

        function()
            F3X:CreateMeshes(partMeshes)
            F3X:SetMeshes(partMeshProperties)
        end,

        function()
            F3X:CreateTextures(partTextures)
            F3X:SetTextures(partTextureProperties)
        end,

        function() F3X:SetAnchors(partAnchor) end,
        function() F3X:SetCollisions(partCollisions) end,
        function() F3X:SetMaterials(partMaterials) end,
    }
    local tasksDone = 0
    for _, t in ipairs(tasks) do
        coroutine.wrap(function()
            t()
            tasksDone += 1
        end)()
    end

    repeat task.wait() until tasksDone == #tasks

    return totalParts
end

return ModelLoader