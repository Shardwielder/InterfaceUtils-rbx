--[[
    Call `roundElement` (guiObject: instance, cornerRadius: number) to convert
    any Frame, ImageLabel, or ImageButton into one with a rounded background of
    `cornerRadius`.

    If the instance is a Frame, it will be replaced with an ImageLabel
    of the same transferrable properties. The BackgroundColor3 and BackgroundTransparency
    properties of the Frame will be used as the basis for the ImageColor3 and
    ImageTransparency properties of the generated ImageLabel.
]]

local NON_NUMERICAL_ERROR = "Bad argument %s to %s: must be a number"
local NON_COMPATIBLE_GUI_ERROR = "Bad argument %s to %s: must be a ImageLabel, ImageButton, or Frame"
local IMPOSSIBLE_RADIUS_ERROR = "Bad argument %s to %s: corner radius must be greater than 0"
local NO_RADIUS_ERROR = "Bad argument %s to %s: no image present for a corner radius of %s"

--[[
    The key for each entry corresponds to the corner radius of the
    image asset (value). The  foreground of the image must be completely white,
    the background completely transparent, and the image fully circular
    (with a diameter of key cornerRadius) or else unexpected results will appear.
]]
local CIRCULAR_IMAGES = {
    [2] = "rbxassetid://4900818720",
    [3] = "rbxassetid://4900818812",
    [4] = "rbxassetid://4900818868",
    [5] = "rbxassetid://4900818934",
    [6] = "rbxassetid://4900818981",
    [7] = "rbxassetid://4900818981",
    [8] = "rbxassetid://4900819077",
    [9] = "rbxassetid://4900819126",
    [10] = "rbxassetid://4900819170",
}

local transitionableProperties = {
    "ZIndex", "ClipsDescendants", "Visible", "AutoLocalize", "RootLocalizationTable", "LayoutOrder",
    "Name", "Size", "Position", "AnchorPoint", "Rotation", "Active", "Selectable",
}

local RoundCorners = {}

local function prepareGuiObject(imageAssetId, guiObject, cornerRadius)
    if guiObject.ClassName == "Frame" then
        local newGuiObject = Instance.new("ImageLabel")
        for i, propertyName in ipairs(transitionableProperties) do
            newGuiObject[propertyName] = guiObject[propertyName]
        end
        newGuiObject.ImageColor3 = guiObject.BackgroundColor3
        newGuiObject.ImageTransparency = guiObject.BackgroundTransparency
        for i, instance in pairs(guiObject:GetChildren()) do
            instance.Parent = newGuiObject
        end
        newGuiObject.Parent = guiObject.Parent
        guiObject:Destroy()
        guiObject = newGuiObject
    elseif guiObject.ClassName ~= "ImageButton" and guiObject.ClassName ~= "ImageLabel" then
        return
    end

    guiObject.BackgroundTransparency = 1
    guiObject.BorderSizePixel = 0
    guiObject.Image = imageAssetId
    guiObject.ScaleType = Enum.ScaleType.Slice
    guiObject.SliceCenter = Rect.new(cornerRadius, cornerRadius, cornerRadius, cornerRadius)
    guiObject.SliceScale = 1
    return guiObject
end

--[[
    Give the `guiObject` Frame, ImageLabel, or ImageButton instance a rounded
    background of `cornerRadius`

    Returns the rounded version of the `guiObject` instance. This may be a different object
    if the instance had to be converted, such as from a Frame to an ImageLabel.
]]
function RoundCorners.roundElement(guiObject, cornerRadius)
    assert(guiObject, NON_COMPATIBLE_GUI_ERROR:format("#1 guiObject", "RoundCorners.roundElement"))
    assert(type(cornerRadius) == "number", NON_NUMERICAL_ERROR:format("#2 cornerRadius", "RoundCorners.roundElement"))
    assert(cornerRadius > 0, IMPOSSIBLE_RADIUS_ERROR:format("#2 cornerRadius", "RoundCorners.roundElement"))

    local imageAssetId = CIRCULAR_IMAGES[cornerRadius]
    assert(imageAssetId, NO_RADIUS_ERROR:format("#2 cornerRadius", "RoundCorners.roundElement", cornerRadius))

    guiObject = prepareGuiObject(imageAssetId, guiObject, cornerRadius)
    assert(guiObject, NON_COMPATIBLE_GUI_ERROR:format("#1 guiObject", "RoundCorners.roundElement"))

    return guiObject
end

return RoundCorners