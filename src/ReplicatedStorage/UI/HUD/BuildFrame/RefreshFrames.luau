local Template = require(script.Parent.Template)

local function refreshFrame(contanier : ScrollingFrame, storedObjects : {[string]: {any}})
    for name, objectData in pairs(storedObjects) do
        local template = Template({
            Amount = objectData.Amount,
            Name = name
        })

        template.Parent = contanier
    end
end

return refreshFrame