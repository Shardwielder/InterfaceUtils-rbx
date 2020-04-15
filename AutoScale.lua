--[[
    A module which allows for more flexible, automatic scaling than what is 
    provided using the Scale element of the GUI  instance size property.
    Utilises UIScale objects, which also allows for texts to scale automatically, 
    and much more precisely and nicely than using Scale sizing and TextScaled.

    Usage:
    - Design all interfaces in the same resolution, such as 1280x720. Only use
    Offset for the sizing and positioning, do not use Scale. Define the standard
    resolution that was used in `BASE_SCREEN_SIZE_X` and `BASE_SCREEN_SIZE_Y`.
    The portion of the screen that UI elements take up at this resolution will
    be the same portion they take up at any other resolution using this module.

    - Add any UI elements (GUI instances) that you want to be scaled by calling 
    `AutoScale.addElement` with the instance as the single parameter. Note
    that this will also cause *all of its children* to be scaled as well.
    Thus, it is best for performance to only use a single, root ScreenGui 
    as the only element you add; this will additionally mean you only need to
    call addElement once.

    - You can alternatively create a UIScale object in the root ScreenGui
    of your entire interface, and put it in the `scaleObjects` array.

    Tips:
    - Common resolutions are best used for the base resolution, such as 1920x1080.
    A 16:9 aspect ratio is advised.
    - The resolution can be forced in Studio by going to Test -> Device, selecting
    your chosen resolution, and then selecting "Fit to Window" in the header dropdown.
    - Anchor points must be utilised for any GUI elements which need to "hang" to any
    side of the screen; otherwise, the positioning will be inaccurate.
    - The `SNAP_RESOLUTION_STEP` variable defines the percentage increment at which
    the `BASE_SCREEN_SIZE` is scaled. This should be kept so that 
    BASE_SCREEN_SIZE * SNAP_RESOLUTION_STEP(n) always equals an integer, otherwise 
    images will lose their clarity.
]]

local RunService = game:GetService("RunService")

local BASE_SCREEN_SIZE_X = 1280
local BASE_SCREEN_SIZE_Y = 720

local SNAP_RESOLUTION_STEP = 0.05
local NON_INSTANCE_ERROR = "Bad argument %s to %s: must be an Instance"

local cameraObject = workspace.CurrentCamera
local scaleObjects = {}

local AutoScale = {}

--[[
    Add any GUI instance (and thus, all of its children) to be automatically scaled.
    It is suggested that this is done with a single base ScreenGui.
]]
function AutoScale.addElement(guiObject)
    assert(typeof(guiObject) == "Instance", NON_INSTANCE_ERROR:format("#1 guiObject", "AutoScale.addElement"))
    local scaleObject = Instance.new("UIScale")
    scaleObjects.Name = "AutoScreenScale"
    scaleObject.Scale = 1
    scaleObject.Parent = guiObject
    scaleObjects[#scaleObjects + 1] = scaleObject
end

-- Update all bound UIScale objects based on Y axis resolution scale
local function updateScaleObjects()
    local portionY = cameraObject.ViewportSize.Y / BASE_SCREEN_SIZE_Y
    local scaleY = math.floor(portionY / SNAP_RESOLUTION_STEP) * SNAP_RESOLUTION_STEP

    for i, scaleObject in ipairs(scaleObjects) do
        scaleObject.Scale = scaleY
    end
end
RunService.Heartbeat:connect(updateScaleObjects)

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    if workspace.CurrentCamera then
        cameraObject = workspace.CurrentCamera
    end
end)

return AutoScale