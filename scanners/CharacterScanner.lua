local AddonName, OrderTracker = ...;
OrderTracker.CharacterScanner = {};
local CharacterScanner = OrderTracker.CharacterScanner


function CharacterScanner:ScanByKey(characterKey)
    if not OrderTrackerDB.Characters[characterKey] then
        OrderTrackerDB.Characters[characterKey] = {
            name = UnitName("player"),
            realm = GetRealmName(),
            class = select(2, UnitClass("player")),
            professions = {}
        }
    end
end
