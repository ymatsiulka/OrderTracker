local AddonName, OrderTracker = ...;
OrderTracker.CharacterBaseProfessionsScanner = {};

local CharacterBaseProfessionsScanner = OrderTracker.CharacterBaseProfessionsScanner

local function StoreProfession(characterKey, skillLineId, professionName, skillLevel, maxSkillLevel)
    if not OrderTrackerDB.Characters[characterKey].professions[skillLineId] then
        OrderTrackerDB.Characters[characterKey].professions[skillLineId] = {
            id = skillLineId,
            name = professionName,
            skillLevel = skillLevel,
            maxSkillLevel = maxSkillLevel,
            recipes = {}
        }
    end
end

function CharacterBaseProfessionsScanner:ScanByKey(characterKey)
    print("Start scanning base professions for character:", characterKey)
    local prof1, prof2 = GetProfessions()

    if prof1 then
        local name, icon, skillLevel, maxSkillLevel, numAbilities, spelloffset, skillLine, rankModifier =
            GetProfessionInfo(prof1)

        print("Profession:", name)
        print("Skill:", skillLevel .. "/" .. maxSkillLevel)
        print("SkillLine:", skillLine)
        
        StoreProfession(characterKey, skillLine, name, skillLevel, maxSkillLevel)
    end

    if prof2 then
        local name, icon, skillLevel, maxSkillLevel, numAbilities, spelloffset, skillLine, rankModifier =
            GetProfessionInfo(prof2)

        print("Profession:", name)
        print("Skill:", skillLevel .. "/" .. maxSkillLevel)
        print("SkillLine:", skillLine)
        
        StoreProfession(characterKey, skillLine, name, skillLevel, maxSkillLevel)
    end
    print("End scanning base professions for character:", characterKey)
end
