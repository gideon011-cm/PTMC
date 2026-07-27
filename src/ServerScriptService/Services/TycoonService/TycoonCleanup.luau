--!nocheck

--[[
    Simply undones everything
]]
local function TycoonCleanup(tycoon : Model)
    tycoon:SetAttribute("Claimed", nil)

    local billboardGui = tycoon.BillboardGui
    billboardGui.FaceImage.Image = ""

    for _, object in pairs(tycoon:GetChildren()) do
        object:Destroy()
    end
end

return TycoonCleanup