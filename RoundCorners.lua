--[[
    Call `roundElement` (guiObject: instance, cornerRadius: number) to convert
    any Frame, ImageLabel, or ImageButton into one with a rounded background of
    `cornerRadius`.

    If the instance is a Frame, it will be replaced with an ImageLabel
    of the same transferrable properties. The BackgroundColor3 and BackgroundTransparency
    properties of the Frame will be used as the basis for the ImageColor3 and
    ImageTransparency properties of the generated ImageLabel.
]]

local INCOMPATIBLE_GUI_ERRORR = "Bad argument #1 `guiObject`: must be a Frame, ImageLabel, or ImageButton"

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

local INHERITABLE_PROPERTIES = {
    "ZIndex", "ClipsDescendants", "Visible", "AutoLocalize", "RootLocalizationTable", "LayoutOrder",
    "Name", "Size", "Position", "AnchorPoint", "Rotation", "Active", "Selectable",
}

local RoundCorners = {}

local function prepareGuiObject(imageAssetId, guiObject, cornerRadius)
    if guiObject.ClassName == "Frame" then
        local newGuiObject = Instance.new("ImageLabel")
        for i, propertyName in ipairs(INHERITABLE_PROPERTIES) do
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

    Alternatively, the 1st argument `guiObject` can be an array of GUI instances which you
    would like to round with the same corner radius. This is only intended for use with ImageLabel
    and ImageButton instances, as Frames will have to be converted into an ImageLabel,
    and you will not have a reference to the new instance.

    If the `cornerRadius` is 0, the original GUI instance is returned without any modifications.
]]
local function roundElement(guiObject, cornerRadius)
    assert(type(cornerRadius) == "number", "Bad argument #2 `cornerRadius`: must be a number")

    if type(guiObject) == "table" then
        for k, object in pairs(guiObject) do
            roundElement(object, cornerRadius)
        end
        return
    else
        assert(guiObject, INCOMPATIBLE_GUI_ERRORR)
    end

    if cornerRadius == 0 then
        return guiObject
    end

    local imageAssetId = CIRCULAR_IMAGES[cornerRadius]
    assert(imageAssetId, "Bad argument #2 `cornerRadius`: no image asset for that radius could be found in `CIRCULAR_IMAGES`")

    guiObject = prepareGuiObject(imageAssetId, guiObject, cornerRadius)
    assert(guiObject, INCOMPATIBLE_GUI_ERRORR)

    return guiObject
end
RoundCorners.roundElement = roundElement

return RoundCorners