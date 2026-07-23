local function Lerp(number1 : number, number2, lerpSpeed : number) : number
    return number1 + (number2 - number1) * lerpSpeed
end

return Lerp