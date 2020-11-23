
-- Generic useful variables
local DHE_playerUID = UnitGUID("player")
local DHE_className, DHE_classFilename, DHE_classId = UnitClass("player")

-- Check that the user is actually playing a demon hunter.
if DHE_classId ~= 12 then
    return nil
end

------
-- Global settings variable
DHE_settings = {
    initialized = false
}

------
-- Default values for the settings
local DHE_settingsDefault = {
    initialized = true,
     -- Global cooldown between each individual sound effect. (Can be overridden for Meta for instance)
    soundGlobalCooldown = 8, -- seconds
    -- Chance for each category of sound effect to trigger
    probabilityTable = {
        AFKEND = 1.0,
        AFKSTART = 1.0,
        AGGRO = 0.33,
        ATTACK = 0.5,
        DEATH = 1.0,
        META = 1.0,
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

function DHE_handleSoundEvent(event, overrideCooldown)
    -- If we are on cooldown don't play anything.
    if DHE_currentSoundHandle ~= nil and not overrideCooldown then
        return nil
    end

    -- If we override the cooldown for important noises, then close the previous sound first
    if DHE_currentSoundHandle ~= nil then
        StopSound(DHE_currentSoundHandle, 0)
    end

    -- Roll to see if we want to play a sound
    local playSoundRoll = fastrandom()
    if playSoundRoll >= DHE_settings.probabilityTable[event] then
        return 0
    end

    -- We rolled to play the sound effect, now use the particular event's probability table to determine which one to play
    local probabilities = DHE_settings.soundProbabilityTable[event]

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
            willPlaySound, DHE_currentSoundHandle = PlaySoundFile("Interface\\AddOns\\DemonHunterExperience\\sounds\\" .. filename, "Dialog")
            -- Start a global cooldown timer to prevent audio from overlapping too much
            C_Timer.After(DHE_settings.soundGlobalCooldown, function()
                DHE_currentSoundHandle = nil
            end)
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
	elseif subevent == "SPELL_DAMAGE" then
		spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, CombatLogGetCurrentEventInfo())
    end

    -- filter to only check for things that we've done
    if sourceGUID ~= DHE_playerUID then
        return nil
    end

    -- Check to see if one of the "attack" spells was used
    -- Vengenace
    --  - Disrupt 183752
    --  - Soul Cleave 228477
    --  - Fracture 263642
    --  - Felblade 232893
    -- Havoc
    --  - Demon's Bite 162243
    --  - Chaos Strike 222031
    --  - Blade Dance 199552
    --  - Death Sweep 210152
    --  - Annihilation1 201427
    --  - Annihilation2 201428
    --  - Annihilation3 227518
    if     spellId == 183752
        or spellId == 228477
        or spellId == 263642
        or spellId == 232893
        or spellId == 162243
        or spellId == 222031
        or spellId == 199552
        or spellId == 210152
        or spellId == 201427
        or spellId == 201428
        or spellId == 227518
    then
        DHE_handleSoundEvent("ATTACK")
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
        if not DHE_settings.initialized then
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
