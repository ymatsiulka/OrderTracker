-- ===== CONFIG =====
local AddonName, OrderTracker = ...;

local characterKey = OrderTracker.CharacterExtensions:GetCharacterKey()
OrderTracker.CharacterScanner:ScanByKey(characterKey)
OrderTracker.CharacterProfessionsScanner:ScanByKey(characterKey)

-- Subscribe on chat messages with delay to ensure data is loaded
C_Timer.After(1.0, function()
    local chatListener = CreateFrame("Frame")
    local chatListenerEvents = {"CHAT_MSG_CHANNEL", "CHAT_MSG_SAY"}
    for _, e in ipairs(chatListenerEvents) do
        chatListener:RegisterEvent(e)
    end

    chatListener:SetScript("OnEvent", function(self, event, message, senderName, _, _, _, _, _, _, _, _, _, guid)
        print("Channel msg:", message, "from", senderName)
        OrderTracker.RecipeSearcher:SearchRecipeInAllCharacters(message, senderName)
    end)

    print("Chat listener initialized after 1 second delay")
end)

