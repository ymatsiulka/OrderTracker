local AddonName, OrderTracker = ...;
OrderTracker.CharacterExtensions = {};
local CharacterExtensions = OrderTracker.CharacterExtensions

function CharacterExtensions:GetCharacterKey()
    local playerName = UnitName("player")
    local realmName = GetRealmName()
    return playerName .. "-" .. realmName
end
