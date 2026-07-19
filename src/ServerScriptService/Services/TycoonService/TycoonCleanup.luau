--[[
    Simply undones everything
]]
local function TycoonCleanup(tycoon : Model)
    tycoon:SetAttribute("Claimed", nil)

    local billboardGui = tycoon.BillboardGui
    billboardGui.FaceImage.Image = ""
end

return TycoonCleanup