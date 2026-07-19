local Players = game:GetService("Players")

local function setupTycoon(player : Player, tycoon : Model)
    -- Might be in testing phase so we need a random ID
    local playerUserId = player.UserId or math.random(1, 1000)
    --[[
        Claims the tycoon so noOne else can claim it
    ]]
    tycoon:SetAttribute("Claimed", player.UserId)

    local faceId = Players:GetUserThumbnailAsync(playerUserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size100x100)

    local billboardGui = tycoon.BillboardGui
    billboardGui.FaceImage.Image = faceId
end

return setupTycoon