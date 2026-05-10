local AddonName, OrderTracker = ...;
OrderTracker.CharacterScanner = {};
local CharacterScanner = OrderTracker.CharacterScanner

function CharacterScanner:ScanByKey(characterKey)
    local playerName = UnitName("player");
    if not OrderTrackerDB.Characters[characterKey] then
        OrderTrackerDB.Characters[characterKey] = {
            name = playerName,
            realm = GetRealmName(),
            class = select(2, playerName),
            professions = {}
        }
    end
end
