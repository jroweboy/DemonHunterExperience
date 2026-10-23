-- Generic useful variables
local DHE_settingsVersion = 4
local DHE_className, DHE_classFilename, DHE_classId = UnitClass("player")

-- Check that the user is actually playing a demon hunter.
if DHE_classId ~= 12 then
    return nil
end

------
-- Default values for the saved settings. Only user choices are saved; the sound tables below live in code so that
-- adding or changing sounds never requires wiping the user's settings.
local DHE_settingsDefault = {
    version = DHE_settingsVersion,
    -- Master on/off switch, toggled from the /dh window
    enabled = true,
    -- Which voice set to use. Must be a key of DHE_soundSets.
    soundSet = "Illidan",
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
}

------
-- Sound sets.
-- Each set has a "normal" table and an optional "demonForm" table used while in Metamorphosis.
-- Sets without a demonForm table use "normal" all the time.
--
-- If a sound is going to be played, then pick a weighted option from the table for that event.
-- The numbers in the table represents the number of sides on the "dice" that the option will be on.
-- The total number of sides of the dice is the total of all rows in the table.
-- So if all options are 1, then they are all equally likely. But if all are one, and one is two,
-- then that one is doubly as likely as any other option. If an option is zero then it won't be rolled.
local DHE_soundSets = {
    DemonHunterWC3 = {
        label = "Demon Hunter (Warcraft III)",
        normal = {
            AFKEND = {
                ["demon_hunter_wc3\\normal\\atlast.ogg"] = 1,
                ["demon_hunter_wc3\\normal\\anudor_anudor.ogg"] = 1,
                ["demon_hunter_wc3\\normal\\commandme.ogg"] = 1,
                ["demon_hunter_wc3\\normal\\doruneka.ogg"] = 1,
                ["demon_hunter_wc3\\normal\\thetimehascome.ogg"] = 1,
            },
            AFKSTART = {
                ["demon_hunter_wc3\\normal\\hmm.ogg"] = 1,
            },
            AGGRO = {
                ["demon_hunter_wc3\\normal\\choasboils.ogg"] = 1,
                ["demon_hunter_wc3\\normal\\ishallfightfire.ogg"] = 1,
                ["demon_hunter_wc3\\normal\\noneshallsurvive.ogg"] = 1,
                ["demon_hunter_wc3\\normal\\atlast.ogg"] = 1,
            },
            ATTACK = {
                ["demon_hunter_wc3\\normal\\forkalimdor.ogg"] = 1,
                ["demon_hunter_wc3\\normal\\yourbloodismine.ogg"] = 1,
                ["demon_hunter_wc3\\normal\\mybladethirsts.ogg"] = 1,
                ["demon_hunter_wc3\\normal\\revenge.ogg"] = 1,
            },
            DEATH = {
                ["demon_hunter_wc3\\normal\\hmm.ogg"] = 1,
            },
            META = {
                ["demon_hunter_wc3\\demon_form\\forkalimdor.ogg"] = 1,
                ["demon_hunter_wc3\\demon_form\\yourbloodismine.ogg"] = 1,
                ["demon_hunter_wc3\\demon_form\\mybladethirsts.ogg"] = 1,
                ["demon_hunter_wc3\\demon_form\\noneshallsurvive.ogg"] = 1,
            },
            HUNT = {
                ["demon_hunter_wc3\\normal\\runforyourlife.ogg"] = 1,
            },
            MOUNT = {
                ["demon_hunter_wc3\\normal\\quickly.ogg"] = 1,
                ["demon_hunter_wc3\\normal\\anudor_anudor.ogg"] = 1,
                ["demon_hunter_wc3\\normal\\wemustact.ogg"] = 1,
                ["demon_hunter_wc3\\normal\\doruneka.ogg"] = 1,
                ["demon_hunter_wc3\\normal\\thoughibedamned.ogg"] = 1,
            },
            REVIVE = {
                ["demon_hunter_wc3\\normal\\atlastweshallhaverevenge.ogg"] = 1,
                ["demon_hunter_wc3\\normal\\revenge.ogg"] = 1,
                ["demon_hunter_wc3\\normal\\thoughibedamned.ogg"] = 1,
            },
            SELECT = {
                ["demon_hunter_wc3\\normal\\ishallfightfire.ogg"] = 1,
                ["demon_hunter_wc3\\normal\\demonblood.ogg"] = 1,
                ["demon_hunter_wc3\\normal\\youwillperish.ogg"] = 1,
                ["demon_hunter_wc3\\normal\\darknesscalled.ogg"] = 1,
                ["demon_hunter_wc3\\normal\\ilikemyenemies.ogg"] = 1,
            },
        },
        demonForm = {
            AFKEND = {
                ["demon_hunter_wc3\\demon_form\\atlast.ogg"] = 1,
                ["demon_hunter_wc3\\demon_form\\anudor_anudor.ogg"] = 1,
                ["demon_hunter_wc3\\demon_form\\commandme.ogg"] = 1,
                ["demon_hunter_wc3\\demon_form\\doruneka.ogg"] = 1,
                ["demon_hunter_wc3\\demon_form\\thetimehascome.ogg"] = 1,
            },
            AFKSTART = {
                ["demon_hunter_wc3\\demon_form\\hmm.ogg"] = 1,
            },
            AGGRO = {
                ["demon_hunter_wc3\\demon_form\\choasboils.ogg"] = 1,
                ["demon_hunter_wc3\\demon_form\\ishallfightfire.ogg"] = 1,
                ["demon_hunter_wc3\\demon_form\\noneshallsurvive.ogg"] = 1,
                ["demon_hunter_wc3\\demon_form\\atlast.ogg"] = 1,
            },
            ATTACK = {
                ["demon_hunter_wc3\\demon_form\\forkalimdor.ogg"] = 1,
                ["demon_hunter_wc3\\demon_form\\yourbloodismine.ogg"] = 1,
                ["demon_hunter_wc3\\demon_form\\mybladethirsts.ogg"] = 1,
                ["demon_hunter_wc3\\demon_form\\revenge.ogg"] = 1,
            },
            DEATH = {
                ["demon_hunter_wc3\\demon_form\\hmm.ogg"] = 1,
            },
            META = {
                ["demon_hunter_wc3\\demon_form\\forkalimdor.ogg"] = 1,
                ["demon_hunter_wc3\\demon_form\\yourbloodismine.ogg"] = 1,
                ["demon_hunter_wc3\\demon_form\\mybladethirsts.ogg"] = 1,
                ["demon_hunter_wc3\\demon_form\\noneshallsurvive.ogg"] = 1,
            },
            HUNT = {
                ["demon_hunter_wc3\\demon_form\\runforyourlife.ogg"] = 1,
            },
            MOUNT = {
                ["demon_hunter_wc3\\normal\\quickly.ogg"] = 1,
                ["demon_hunter_wc3\\normal\\anudor_anudor.ogg"] = 1,
                ["demon_hunter_wc3\\normal\\wemustact.ogg"] = 1,
                ["demon_hunter_wc3\\normal\\doruneka.ogg"] = 1,
                ["demon_hunter_wc3\\normal\\thoughibedamned.ogg"] = 1,
            },
            REVIVE = {
                ["demon_hunter_wc3\\demon_form\\atlastweshallhaverevenge.ogg"] = 1,
                ["demon_hunter_wc3\\demon_form\\revenge.ogg"] = 1,
                ["demon_hunter_wc3\\demon_form\\thoughibedamned.ogg"] = 1,
            },
            SELECT = {
                ["demon_hunter_wc3\\demon_form\\ishallfightfire.ogg"] = 1,
                ["demon_hunter_wc3\\demon_form\\demonblood.ogg"] = 1,
                ["demon_hunter_wc3\\demon_form\\youwillperish.ogg"] = 1,
                ["demon_hunter_wc3\\demon_form\\darknesscalled.ogg"] = 1,
                ["demon_hunter_wc3\\demon_form\\ilikemyenemies.ogg"] = 1,
            },
        },
    },

    IllidanWC3 = {
        label = "Illidan (Warcraft III)",
        normal = {
            AFKEND = {
                ["illidan_wc3\\normal\\easily.ogg"] = 1,
                ["illidan_wc3\\normal\\isthatall.ogg"] = 1,
            },
            AFKSTART = {
                ["illidan_wc3\\normal\\igrowimpatient.ogg"] = 1,
            },
            AGGRO = {
                ["illidan_wc3\\normal\\hardlyachallenge.ogg"] = 1,
                ["illidan_wc3\\normal\\youllregretapproachingme.ogg"] = 1,
                ["illidan_wc3\\normal\\evildrawsclose.ogg"] = 1,
                ["illidan_wc3\\normal\\youdarespeaktome.ogg"] = 1,
            },
            ATTACK = {
                ["illidan_wc3\\normal\\vengenceismine.ogg"] = 1,
                ["illidan_wc3\\normal\\diefool.ogg"] = 1,
                ["illidan_wc3\\normal\\youllregretapproachingme.ogg"] = 1,
                ["illidan_wc3\\normal\\nonemaychallengeme.ogg"] = 1,
            },
            DEATH = {
                ["illidan_wc3\\normal\\finallyrelease.ogg"] = 1,
            },
            META = {
                ["illidan_wc3\\demon_form\\mysoul.ogg"] = 1,
                ["illidan_wc3\\demon_form\\ivebeencaged.ogg"] = 1,
                ["illidan_wc3\\demon_form\\ivebeenalone.ogg"] = 1,
                ["illidan_wc3\\demon_form\\nonemaychallengeme.ogg"] = 1,
            },
            HUNT = {
                ["illidan_wc3\\normal\\youllregretapproachingme.ogg"] = 1,
                ["illidan_wc3\\normal\\hardlyachallenge.ogg"] = 1,
            },
            MOUNT = {
                ["illidan_wc3\\normal\\igrowimpatient.ogg"] = 1,
                ["illidan_wc3\\normal\\aretheredemonsnearby.ogg"] = 1,
                ["illidan_wc3\\normal\\imblindnotdeaf.ogg"] = 1,
            },
            REVIVE = {
                ["illidan_wc3\\normal\\mysoul.ogg"] = 1,
                ["illidan_wc3\\normal\\mybrother.ogg"] = 1,
                ["illidan_wc3\\normal\\noneofthemknow.ogg"] = 1,
            },
            SELECT = {
                ["illidan_wc3\\normal\\iseenothing.ogg"] = 1,
                ["illidan_wc3\\normal\\wingshornshoofs.ogg"] = 1,
                ["illidan_wc3\\normal\\paweep.ogg"] = 1,
            },
        },
        demonForm = {
            AFKEND = {
                ["illidan_wc3\\demon_form\\easily.ogg"] = 1,
                ["illidan_wc3\\demon_form\\isthatall.ogg"] = 1,
            },
            AFKSTART = {
                ["illidan_wc3\\demon_form\\igrowimpatient.ogg"] = 1,
            },
            AGGRO = {
                ["illidan_wc3\\demon_form\\hardlyachallenge.ogg"] = 1,
                ["illidan_wc3\\demon_form\\youllregretapproachingme.ogg"] = 1,
                ["illidan_wc3\\demon_form\\evildrawsclose.ogg"] = 1,
                ["illidan_wc3\\demon_form\\youdarespeaktome.ogg"] = 1,
            },
            ATTACK = {
                ["illidan_wc3\\demon_form\\vengenceismine.ogg"] = 1,
                ["illidan_wc3\\demon_form\\diefool.ogg"] = 1,
                ["illidan_wc3\\demon_form\\youllregretapproachingme.ogg"] = 1,
                ["illidan_wc3\\demon_form\\nonemaychallengeme.ogg"] = 1,
            },
            DEATH = {
                ["illidan_wc3\\demon_form\\finallyrelease.ogg"] = 1,
            },
            META = {
                ["illidan_wc3\\demon_form\\mysoul.ogg"] = 1,
                ["illidan_wc3\\demon_form\\ivebeencaged.ogg"] = 1,
                ["illidan_wc3\\demon_form\\ivebeenalone.ogg"] = 1,
                ["illidan_wc3\\demon_form\\nonemaychallengeme.ogg"] = 1,
            },
            HUNT = {
                ["illidan_wc3\\demon_form\\youllregretapproachingme.ogg"] = 1,
                ["illidan_wc3\\demon_form\\hardlyachallenge.ogg"] = 1,
            },
            MOUNT = {
                ["illidan_wc3\\normal\\igrowimpatient.ogg"] = 1,
                ["illidan_wc3\\normal\\aretheredemonsnearby.ogg"] = 1,
                ["illidan_wc3\\normal\\imblindnotdeaf.ogg"] = 1,
            },
            REVIVE = {
                ["illidan_wc3\\demon_form\\mysoul.ogg"] = 1,
                ["illidan_wc3\\demon_form\\mybrother.ogg"] = 1,
                ["illidan_wc3\\demon_form\\noneofthemknow.ogg"] = 1,
            },
            SELECT = {
                ["illidan_wc3\\demon_form\\iseenothing.ogg"] = 1,
                ["illidan_wc3\\demon_form\\wingshornshoofs.ogg"] = 1,
                ["illidan_wc3\\demon_form\\paweep.ogg"] = 1,
            },
        },
    },

    -- Heroes of the Storm Illidan. No separate demon form table; "normal" is used everywhere.
    Illidan = {
        label = "Illidan (Heroes of the Storm)",
        normal = {
            AFKEND = {
                ["illidan_hots\\afkend\\atlast.ogg"] = 1,
                ["illidan_hots\\afkend\\betterthingstodo.ogg"] = 1,
                ["illidan_hots\\afkend\\finally.ogg"] = 1,
                ["illidan_hots\\afkend\\igrowimpatient.ogg"] = 1,
                ["illidan_hots\\afkend\\letsgoalready.ogg"] = 1,
                ["illidan_hots\\afkend\\tookyoulongenough.ogg"] = 1,
            },
            AFKSTART = {
                ["illidan_hots\\afkstart\\keepeyesopen.ogg"] = 1,
                ["illidan_hots\\afkstart\\satstill.ogg"] = 1,
                ["illidan_hots\\afkstart\\stayalert.ogg"] = 1,
                ["illidan_hots\\afkstart\\stillthere.ogg"] = 1,
            },
            AGGRO = {
                ["illidan_hots\\aggroed\\betterthingstodo.ogg"] = 1,
                ["illidan_hots\\aggroed\\demiseathand.ogg"] = 1,
                ["illidan_hots\\aggroed\\evildrawsclose.ogg"] = 1,
                ["illidan_hots\\aggroed\\regretapproachingme.ogg"] = 1,
                ["illidan_hots\\aggroed\\slaythatonenext.ogg"] = 1,
                ["illidan_hots\\aggroed\\whonextshalltaste.ogg"] = 1,
            },
            ATTACK = {
                ["illidan_hots\\attack\\burnwiththeflames.ogg"] = 1,
                ["illidan_hots\\attack\\claimyourlife.ogg"] = 1,
                ["illidan_hots\\attack\\diefool.ogg"] = 1,
                ["illidan_hots\\attack\\dontfearmortal.ogg"] = 1,
                ["illidan_hots\\attack\\ifeelonlyhatred.ogg"] = 1,
                ["illidan_hots\\attack\\tastetheblades.ogg"] = 1,
                ["illidan_hots\\attack\\unendinghatred.ogg"] = 1,
                ["illidan_hots\\attack\\vengeanceismine.ogg"] = 1,
            },
            DEATH = {
                ["illidan_hots\\death\\chaosdamage.ogg"] = 1,
                ["illidan_hots\\death\\fortheloveof.ogg"] = 2,
                ["illidan_hots\\death\\kindaprepared.ogg"] = 1,
                ["illidan_hots\\death\\rabble.ogg"] = 3,
                ["illidan_hots\\death\\scoff.ogg"] = 3,
            },
            META = {
                ["illidan_hots\\metamorphosis\\nowcomplete.ogg"] = 3,
                ["illidan_hots\\metamorphosis\\notprepared.ogg"] = 1,
                ["illidan_hots\\metamorphosis\\feelhatred.ogg"] = 1,
            },
            HUNT = {
                ["illidan_hots\\metamorphosis\\notprepared.ogg"] = 1,
                ["illidan_hots\\metamorphosis\\feelhatred.ogg"] = 1,
            },
            MOUNT = {
                ["illidan_hots\\mount\\ialonemustact.ogg"] = 1,
                ["illidan_hots\\mount\\letsmoveout.ogg"] = 1,
                ["illidan_hots\\mount\\onmyway.ogg"] = 1,
                ["illidan_hots\\mount\\quickly.ogg"] = 1,
            },
            REVIVE = {
                ["illidan_hots\\revived\\deathcannotstopme.ogg"] = 1,
                ["illidan_hots\\revived\\willhavevengeance.ogg"] = 1,
                ["illidan_hots\\revived\\willpay.ogg"] = 1,
            },
            SELECT = {
                ["illidan_hots\\select\\alaspoorguldan.ogg"] = 1,
                ["illidan_hots\\select\\blindnotdeaf.ogg"] = 7,
                ["illidan_hots\\select\\daresaddress.ogg"] = 7,
                ["illidan_hots\\select\\darknesstextedme.ogg"] = 1,
                ["illidan_hots\\select\\holdthepinata.ogg"] = 1,
                ["illidan_hots\\select\\ihearyou.ogg"] = 7,
                ["illidan_hots\\select\\noididnotseethat.ogg"] = 1,
                ["illidan_hots\\select\\tyrandestilllooksgood.ogg"] = 1,
            },
        },
    },
}

-- Order the sets appear in the dropdown
local DHE_soundSetOrder = { "Illidan", "DemonHunterWC3", "IllidanWC3" }

-- Variables for tracking the current player state
local DHE_playerWasAFK = false
local DHE_playerWasMounted = IsMounted()
local DHE_currentSoundHandle = nil
local DHE_lastSoundTimestamp = nil
local DHE_lastFilenamePlayed = nil

-- Spell ids that trigger each kind of sound. Midnight (12.0+) removed addon access to the combat log, so these are
-- matched against the player's own UNIT_SPELLCAST_SUCCEEDED events instead.
-- Debugging: uncomment the print in DHE_events:UNIT_SPELLCAST_SUCCEEDED to see what your recent spell ids are.
local DHE_attackSpells = {
    -- Vengeance
    [183752] = true, -- Disrupt
    [228478] = true, -- Soul Cleave
    [225919] = true, -- Fracture
    [225921] = true, -- Fracture ... also?
    [232893] = true, -- Felblade
    -- Havoc
    [162243] = true, -- Demon's Bite
    [344859] = true, -- Demon's Bite new?
    [222031] = true, -- Chaos Strike
    [344862] = true, -- Chaos Strike new?
    [199552] = true, -- Blade Dance
    [210152] = true, -- Death Sweep
    [201427] = true, -- Annihilation1
    [201428] = true, -- Annihilation2
    [227518] = true, -- Annihilation3
    [213405] = true, -- Master of the Glaive
}
local DHE_huntSpells = {
    [323639] = true, -- Night Fae "The Hunt" ability
    [370965] = true, -- Talent "The Hunt" ability
}
local DHE_metaSpells = {
    [191427] = true, -- Metamorphosis (Havoc)
    [187827] = true, -- Metamorphosis (Vengeance)
}

local DHE_eyeBeamSpells = {
    [198013] = true, -- Eye Beam (Havoc)
}
-- Demonic: Eye Beam channels for about 2s, then you get demon form for about 6s afterwards
local DHE_eyeBeamMetaSeconds = 8

-- Metamorphosis durations in seconds, by cast spell id. Reading the buff itself is blocked in Midnight,
-- so we track it from the cast instead.
local DHE_metaDurations = {
    [191427] = 20, -- Havoc
    [187827] = 15, -- Vengeance
}
local DHE_metaUntil = 0

local function DHE_isInMeta()
    return GetTime() < DHE_metaUntil
end

------
-- Settings helpers

-- Fill in any missing keys in `saved` from `defaults`, recursing into tables. Existing values are kept.
local function DHE_applyDefaults(saved, defaults)
    for key, value in pairs(defaults) do
        if type(value) == "table" then
            if type(saved[key]) ~= "table" then
                saved[key] = {}
            end
            DHE_applyDefaults(saved[key], value)
        elseif saved[key] == nil then
            saved[key] = value
        end
    end
end

local function DHE_loadSettings()
    -- The old format stored the whole sound tables in saved variables and was marked with `initialized`.
    -- Start fresh from those.
    if type(DHE_settings) ~= "table" or DHE_settings.initialized then
        DHE_settings = {}
    end
    DHE_applyDefaults(DHE_settings, DHE_settingsDefault)
    DHE_settings.version = DHE_settingsVersion

    -- Guard against a set that no longer exists
    if not DHE_soundSets[DHE_settings.soundSet] then
        DHE_settings.soundSet = DHE_settingsDefault.soundSet
    end
end

local function DHE_stopCurrentSound()
    if DHE_currentSoundHandle ~= nil then
        StopSound(DHE_currentSoundHandle, 0)
        DHE_currentSoundHandle = nil
    end
end

local function DHE_setEnabled(enabled)
    DHE_settings.enabled = enabled and true or false
    if not DHE_settings.enabled then
        DHE_stopCurrentSound()
    end
end

local function DHE_setSoundSet(key)
    if DHE_soundSets[key] then
        DHE_settings.soundSet = key
        DHE_lastFilenamePlayed = nil
    end
end

-- Returns the weighted sound table for an event, using the demon form table during Metamorphosis
-- when the selected set has one.
local function DHE_getProbabilities(event)
    local set = DHE_soundSets[DHE_settings.soundSet] or DHE_soundSets[DHE_settingsDefault.soundSet]
    local sounds = (DHE_isInMeta() and set.demonForm) or set.normal
    return sounds[event]
end

------
-- Sound playback

function DHE_isSoundCooldown()
    if not DHE_lastSoundTimestamp then
        return false
    end
    local currentTime = GetServerTime()

    return currentTime - DHE_lastSoundTimestamp < DHE_settings.soundGlobalCooldown
end

-- Picks a weighted random sound for the event and plays it. No enabled/cooldown/probability checks.
local function DHE_playRandomSound(event)
    local probabilities = DHE_getProbabilities(event)
    if not probabilities then
        return nil
    end

    -- Total up the sides of the dice, skipping the sound we played last time so it doesn't repeat back to back.
    -- If that sound is the only option, allow the repeat.
    local function sides(filename, weight, allowRepeat)
        if filename == DHE_lastFilenamePlayed and not allowRepeat then
            return 0
        end
        return weight
    end

    local allowRepeat = false
    local totalSides = 0
    for filename, weight in pairs(probabilities) do
        totalSides = totalSides + sides(filename, weight, false)
    end
    if totalSides == 0 then
        allowRepeat = true
        for filename, weight in pairs(probabilities) do
            totalSides = totalSides + sides(filename, weight, true)
        end
    end

    -- if all sound options are disabled, then just return
    if totalSides == 0 then
        return nil
    end

    -- Stop the previous sound effect if its still playing. This is mostly useful for override sounds.
    DHE_stopCurrentSound()

    -- then determine which side of the die it landed on and play the sound
    local roll = fastrandom(1, totalSides)
    local cumulativeRange = 1
    for filename, weight in pairs(probabilities) do
        local w = sides(filename, weight, allowRepeat)
        if w > 0 and cumulativeRange <= roll and roll < cumulativeRange + w then
            local _
            _, DHE_currentSoundHandle = PlaySoundFile(
                "Interface\\AddOns\\DemonHunterExperience\\sounds\\" .. filename, "Dialog")
            DHE_lastFilenamePlayed = filename
            DHE_lastSoundTimestamp = GetServerTime()
            break
        end
        cumulativeRange = cumulativeRange + w
    end
end

function DHE_handleSoundEvent(event, overrideCooldown)
    -- Settings not loaded yet, or the user turned the addon off
    if not DHE_settings or not DHE_settings.enabled then
        return nil
    end

    -- If we are on cooldown don't play anything.
    if DHE_isSoundCooldown() and not overrideCooldown then
        return nil
    end

    -- Roll to see if we want to play a sound
    if fastrandom() >= (DHE_settings.probabilityTable[event] or 0) then
        return nil
    end

    DHE_playRandomSound(event)
end

------
-- Options window (/dh)

local DHE_optionsFrame = nil

-- Chance sliders, in display order
local DHE_eventOrder = {
    { key = "SELECT",   label = "Target self" },
    { key = "ATTACK",   label = "Attack" },
    { key = "AGGRO",    label = "Enter combat" },
    { key = "META",     label = "Metamorphosis" },
    { key = "HUNT",     label = "The Hunt" },
    { key = "MOUNT",    label = "Mount" },
    { key = "DEATH",    label = "Death" },
    { key = "REVIVE",   label = "Revive" },
    { key = "AFKSTART", label = "Go AFK" },
    { key = "AFKEND",   label = "Back from AFK" },
}

local DHE_rowHeight = 26

-- A row with a label on the left and a whole-number slider on the right, anchored below `anchor`.
-- formatValue turns the value into the text shown right of the slider; onChanged receives the new value.
local function DHE_createSliderRow(parent, anchor, labelText, minValue, maxValue, formatValue, onChanged)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(parent:GetWidth() - 32, DHE_rowHeight)
    row:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, 0)

    local label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("LEFT", row, "LEFT", 0, 0)
    label:SetText(labelText)

    local slider = CreateFrame("Frame", nil, row, "MinimalSliderWithSteppersTemplate")
    slider:SetPoint("LEFT", row, "LEFT", 140, 0)
    slider:SetWidth(180)
    slider:Init(minValue, minValue, maxValue, maxValue - minValue, {
        [MinimalSliderWithSteppersMixin.Label.Right] = formatValue,
    })
    slider:RegisterCallback(MinimalSliderWithSteppersMixin.Event.OnValueChanged, function(_, value)
        onChanged(math.floor(value + 0.5))
    end, row)

    row.slider = slider
    return row
end

local function DHE_createOptionsFrame()
    local frame = CreateFrame("Frame", "DemonHunterExperienceOptionsFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(400, 500)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()

    -- Close with Escape
    tinsert(UISpecialFrames, frame:GetName())

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOP", frame, "TOP", 0, -5)
    title:SetText("Demon Hunter Experience")

    -- Enabled checkbox
    local checkbox = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, -32)
    local checkboxLabel = checkbox.text or checkbox.Text or checkbox:CreateFontString(nil, "OVERLAY")
    checkboxLabel:SetFontObject("GameFontNormal")
    checkboxLabel:ClearAllPoints()
    checkboxLabel:SetPoint("LEFT", checkbox, "RIGHT", 2, 0)
    checkboxLabel:SetText("Enable sounds")
    checkbox:SetScript("OnClick", function(self)
        DHE_setEnabled(self:GetChecked())
    end)

    -- Voice dropdown
    local dropdownLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dropdownLabel:SetPoint("TOPLEFT", checkbox, "BOTTOMLEFT", 4, -10)
    dropdownLabel:SetText("Voice")

    local dropdown = CreateFrame("DropdownButton", nil, frame, "WowStyle1DropdownTemplate")
    dropdown:SetPoint("TOPLEFT", dropdownLabel, "BOTTOMLEFT", 0, -6)
    dropdown:SetWidth(200)
    dropdown:SetupMenu(function(_, rootDescription)
        for _, key in ipairs(DHE_soundSetOrder) do
            rootDescription:CreateRadio(
                DHE_soundSets[key].label,
                function() return DHE_settings.soundSet == key end,
                function() DHE_setSoundSet(key) end
            )
        end
    end)

    -- Preview button: plays an ATTACK line from the chosen voice, ignoring enabled/cooldown/chance
    local preview = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    preview:SetSize(80, 22)
    preview:SetPoint("LEFT", dropdown, "RIGHT", 8, 0)
    preview:SetText("Preview")
    preview:SetScript("OnClick", function()
        DHE_playRandomSound("ATTACK")
    end)

    -- Frequency section
    local frequencyHeader = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frequencyHeader:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 0, -16)
    frequencyHeader:SetText("Frequency")

    local cooldownRow = DHE_createSliderRow(frame, frequencyHeader, "Cooldown", 0, 60,
        function(value) return value .. "s" end,
        function(value) DHE_settings.soundGlobalCooldown = value end)

    local chanceRows = {}
    local previousRow = cooldownRow
    for _, info in ipairs(DHE_eventOrder) do
        local key = info.key
        local row = DHE_createSliderRow(frame, previousRow, info.label .. " chance", 0, 100,
            function(value) return value .. "%" end,
            function(value) DHE_settings.probabilityTable[key] = value / 100 end)
        chanceRows[key] = row
        previousRow = row
    end

    local note = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    note:SetPoint("TOPLEFT", previousRow, "BOTTOMLEFT", 0, -4)
    note:SetText("Metamorphosis and The Hunt ignore the cooldown.")

    -- Sync controls with saved settings
    local function refresh()
        checkbox:SetChecked(DHE_settings.enabled)
        dropdown:GenerateMenu()
        cooldownRow.slider:SetValue(DHE_settings.soundGlobalCooldown)
        for key, row in pairs(chanceRows) do
            row.slider:SetValue(math.floor((DHE_settings.probabilityTable[key] or 0) * 100 + 0.5))
        end
    end

    -- Reset cooldown and chances to defaults (leaves enabled and voice alone)
    local reset = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    reset:SetSize(140, 22)
    reset:SetPoint("BOTTOM", frame, "BOTTOM", 0, 12)
    reset:SetText("Reset to defaults")
    reset:SetScript("OnClick", function()
        DHE_settings.soundGlobalCooldown = DHE_settingsDefault.soundGlobalCooldown
        DHE_settings.probabilityTable = {}
        DHE_applyDefaults(DHE_settings, DHE_settingsDefault)
        refresh()
    end)

    -- Sync controls whenever the window opens
    frame:SetScript("OnShow", refresh)

    return frame
end

local function DHE_toggleOptions()
    if not DHE_settings then
        return
    end
    if not DHE_optionsFrame then
        DHE_optionsFrame = DHE_createOptionsFrame()
    end
    DHE_optionsFrame:SetShown(not DHE_optionsFrame:IsShown())
end

SLASH_DEMONHUNTEREXPERIENCE1 = "/dh"
SlashCmdList["DEMONHUNTEREXPERIENCE"] = DHE_toggleOptions

------
-- Events

local DemonHunterExperience, DHE_events = CreateFrame("Frame"), {};

-- Fires for the player's own successful casts (registered for the "player" unit only, see below).
function DHE_events:UNIT_SPELLCAST_SUCCEEDED(unit, castGUID, spellId)
    -- Midnight can hand addons "secret values" that can't be compared or used as table keys. Ignore those.
    if issecretvalue and issecretvalue(spellId) then
        return nil
    end

    -- Debugging: uncomment to show what your recent spell ids are
    --print(unit, spellId, (C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(spellId)) or "")

    if DHE_attackSpells[spellId] then
        DHE_handleSoundEvent("ATTACK")
    elseif DHE_huntSpells[spellId] then
        DHE_handleSoundEvent("HUNT", true)
    elseif DHE_eyeBeamSpells[spellId] then
        -- Demonic: short demon form after Eye Beam. Never shorten a longer Metamorphosis that is already running.
        DHE_metaUntil = math.max(DHE_metaUntil, GetTime() + DHE_eyeBeamMetaSeconds)
        DHE_handleSoundEvent("META", true)
    elseif DHE_metaSpells[spellId] then
        DHE_metaUntil = math.max(DHE_metaUntil, GetTime() + (DHE_metaDurations[spellId] or 15))
        DHE_handleSoundEvent("META", true)
    end
end

function DHE_events:PLAYER_REGEN_DISABLED(...)
    DHE_handleSoundEvent("AGGRO")
end

function DHE_events:PLAYER_DEAD(...)
    DHE_metaUntil = 0
    DHE_handleSoundEvent("DEATH")
end

function DHE_events:PLAYER_UNGHOST(...)
    DHE_handleSoundEvent("REVIVE")
end

function DHE_events:PLAYER_MOUNT_DISPLAY_CHANGED(...)
    if not DHE_playerWasMounted and IsMounted() then
        DHE_playerWasMounted = true
        DHE_handleSoundEvent("MOUNT")
    elseif DHE_playerWasMounted and not IsMounted() then
        DHE_playerWasMounted = false
    end
end

function DHE_events:PLAYER_TARGET_CHANGED(...)
    if UnitIsUnit("target", "player") then
        DHE_handleSoundEvent("SELECT")
    end
end

function DHE_events:PLAYER_FLAGS_CHANGED(...)
    local isAFK = UnitIsAFK("player")
    -- Secret in dungeons, raids, encounters and PvP matches. Testing it errors, so skip the update.
    if issecretvalue and issecretvalue(isAFK) then
        return
    end

    if not DHE_playerWasAFK and isAFK then
        DHE_playerWasAFK = true
        DHE_handleSoundEvent("AFKSTART")
    elseif DHE_playerWasAFK and not isAFK then
        DHE_playerWasAFK = false
        DHE_handleSoundEvent("AFKEND")
    end
end

function DHE_events:ADDON_LOADED(...)
    local addonName = ...
    if addonName == "DemonHunterExperience" then
        DHE_loadSettings()
    end
end

-- Generic event handler that will call our internal event handlers. Each interal event handler will then filter for the
-- individual events that we want (like attack or meta for instance) and call the handleSoundEvent function
DemonHunterExperience:SetScript("OnEvent", function(self, event, ...)
    local handler = DHE_events[event]
    if handler then
        handler(self, ...)
    end
end);

-- Register all events for which handlers have been defined
for event in pairs(DHE_events) do
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        -- Only care about our own casts, not every unit in the world
        DemonHunterExperience:RegisterUnitEvent(event, "player")
    else
        DemonHunterExperience:RegisterEvent(event)
    end
end
