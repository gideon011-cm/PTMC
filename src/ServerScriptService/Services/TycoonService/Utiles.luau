local __THINGS = workspace:WaitForChild("__THINGS")
local Tycoons = __THINGS:WaitForChild("Tycoons")

local Utiles = {}

function Utiles:IsTycoonClaimed(tycoon : Model) : boolean
    local claimedAttribute = tycoon:GetAttribute("Claimed")

    return claimedAttribute and true or false
end

function Utiles:GetUnclaimedTycoon() : Model | nil?
    for _, tycoon : Model in pairs(Tycoons:GetChildren()) do
        local isClaimed = self:IsTycoonClaimed(tycoon)
        
        if not isClaimed then
            return tycoon
        end
    end

    return nil
end

function Utiles:GetTycoon(player : Player) : Model
    for _, tycoon : Model in pairs(Tycoons:GetChildren()) do
        local isClaimed = self:IsTycoonClaimed(tycoon)
        
        --[[
            Checks if it claimed and then checks if it claimed by the givin player
        ]]
        if isClaimed then
            local claimedByPlayer = tycoon:GetAttribute("Claimed") == player.UserId

            if claimedByPlayer then
                return tycoon
            end
        end
    end
end

return Utiles