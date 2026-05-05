function PrintProfession(profIndex)
    if not profIndex then
        return
    end

    local name, icon, skillLevel = GetProfessionInfo(profIndex)
    print("Profession:", name, "Skill:", skillLevel)
end

-- ===== UI =====
-- local frame = CreateFrame("Frame", "MyOrderFrame", UIParent, "BackdropTemplate")
-- frame:SetSize(320, 400)
-- frame:SetPoint("CENTER")
-- frame:SetBackdrop({
--     bgFile = "Interface/Tooltips/UI-Tooltip-Background"
-- })
-- frame:SetBackdropColor(0, 0, 0, 0.8)
-- frame:Show()

-- frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
-- frame.title:SetPoint("TOP", 0, -10)
-- frame.title:SetText("Orders")

-- -- Close button
-- local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
-- closeBtn:SetPoint("TOPRIGHT", -5, -5)
-- closeBtn:SetScript("OnClick", function()
--     frame:Hide()
-- end)

-- frame.buttons = {}

-- local function RefreshUI()
--     -- очистка старых кнопок
--     for _, btn in ipairs(frame.buttons) do
--         btn:Hide()
--     end

--     frame.buttons = {}

--     for i, order in ipairs(Orders) do
--         local btn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
--         btn:SetSize(280, 30)
--         btn:SetPoint("TOP", 0, -40 - (i - 1) * 35)

--         btn:SetText(order.player .. " - " .. order.link)

--         -- Accept
--         local accept = CreateFrame("Button", nil, btn, "UIPanelButtonTemplate")
--         accept:SetSize(50, 20)
--         accept:SetPoint("RIGHT", -5, 0)
--         accept:SetText("✔")

--         accept:SetScript("OnClick", function()
--             Orders[i].status = "PROCESSING"
--             print("Accepted:", Orders[i].player)
--             RefreshUI()
--         end)

--         -- Decline
--         local decline = CreateFrame("Button", nil, btn, "UIPanelButtonTemplate")
--         decline:SetSize(50, 20)
--         decline:SetPoint("RIGHT", -60, 0)
--         decline:SetText("X")

--         decline:SetScript("OnClick", function()
--             print("Declined:", Orders[i].player)
--             table.remove(Orders, i)
--             RefreshUI()
--         end)

--         table.insert(frame.buttons, btn)
--     end
-- end

-- -- ===== CHAT LISTENER =====
-- local listener = CreateFrame("Frame")
-- listener:RegisterEvent("CHAT_MSG_CHANNEL")
-- listener:RegisterEvent("CHAT_MSG_SAY")
-- listener:RegisterEvent("CHAT_MSG_YELL")
-- listener:RegisterEvent("CHAT_MSG_WHISPER")

-- listener:SetScript("OnEvent", function(_, event, msg, author)
--     local link = ExtractItemLink(msg)
--     if not link then
--         return
--     end

--     local itemID = ExtractItemID(link)
--     if not itemID then
--         return
--     end

--     if Characters[itemID] then
--         table.insert(Orders, {
--             player = author,
--             link = link,
--             itemID = itemID,
--             crafter = Characters[itemID],
--             status = "NEW"
--         })

--         print("New order:", author, link)
--         RefreshUI()
--     end
-- end)

-- function ScanMyCrafts()
--     local player = UnitName("player")

--     Characters = Characters or {}

--     local recipeIDs = C_TradeSkillUI.GetAllRecipeIDs()

--     print(#recipeIDs)
--     for key, value in pairs(recipeIDs) do
--         print(key, value)
--     end

--     if not recipeIDs then
--         print("No recipes found (open profession window!)")
--         return
--     end

--     for key, value in pairs(recipeIDs) do
--         print(key, value)
--     end

--     for _, recipeID in ipairs(recipeIDs) do

--         local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
--         if (not recipeInfo) then
--             print("No recipe info for:", recipeID)
--         end

--         if recipeInfo.learned then
--             print("Recipe:", recipeID, recipeInfo.name)
--             local link = C_TradeSkillUI.GetRecipeItemLink(recipeID)
--             print("Link:", link);
--             -- local itemID = ExtractItemID(link)
--             Characters[recipeID] = {
--                 crafter = player,
--                 name = recipeInfo.name,
--                 link = link
--             }
--         end
--     end

--     print(#Characters)

--     print("Scanned crafts for:", player)
-- end

-- SLASH_LISTCRAFTS1 = "/listcrafts"

-- SlashCmdList["LISTCRAFTS"] = function()
--     -- if not MyCrafts or next(MyCrafts) == nil then
--     --     print("No crafts found. Use /scancrafts first.")
--     --     return
--     -- end

--     print("=== My Crafts ===")

--     for itemID, data in pairs(Characters) do
--         local name = data.name or ("item:" .. itemID)
--         local crafter = data.crafter or "Unknown"

--         print(itemID, "-", name, "->", crafter)
--     end
-- end

-- local f = CreateFrame("Frame")
-- f:RegisterEvent("TRADE_SKILL_SHOW")

-- f:SetScript("OnEvent", function()
--     ScanMyCrafts()
-- end)

-- Scan Professions
-- local prof1, prof2 = GetProfessions()
-- PrintProfession(prof1)
-- PrintProfession(prof2)



-- ===== CONFIG =====
-- Initialize saved variables (global table that WoW persists)
OrderAddonDB = OrderAddonDB or {}
OrderAddonDB.Characters = OrderAddonDB.Characters or {}
OrderAddonDB.Orders = OrderAddonDB.Orders or {}

-- Get current character key
function GetCharacterKey()
    local playerName = UnitName("player")
    local realmName = GetRealmName()
    return playerName .. "-" .. realmName
end

-- Extract item details from link
function ParseItemLink(msg)
    local name = msg:match("%[([^%]]+)%]")
    print(name)
    return {
        name = name
    }
end

function ScanCharacter(characterKey)
    if not OrderAddonDB.Characters[characterKey] then
        OrderAddonDB.Characters[characterKey] = {
            name = UnitName("player"),
            realm = GetRealmName(),
            class = select(2, UnitClass("player")),
            professions = {}
        }
    end
end

-- Scan recipes using modern API
function ScanRecipesModern(skillLineID, professionData)
    local wasOpen = C_TradeSkillUI.IsTradeSkillReady()
    if not wasOpen then
        C_TradeSkillUI.OpenTradeSkill(skillLineID)
    end

    C_Timer.After(2, function()
        local recipes = C_TradeSkillUI.GetAllRecipeIDs()
        if recipes then
            for _, recipeID in ipairs(recipes) do
                local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
                if recipeInfo and recipeInfo.learned then
                    professionData.recipes[recipeID] = {
                        name = recipeInfo.name,
                        hyperlink = recipeInfo.hyperlink,
                        recipeID = recipeID,
                        difficulty = recipeInfo.difficulty,
                        icon = recipeInfo.icon
                    }
                end
            end
        end

        if not wasOpen then
            C_TradeSkillUI.CloseTradeSkill()
        end
    end)
end

function SearchRecipeInAllCharacters(searchCriteria, author, fullMessage)
    print("Scan Recipe in all characters for:", searchCriteria)
    for charKey, charData in pairs(OrderAddonDB.Characters) do
        for profKey, profData in pairs(charData.professions) do
            for recipeID, recipeData in pairs(profData.recipes) do
                if string.find(searchCriteria, recipeData.name) then
                    print("Found", searchCriteria, "in", charKey, "profession", profData.name)
                    local itemLinkName = ParseItemLink(searchCriteria)

                    -- Add to orders if author provided
                    if author and fullMessage then
                        local order = {
                            itemLinkName = recipeData.name,
                            itemLink = recipeData.recipeItemLink,
                            author = author,
                            message = fullMessage,
                            crafterCharacter = charKey, -- Add crafter character name
                            status = "NEW",
                            timestamp = time()
                        }
                        table.insert(OrderAddonDB.Orders, order)
                        ShowOrderUI(order)
                    end
                    return
                end

            end
        end
    end
end

-- Create and show order UI frame
function ShowOrderUI(orderData)
    local frame = CreateFrame("Frame", "OrderFrame", UIParent, "BackdropTemplate")
    frame:SetSize(400, 150)
    frame:SetPoint("CENTER")
    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background"
    })
    frame:SetBackdropColor(0, 0, 0, 0.9)
    frame:Show()

    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -10)
    title:SetText("New Order from " .. orderData.author)

    -- Item info
    local info = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    info:SetPoint("TOPLEFT", 10, -35)
    info:SetWidth(380)
    info:SetJustifyH("LEFT")
    info:SetText("Item: " .. orderData.itemLinkName .. "\nAuthor: " .. orderData.author .. "\nCrafter: " ..
                     orderData.crafterCharacter .. "\nMessage: " .. orderData.message)

    -- Close button (X)
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function()
        frame:Hide()
        frame:Destroy()
    end)

    -- Accept button
    local acceptBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    acceptBtn:SetSize(100, 25)
    acceptBtn:SetPoint("BOTTOM", -60, 10)
    acceptBtn:SetText("Отправить")
    acceptBtn:SetScript("OnClick", function()
        orderData.status = "ACCEPTED"
        print("Order accepted from:", orderData.author)

        -- Send whisper to order author
        SendChatMessage("Кидай на " .. orderData.crafterCharacter, "WHISPER", nil, orderData.author)
        print("Whisper sent to:", orderData.author)

        frame:Hide()
        frame:Destroy()
        RefreshOrdersWindow()
    end)

    -- Cancel button
    local cancelBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    cancelBtn:SetSize(100, 25)
    cancelBtn:SetPoint("BOTTOM", 60, 10)
    cancelBtn:SetText("Отменить")
    cancelBtn:SetScript("OnClick", function()
        orderData.status = "DECLINED"
        print("Order declined from:", orderData.author)
        frame:Hide()
        frame:Destroy()
        RefreshOrdersWindow()
    end)
end

-- Show all orders in a list window
function ShowOrdersWindow()
    -- Create main frame
    local mainFrame = CreateFrame("Frame", "OrdersListFrame", UIParent, "BackdropTemplate")
    mainFrame:SetSize(500, 400)
    mainFrame:SetPoint("CENTER")
    mainFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background"
    })
    mainFrame:SetBackdropColor(0, 0, 0, 0.9)
    mainFrame:Show()

    -- Title
    local title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -15)
    title:SetText("Orders List")

    -- Close button (X)
    local closeBtn = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function()
        mainFrame:Hide()
        mainFrame:Destroy()
    end)
    
    -- Clear button
    local clearBtn = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    clearBtn:SetSize(80, 22)
    clearBtn:SetPoint("TOPRIGHT", -40, -10)
    clearBtn:SetText("Clear")
    clearBtn:SetScript("OnClick", function()
        OrderAddonDB.Orders = {}
        OrderAddonDB.OrderWindowCount = 0
        print("Orders cleared!")
        mainFrame:Destroy()
        ShowOrdersWindow()
    end)

    -- Scroll frame for orders
    local scrollFrame = CreateFrame("ScrollFrame", nil, mainFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(480, 330)
    scrollFrame:SetPoint("TOPLEFT", 10, -40)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(460, #OrderAddonDB.Orders * 50 + 10)
    scrollFrame:SetScrollChild(scrollChild)

    -- Display orders
    local yOffset = 0
    if #OrderAddonDB.Orders == 0 then
        local noOrders = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        noOrders:SetPoint("TOPLEFT", 10, -10)
        noOrders:SetText("No orders yet")
    else
        for i, order in ipairs(OrderAddonDB.Orders) do
            local orderBtn = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
            orderBtn:SetSize(440, 40)
            orderBtn:SetPoint("TOPLEFT", 10, -yOffset)

            local orderText = string.format("%s - %s - %s [%s]", order.author, order.itemLinkName,
                order.crafterCharacter, order.status)
            orderBtn:SetText(orderText)

            -- Click to view details
            orderBtn:SetScript("OnClick", function()
                ShowOrderUI(order)
            end)

            yOffset = yOffset + 50
        end
    end
end

-- Refresh orders window
function RefreshOrdersWindow()
    local frame = _G["OrdersListFrame"]
    if frame then
        frame:Destroy()
        ShowOrdersWindow()
    end
end

-- Slash command to show orders
SLASH_ORDERLIST1 = "/orderlist"
SlashCmdList["ORDERLIST"] = function()
    ShowOrdersWindow()
    frame:Destroy()
end

function ScanCharacterProfessions()
    -- Scan Character
    local characterKey = GetCharacterKey()
    ScanCharacter(characterKey)
    for charKey, charData in pairs(OrderAddonDB.Characters) do
        print("Character:", charKey, "Class:", charData.class or "Unknown")
    end
    local skillLineIds = C_TradeSkillUI.GetAllProfessionTradeSkillLines()

    for _, skillLineId in ipairs(skillLineIds) do
        local skillLineInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(skillLineId)

        OrderAddonDB.Characters[characterKey].professions[skillLineId] = {
            name = skillLineInfo.professionName,
            skillLevel = skillLineInfo.skillLevel,
            maxSkillLevel = skillLineInfo.skillModifier,
            skillLineID = skillLineId,
            recipes = {}
        }

        -- Scan recipes for each profession
        ScanRecipesModern(skillLineId, OrderAddonDB.Characters[characterKey].professions[skillLineId])
    end
end

ScanCharacterProfessions()

-- Subscribe on chat messages with delay to ensure data is loaded
C_Timer.After(5.0, function()
    local chatListener = CreateFrame("Frame")
    local chatListenerEvents = {"CHAT_MSG_CHANNEL", "CHAT_MSG_SAY"}
    for _, e in ipairs(chatListenerEvents) do
        chatListener:RegisterEvent(e)
    end

    chatListener:SetScript("OnEvent", function(self, event, msg, author, _, _, _, _, _, _, _, _, _, guid)
        print("Channel msg:", msg, "from", author)
        SearchRecipeInAllCharacters(msg, author, msg)
    end)

    print("Chat listener initialized after 1 second delay")
end)

