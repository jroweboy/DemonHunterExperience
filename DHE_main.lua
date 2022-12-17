
-- Generic useful variables
local DHE_playerUID = UnitGUID("player")
local DHE_settingsVersion = 3
local DHE_className, DHE_classFilename, DHE_classId = UnitClass("player")

-- Check that the user is actually playing a demon hunter.
if DHE_classId ~= 12 then
    return nil
end

------
-- Global settings variable
DHE_settings = {
    version = DHE_settingsVersion,
}

------
-- Default values for the settings
local DHE_settingsDefault = {
    initialized = true,
    version = DHE_settingsVersion,
     -- Global cooldown between each individual sound effect. (Can be overridden for Meta for instance)
    soundGlobalCooldown = 14, -- seconds
    -- Chance for each category of sound effect to trigger
    probabilityTable = {
        AFKEND = 1.0,
        AFKSTART = 1.0,
        AGGRO = 0.33,
        ATTACK = 0.5,
        DEATH = 1.0,
        META = 1.0,
        HUNT = 1.0,
        MOUNT = 1.0,
        REVIVE = 1.0,
        SELECT = 1.0,
    },
    -- Mapping of probabilities for each of the individual sounds
    -- If a sound is going to be played, then picked a weighted option from this table.
    -- The numbers in the table represents the number of sides on the "dice" that the option will be on.
    -- The total number of sides of the dice is the total of all rows in the table.
    -- So if all options are 1, then they are all equally likely. But if all are one, and one is two,
    -- then that one is doubly as likely as any other option. If an option is zero then it won't be rolled.
    soundProbabilityTable = {
        AFKEND = {
            ["afkend\\atlast.ogg"] = 1,
            ["afkend\\betterthingstodo.ogg"] = 1,
            ["afkend\\finally.ogg"] = 1,
            ["afkend\\igrowimpatient.ogg"] = 1,
            ["afkend\\letsgoalready.ogg"] = 1,
            ["afkend\\tookyoulongenough.ogg"] = 1,
        },
        AFKSTART = {
            ["afkstart\\keepeyesopen.ogg"] = 1,
            ["afkstart\\satstill.ogg"] = 1,
            ["afkstart\\stayalert.ogg"] = 1,
            ["afkstart\\stillthere.ogg"] = 1,
        },
        AGGRO = {
            ["aggroed\\betterthingstodo.ogg"] = 1,
            ["aggroed\\demiseathand.ogg"] = 1,
            ["aggroed\\evildrawsclose.ogg"] = 1,
            ["aggroed\\regretapproachingme.ogg"] = 1,
            ["aggroed\\slaythatonenext.ogg"] = 1,
            ["aggroed\\whonextshalltaste.ogg"] = 1,
        },
        ATTACK = {
            ["attack\\burnwiththeflames.ogg"] = 1,
            ["attack\\claimyourlife.ogg"] = 1,
            ["attack\\diefool.ogg"] = 1,
            ["attack\\dontfearmortal.ogg"] = 1,
            ["attack\\ifeelonlyhatred.ogg"] = 1,
            ["attack\\tastetheblades.ogg"] = 1,
            ["attack\\unendinghatred.ogg"] = 1,
            ["attack\\vengeanceismine.ogg"] = 1,
        },
        DEATH = {
            ["death\\chaosdamage.ogg"] = 1,
            ["death\\fortheloveof.ogg"] = 2,
            ["death\\kindaprepared.ogg"] = 1,
            ["death\\rabble.ogg"] = 3,
            ["death\\scoff.ogg"] = 3,
        },
        META = {
            ["metamorphosis\\nowcomplete.ogg"] = 3,
            ["metamorphosis\\notprepared.ogg"] = 1,
            ["metamorphosis\\feelhatred.ogg"] = 1,
        },
        HUNT = {
            ["metamorphosis\\notprepared.ogg"] = 1,
            ["metamorphosis\\feelhatred.ogg"] = 1,
        },
        MOUNT = {
            ["mount\\ialonemustact.ogg"] = 1,
            ["mount\\letsmoveout.ogg"] = 1,
            ["mount\\onmyway.ogg"] = 1,
            ["mount\\quickly.ogg"] = 1,
        },
        REVIVE = {
            ["revived\\deathcannotstopme.ogg"] = 1,
            ["revived\\willhavevengeance.ogg"] = 1,
            ["revived\\willpay.ogg"] = 1,
        },
        SELECT = {
            ["select\\alaspoorguldan.ogg"] = 1,
            ["select\\blindnotdeaf.ogg"] = 7,
            ["select\\daresaddress.ogg"] = 7,
            ["select\\darknesstextedme.ogg"] = 1,
            ["select\\holdthepinata.ogg"] = 1,
            ["select\\ihearyou.ogg"] = 7,
            ["select\\noididnotseethat.ogg"] = 1,
            ["select\\tyrandestilllooksgood.ogg"] = 1,
        },
    }
}

-- Variables for tracking the current player state
local DHE_playerWasAFK = UnitIsAFK("player")
local DHE_playerWasMounted = IsMounted()
local DHE_playerInMetamorphosis = false
local DHE_currentSoundHandle = nil
local DHE_lastSoundTimestamp = nil
local DHE_lastFilenamePlayed = nil

function DHE_isSoundCooldown()
    if not DHE_lastSoundTimestamp then
        return false
    end
    local currentTime = GetServerTime()
    
    return currentTime - DHE_lastSoundTimestamp < DHE_settings.soundGlobalCooldown
end

function DHE_handleSoundEvent(event, overrideCooldown)
    
    -- If we are on cooldown don't play anything.
    if DHE_isSoundCooldown() and not overrideCooldown then
        return nil
    end
    
    -- Stop the previous sound effect if its still playing. This is mostly useful for override sounds.
    if DHE_currentSoundHandle ~= nil then
        StopSound(DHE_currentSoundHandle, 0)
    end

    -- Roll to see if we want to play a sound
    local playSoundRoll = fastrandom()
    if playSoundRoll >= DHE_settings.probabilityTable[event] then
        return nil
    end

    -- We rolled to play the sound effect, now use the particular event's probability table to determine which one to play
    local probabilities = DHE_settings.soundProbabilityTable[event]

    -- Remove the previously played sound effect from the table so we don't roll it twice in a row.
    local originalProbability = nil
    if DHE_lastFilenamePlayed ~= nil then
        for filename, soundProbability in pairs(probabilities) do
            if filename == DHE_lastFilenamePlayed then
                originalProbability = soundProbability
                probabilities[filename] = 0
                break
            end
        end
    end

    -- First calculate the total number of sides of the dice to use
    local totalSides = 0
    for unused, soundProbability in pairs(probabilities) do
        totalSides = totalSides + soundProbability
    end

    -- if all sound options are disabled, then just return
    if totalSides == 0 then
        return nil
    end

    -- then determine which side of the die it landed on and play the sound
    local roll = fastrandom(1, totalSides)
    local cumulativeRange = 1
    local willPlaySound = false
    for filename, soundProbability in pairs(probabilities) do
        if (cumulativeRange <= roll) and (roll < cumulativeRange + soundProbability) then
            
            -- Restore the original probability to the previous sound played
            if originalProbability ~= nil and originalProbability > 0 then
                for f, s in pairs(probabilities) do
                    if f == DHE_lastFilenamePlayed then
                        probabilities[f] = originalProbability
                        break
                    end
                end
            end
            willPlaySound, DHE_currentSoundHandle = PlaySoundFile("Interface\\AddOns\\DemonHunterExperience\\sounds\\" .. filename, "Dialog")
            DHE_lastFilenamePlayed = filename
            DHE_lastSoundTimestamp = GetServerTime()
            break
        end
        cumulativeRange = cumulativeRange + soundProbability
    end
end

local DemonHunterExperience, DHE_events = CreateFrame("Frame"), {};

function DHE_events:COMBAT_LOG_EVENT_UNFILTERED(...)
    -- General boilerplate code to get unwrap the fields from the latest combat log
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
	local spellId, spellName, spellSchool
	local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand
	if subevent == "SWING_DAMAGE" then
        amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, CombatLogGetCurrentEventInfo())
	else
        spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, CombatLogGetCurrentEventInfo())
    end

    -- filter to only check for things that we've done
    if sourceGUID ~= DHE_playerUID then
        return nil
    end

    -- Check to see if one of the "attack" spells was used
    -- Debugging: uncomment to show what your recent attack skill ids are
    --print(subevent, spellId, spellName, spellSchool)
    if subevent == "SPELL_CAST_SUCCESS" and
    (
        -- Vengenace
           spellId == 183752 -- Disrupt
        or spellId == 228478 -- Soul Cleave
        or spellId == 225919 -- Fracture
        or spellId == 225921 -- Fracture ... also?
        or spellId == 232893 -- Felblade
        -- Havoc
        or spellId == 162243 -- Demon's Bite
        or spellId == 344859 -- Demon's Bite new?
        or spellId == 222031 -- Chaos Strike
        or spellId == 344862 -- Chaos Strike new?
        or spellId == 199552 -- Blade Dance
        or spellId == 210152 -- Death Sweep
        or spellId == 201427 -- Annihilation1
        or spellId == 201428 -- Annihilation2
        or spellId == 227518 -- Annihilation3
        or spellId == 213405 -- Master of the Glaive
    )
    then
        DHE_handleSoundEvent("ATTACK")
    end

    if subevent == "SPELL_CAST_START" and
    (
           spellId == 323639 -- Night Fae "The Hunt" ability
        or spellId == 370965 -- Talent "The Hunt" ability
    )
    then
        DHE_handleSoundEvent("HUNT", true)
    end
end

function DHE_events:PLAYER_REGEN_DISABLED(...)
    DHE_handleSoundEvent("AGGRO")
end

function DHE_events:PLAYER_DEAD(...)
    DHE_handleSoundEvent("DEATH")
end

function DHE_events:PLAYER_UNGHOST(...)
    DHE_handleSoundEvent("REVIVE")
end

function DHE_events:UNIT_AURA(...)
    local target = ...
    if not DHE_playerWasMounted and IsMounted() then
        DHE_playerWasMounted = true
        DHE_handleSoundEvent("MOUNT")
    elseif DHE_playerWasMounted and not IsMounted() then
        DHE_playerWasMounted = false
    end
    -- Check if the player hopped into meta just now
    local isInMeta = false
    for i=1,40 do
        local name = UnitBuff("player",i)
        if name == "Metamorphosis" then
            isInMeta = true
            if not DHE_playerInMetamorphosis then
                DHE_playerInMetamorphosis = true
                DHE_handleSoundEvent("META", true)
            end
        end
    end
    if not isInMeta and DHE_playerInMetamorphosis then
        DHE_playerInMetamorphosis = false
    end
end

function DHE_events:PLAYER_TARGET_CHANGED(...)
    if UnitGUID("target") == DHE_playerUID then
        DHE_handleSoundEvent("SELECT")
    end
end

function DHE_events:PLAYER_FLAGS_CHANGED(...)
    if not DHE_playerWasAFK and UnitIsAFK("player") then
        DHE_playerWasAFK = true
        DHE_handleSoundEvent("AFKSTART")
    elseif DHE_playerWasAFK and not UnitIsAFK("player") then
        DHE_playerWasAFK = false
        DHE_handleSoundEvent("AFKEND")
    end
end

function DHE_events:ADDON_LOADED(...)
    local addonName = ...
    if addonName == "DemonHunterExperience" then
        -- Update the settings with the new version. TODO don't override changed settings.
        if not DHE_settings.initialized then
            DHE_settings = DHE_settingsDefault
        end
        if DHE_settings.version ~= DHE_settingsVersion then
            DHE_settings = DHE_settingsDefault
        end
    end
end

-- Generic event handler that will call our internal event handlers. Each interal event handler will then filter for the
-- individual events that we want (like attack or meta for instance) and call the handleSoundEvent function
DemonHunterExperience:SetScript("OnEvent", function(self, event, ...)
    DHE_events[event](self, ...);
end);

-- Register all events for which handlers have been defined
for k, v in pairs(DHE_events) do
    DemonHunterExperience:RegisterEvent(k);
end
