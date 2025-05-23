local mod = RegisterMod('Character Shenanigans', 1)
local json = require('json')
local game = Game()

if REPENTOGON then
  function mod:onModsLoaded()
    mod:setupImGui()
  end
  
  function mod:getKeys(tbl, val)
    local keys = {}
    
    for k, v in pairs(tbl) do
      if v == val and
         k ~= 'PLAYER_MAGDALENA' and -- exclude deprecated properties
         k ~= 'PLAYER_XXX' and
         k ~= 'PLAYER_MAGDALENA_B' and
         k ~= 'PLAYER_XXX_B'
      then
        table.insert(keys, k)
      end
    end
    
    table.sort(keys)
    return keys
  end
  
  function mod:hasKey(tbl, key)
    for _, v in ipairs(tbl) do
      if v.key == key then
        return true
      end
    end
    
    return false
  end
  
  function mod:getXmlModName(sourceid)
    local entry = XMLData.GetModById(sourceid)
    if entry and type(entry) == 'table' and entry.name and entry.name ~= '' then
      return entry.name
    end
    
    return nil
  end
  
  function mod:getXmlPlayerSourceId(id)
    id = tonumber(id)
    
    if math.type(id) == 'integer' then
      local entry = XMLData.GetEntryById(XMLNode.PLAYER, id)
      if entry and type(entry) == 'table' then
        if entry.sourceid and entry.sourceid ~= '' then
          return entry.sourceid
        end
      end
    end
    
    return nil
  end
  
  function mod:getXmlPlayerAchievement(id)
    id = tonumber(id)
    
    if math.type(id) == 'integer' then
      local entry = XMLData.GetEntryById(XMLNode.PLAYER, id)
      if entry and type(entry) == 'table' then
        if entry.achievement and entry.achievement ~= '' then
          return entry.achievement
        end
      end
    end
    
    return nil
  end
  
  function mod:getXmlAchievementId(name)
    local entry = XMLData.GetEntryByName(XMLNode.ACHIEVEMENT, name)
    if entry and type(entry) == 'table' then
      if entry.id and entry.id ~= '' then
        return entry.id
      end
    end
    
    return nil
  end
  
  function mod:getAchievementID(playerConfig)
    local achievementId = playerConfig:GetAchievementID() -- broken for modded characters right now
    
    if achievementId == 0 then
      local achievement = mod:getXmlPlayerAchievement(playerConfig:GetPlayerType())
      if achievement then
        local tempAchievementId = tonumber(mod:getXmlAchievementId(achievement))
        if math.type(tempAchievementId) == 'integer' then
          achievementId = tempAchievementId
        end
      end
    end
    
    return achievementId
  end
  
  function mod:localize(category, key)
    local s = Isaac.GetString(category, key)
    return (s == nil or s == 'StringTable::InvalidCategory' or s == 'StringTable::InvalidKey') and key or s
  end
  
  function mod:padName(name, num)
    local pad
    if Options.Language == 'jp' or Options.Language == 'kr' or Options.Language == 'zh' then
      pad = '\u{3000}' -- ideographic space
      
      local codes = {}
      for _, c in utf8.codes(name) do
        if c == 0x20 then -- space
          table.insert(codes, 0x3000)
        elseif c >= 0x21 and c <= 0x7E then -- ascii chars
          table.insert(codes, c + 0xFEE0) -- full width chars
        else
          table.insert(codes, c)
        end
      end
      name = utf8.char(table.unpack(codes))
    else
      pad = ' ' -- space
    end
    
    local nameLength = utf8.len(name) -- string.len
    if num > nameLength then
      local diff = num - nameLength
      if diff % 2 ~= 0 then
        name = pad .. name -- extra space before name
        diff = diff - 1
      end
      if diff > 0 then
        local halfDiff = diff / 2
        name = string.rep(pad, halfDiff) .. name .. string.rep(pad, halfDiff)
      end
    end
    
    return name
  end
  
  -- visible and in same order as character select carousel
  function mod:getModdedCharacters()
    local characters = {}
    
    local i = PlayerType.NUM_PLAYER_TYPES -- 41, EntityConfig.GetMaxPlayerType()
    local playerConfig = EntityConfig.GetPlayer(i)
    while playerConfig do
      if not playerConfig:IsHidden() and not playerConfig:IsTainted() and not mod:hasPlayerType(characters, playerConfig:GetPlayerType()) then
        table.insert(characters, playerConfig)
        
        local taintedConfig = playerConfig:GetTaintedCounterpart()
        if taintedConfig and not taintedConfig:IsHidden() and not mod:hasPlayerType(characters, taintedConfig:GetPlayerType()) then
          table.insert(characters, taintedConfig)
        end
      end
      
      i = i + 1
      playerConfig = EntityConfig.GetPlayer(i)
    end
    
    return characters
  end
  
  -- visible or hidden in ID order
  function mod:getModdedCharactersForExport(inclVisible, inclHidden)
    local characters = {}
    
    local i = PlayerType.NUM_PLAYER_TYPES
    local playerConfig = EntityConfig.GetPlayer(i)
    while playerConfig do
      local isHidden = playerConfig:IsHidden()
      if not isHidden and playerConfig:IsTainted() then
        local regularConfig = playerConfig:GetTaintedCounterpart()
        if regularConfig == nil or regularConfig:IsHidden() or regularConfig:IsTainted() then
          isHidden = true
        end
      end
      
      if (inclVisible and not isHidden) or (inclHidden and isHidden) then
        table.insert(characters, playerConfig)
      end
      
      i = i + 1
      playerConfig = EntityConfig.GetPlayer(i)
    end
    
    return characters
  end
  
  function mod:getModdedCharacterId(sourceIdAndName)
    for _, character in ipairs(mod:getModdedCharactersForExport(true, true)) do
      local sourceId = mod:getXmlPlayerSourceId(character:GetPlayerType())
      if sourceId then
        local generatedSourceIdAndName = sourceId .. '-' .. character:GetName()
        if character:IsTainted() then
          generatedSourceIdAndName = generatedSourceIdAndName .. '-Tainted-'
        end
        if generatedSourceIdAndName == sourceIdAndName then
          return character:GetPlayerType()
        end
      end
    end
    
    return nil
  end
  
  function mod:hasPlayerType(characters, playerType)
    for _, character in ipairs(characters) do
      if character:GetPlayerType() == playerType then
        return true
      end
    end
    
    return false
  end
  
  function mod:isPlayerType(playerType)
    return EntityConfig.GetPlayer(playerType) ~= nil
  end
  
  function mod:isBossType(boss)
    for _, v in pairs(CompletionType) do
      if v == boss then
        return true
      end
    end
    
    return false
  end
  
  function mod:unlockLock(achievement, unlock)
    if unlock then
      local gameData = Isaac.GetPersistentGameData()
      gameData:TryUnlock(achievement, false) -- Isaac.ExecuteCommand('achievement ' .. achievement)
    else
      Isaac.ExecuteCommand('lockachievement ' .. achievement)
    end
  end
  
  function mod:processImportedJson(s)
    local jsonDecoded, data = pcall(json.decode, s)
    local completionMarks = {}
    
    if jsonDecoded and type(data) == 'table' then
      if type(data.completionMarks) == 'table' then
        for k, v in pairs(data.completionMarks) do
          local character = nil
          if type(k) == 'string' then
            if string.sub(k, 1, 2) == 'M-' then
              character = tonumber(mod:getModdedCharacterId(string.sub(k, 3)))
            else
              character = tonumber(string.match(k, '^(%d+)'))
            end
          end
          if math.type(character) == 'integer' and type(v) == 'table' and mod:isPlayerType(character) then
            for l, w in pairs(v) do
              local boss = nil
              if type(l) == 'string' then
                boss = tonumber(string.match(l, '^(%d+)'))
              end
              if math.type(boss) == 'integer' and math.type(w) == 'integer' and mod:isBossType(boss) and w >= 0 and w <= 2 then -- 0=off,1=normal,2=hard
                local key = character .. '-' .. boss
                if not mod:hasKey(completionMarks, key) then
                  table.insert(completionMarks, { key = key, character = character, boss = boss, value = w })
                end
              end
            end
          end
        end
      end
      
      table.sort(completionMarks, function(a, b)
        if a.character == b.character then
          return a.boss < b.boss
        end
        
        return a.character < b.character
      end)
      
      for _, v in ipairs(completionMarks) do
        Isaac.SetCompletionMark(v.character, v.boss, v.value)
      end
    end
    
    return jsonDecoded, jsonDecoded and 'Imported ' .. #completionMarks .. ' completion marks' or data
  end
  
  function mod:getJsonExport(inclBuiltInCharacters, inclVisibleModdedCharacters, inclHiddenModdedCharacters)
    local s = '{'
    
    s = s .. '\n  "completionMarks": {'
    local sb = {}
    if inclBuiltInCharacters then
      for _, character in ipairs({
                                  PlayerType.PLAYER_ISAAC       ,
                                  PlayerType.PLAYER_MAGDALENE   ,
                                  PlayerType.PLAYER_CAIN        ,
                                  PlayerType.PLAYER_JUDAS       ,
                                  PlayerType.PLAYER_BLUEBABY    ,
                                  PlayerType.PLAYER_EVE         ,
                                  PlayerType.PLAYER_SAMSON      ,
                                  PlayerType.PLAYER_AZAZEL      ,
                                  PlayerType.PLAYER_LAZARUS     ,
                                  PlayerType.PLAYER_EDEN        ,
                                  PlayerType.PLAYER_THELOST     ,
                                  PlayerType.PLAYER_LILITH      ,
                                  PlayerType.PLAYER_KEEPER      ,
                                  PlayerType.PLAYER_APOLLYON    ,
                                  PlayerType.PLAYER_THEFORGOTTEN,
                                  PlayerType.PLAYER_BETHANY     ,
                                  PlayerType.PLAYER_JACOB       ,
                                  PlayerType.PLAYER_ISAAC_B       ,
                                  PlayerType.PLAYER_MAGDALENE_B   ,
                                  PlayerType.PLAYER_CAIN_B        ,
                                  PlayerType.PLAYER_JUDAS_B       ,
                                  PlayerType.PLAYER_BLUEBABY_B    ,
                                  PlayerType.PLAYER_EVE_B         ,
                                  PlayerType.PLAYER_SAMSON_B      ,
                                  PlayerType.PLAYER_AZAZEL_B      ,
                                  PlayerType.PLAYER_LAZARUS_B     ,
                                  PlayerType.PLAYER_EDEN_B        ,
                                  PlayerType.PLAYER_THELOST_B     ,
                                  PlayerType.PLAYER_LILITH_B      ,
                                  PlayerType.PLAYER_KEEPER_B      ,
                                  PlayerType.PLAYER_APOLLYON_B    ,
                                  PlayerType.PLAYER_THEFORGOTTEN_B,
                                  PlayerType.PLAYER_BETHANY_B     ,
                                  PlayerType.PLAYER_JACOB_B       ,
                                })
      do
        local keys = mod:getKeys(PlayerType, character)
        if #keys > 0 then
          local name = character .. '-' .. keys[1]
          table.insert(sb, mod:getJsonCharacterExport(character, name))
        end
      end
    end
    if inclVisibleModdedCharacters or inclHiddenModdedCharacters then
      for _, character in ipairs(mod:getModdedCharactersForExport(inclVisibleModdedCharacters, inclHiddenModdedCharacters)) do
        local sourceId = mod:getXmlPlayerSourceId(character:GetPlayerType())
        if sourceId then
          local name = 'M-' .. sourceId .. '-' .. character:GetName()
          if character:IsTainted() then
            name = name .. '-Tainted-'
          end
          table.insert(sb, mod:getJsonCharacterExport(character:GetPlayerType(), name))
        end
      end
    end
    s = s .. table.concat(sb, ',')
    s = s .. '\n  }'
    
    s = s .. '\n}'
    return s
  end
  
  function mod:getJsonCharacterExport(character, name)
    local s = ''
    
    s = s .. '\n    ' .. json.encode(name) .. ': {'
    local sb = {}
    for _, boss in ipairs({
                           CompletionType.MOMS_HEART ,
                           CompletionType.ISAAC      ,
                           CompletionType.SATAN      ,
                           CompletionType.BOSS_RUSH  ,
                           CompletionType.BLUE_BABY  ,
                           CompletionType.LAMB       ,
                           CompletionType.MEGA_SATAN ,
                           CompletionType.ULTRA_GREED,
                           CompletionType.HUSH       ,
                           CompletionType.DELIRIUM   ,
                           CompletionType.MOTHER     ,
                           CompletionType.BEAST      ,
                         })
    do
      local keys = mod:getKeys(CompletionType, boss)
      if #keys > 0 then
        table.insert(sb, '\n      ' .. json.encode(boss .. '-' .. keys[1]) .. ': ' .. math.floor(Isaac.GetCompletionMark(character, boss)))
      end
    end
    s = s .. table.concat(sb, ',')
    s = s .. '\n    }'
    
    return s
  end
  
  function mod:setupImGuiMenu()
    if not ImGui.ElementExists('shenanigansMenu') then
      ImGui.CreateMenu('shenanigansMenu', '\u{f6d1} Shenanigans')
    end
  end
  
  function mod:setupImGui()
    ImGui.AddElement('shenanigansMenu', 'shenanigansMenuItemCharacters', ImGuiElement.MenuItem, '\u{f5b3} Character Shenanigans')
    ImGui.CreateWindow('shenanigansWindowCharacters', 'Character Shenanigans')
    ImGui.LinkWindowToElement('shenanigansWindowCharacters', 'shenanigansMenuItemCharacters')
    
    ImGui.AddTabBar('shenanigansWindowCharacters', 'shenanigansTabBarCharacters')
    ImGui.AddTab('shenanigansTabBarCharacters', 'shenanigansTabCharactersRegular', 'Regular')
    ImGui.AddTab('shenanigansTabBarCharacters', 'shenanigansTabCharactersTainted', 'Tainted')
    ImGui.AddTab('shenanigansTabBarCharacters', 'shenanigansTabCharactersRegularModded', 'Regular (Modded)')
    ImGui.AddTab('shenanigansTabBarCharacters', 'shenanigansTabCharactersTaintedModded', 'Tainted (Modded)')
    ImGui.AddTab('shenanigansTabBarCharacters', 'shenanigansTabCharactersBosses', 'Bosses')
    ImGui.AddTab('shenanigansTabBarCharacters', 'shenanigansTabCharactersImportExport', 'Import/Export')
    
    for _, character in ipairs({
                                { id = PlayerType.PLAYER_ISAAC       , tab = 'shenanigansTabCharactersRegular', achievements = { Achievement.ISAAC_HOLDS_THE_D6 }, achievementsText = { 'Start with #THE_D6_NAME?' } },
                                { id = PlayerType.PLAYER_MAGDALENE   , tab = 'shenanigansTabCharactersRegular', achievements = { Achievement.MAGDALENE_HOLDS_A_PILL }, achievementsText = { 'Start with a pill?' } },
                                { id = PlayerType.PLAYER_CAIN        , tab = 'shenanigansTabCharactersRegular', achievements = { Achievement.CAIN_HOLDS_PAPERCLIP }, achievementsText = { 'Start with #PAPER_CLIP_NAME?' } },
                                { id = PlayerType.PLAYER_JUDAS       , tab = 'shenanigansTabCharactersRegular' },
                                { id = PlayerType.PLAYER_BLUEBABY    , tab = 'shenanigansTabCharactersRegular' },
                                { id = PlayerType.PLAYER_EVE         , tab = 'shenanigansTabCharactersRegular', achievements = { Achievement.EVE_HOLDS_RAZOR_BLADE }, achievementsText = { 'Start with #RAZOR_BLADE_NAME?' } },
                                { id = PlayerType.PLAYER_SAMSON      , tab = 'shenanigansTabCharactersRegular', achievements = { Achievement.SAMSON_HOLDS_CHILDS_HEART }, achievementsText = { 'Start with #CHILDS_HEART_NAME?' } },
                                { id = PlayerType.PLAYER_AZAZEL      , tab = 'shenanigansTabCharactersRegular' },
                                { id = PlayerType.PLAYER_LAZARUS     , tab = 'shenanigansTabCharactersRegular', achievements = { Achievement.LAZARUS_HOLDS_ANEMIA }, achievementsText = { 'Start with #ANEMIC_NAME?' } },
                                { id = PlayerType.PLAYER_EDEN        , tab = 'shenanigansTabCharactersRegular' },
                                { id = PlayerType.PLAYER_THELOST     , tab = 'shenanigansTabCharactersRegular', achievements = { Achievement.THE_LOST_HOLDS_HOLY_MANTLE }, achievementsText = { 'Start with #HOLY_MANTLE_NAME?' } },
                                { id = PlayerType.PLAYER_LILITH      , tab = 'shenanigansTabCharactersRegular' },
                                { id = PlayerType.PLAYER_KEEPER      , tab = 'shenanigansTabCharactersRegular', achievements = { Achievement.KEEPER_HOLDS_WOODEN_NICKEL, Achievement.KEEPER_HOLDS_STORE_KEY, Achievement.KEEPER_HOLDS_A_PENNY }, achievementsText = { 'Start with #WOODEN_NICKEL_NAME?', 'Start with #STORE_KEY_NAME?', 'Start with a penny?' } },
                                { id = PlayerType.PLAYER_APOLLYON    , tab = 'shenanigansTabCharactersRegular' },
                                { id = PlayerType.PLAYER_THEFORGOTTEN, tab = 'shenanigansTabCharactersRegular' },
                                { id = PlayerType.PLAYER_BETHANY     , tab = 'shenanigansTabCharactersRegular' },
                                { id = PlayerType.PLAYER_JACOB       , tab = 'shenanigansTabCharactersRegular', id2 = PlayerType.PLAYER_ESAU },
                                { id = PlayerType.PLAYER_ISAAC_B       , tab = 'shenanigansTabCharactersTainted' },
                                { id = PlayerType.PLAYER_MAGDALENE_B   , tab = 'shenanigansTabCharactersTainted' },
                                { id = PlayerType.PLAYER_CAIN_B        , tab = 'shenanigansTabCharactersTainted' },
                                { id = PlayerType.PLAYER_JUDAS_B       , tab = 'shenanigansTabCharactersTainted' },
                                { id = PlayerType.PLAYER_BLUEBABY_B    , tab = 'shenanigansTabCharactersTainted' },
                                { id = PlayerType.PLAYER_EVE_B         , tab = 'shenanigansTabCharactersTainted' },
                                { id = PlayerType.PLAYER_SAMSON_B      , tab = 'shenanigansTabCharactersTainted' },
                                { id = PlayerType.PLAYER_AZAZEL_B      , tab = 'shenanigansTabCharactersTainted' },
                                { id = PlayerType.PLAYER_LAZARUS_B     , tab = 'shenanigansTabCharactersTainted' },
                                { id = PlayerType.PLAYER_EDEN_B        , tab = 'shenanigansTabCharactersTainted' },
                                { id = PlayerType.PLAYER_THELOST_B     , tab = 'shenanigansTabCharactersTainted' },
                                { id = PlayerType.PLAYER_LILITH_B      , tab = 'shenanigansTabCharactersTainted' },
                                { id = PlayerType.PLAYER_KEEPER_B      , tab = 'shenanigansTabCharactersTainted' },
                                { id = PlayerType.PLAYER_APOLLYON_B    , tab = 'shenanigansTabCharactersTainted' },
                                { id = PlayerType.PLAYER_THEFORGOTTEN_B, tab = 'shenanigansTabCharactersTainted' },
                                { id = PlayerType.PLAYER_BETHANY_B     , tab = 'shenanigansTabCharactersTainted' },
                                { id = PlayerType.PLAYER_JACOB_B       , tab = 'shenanigansTabCharactersTainted' },
                              })
    do
      local playerConfig = EntityConfig.GetPlayer(character.id)
      character.name = mod:localize('Players', playerConfig:GetName())
      if character.id2 then
        local playerConfig2 = EntityConfig.GetPlayer(character.id2)
        character.name = character.name .. '+' .. mod:localize('Players', playerConfig2:GetName())
      end
      mod:processCharacter(character)
    end
    
    for _, character in ipairs(mod:getModdedCharacters()) do
      local modName = nil
      local sourceid = mod:getXmlPlayerSourceId(character:GetPlayerType())
      if sourceid then
        modName = mod:getXmlModName(sourceid) or sourceid
      end
      mod:processCharacter({ id = character:GetPlayerType(), name = character:GetName(), tab = character:IsTainted() and 'shenanigansTabCharactersTaintedModded' or 'shenanigansTabCharactersRegularModded', mod = modName })
    end
    
    local longestName = 0
    local completionTypes = {
      { id = CompletionType.MOMS_HEART , entity = EntityType.ENTITY_MOMS_HEART },
      { id = CompletionType.ISAAC      , entity = EntityType.ENTITY_ISAAC },
      { id = CompletionType.SATAN      , entity = EntityType.ENTITY_SATAN },
      { id = CompletionType.BOSS_RUSH  , name = 'Boss Rush' },
      { id = CompletionType.BLUE_BABY  , entity = EntityType.ENTITY_ISAAC, variant = 1 },
      { id = CompletionType.LAMB       , entity = EntityType.ENTITY_THE_LAMB },
      { id = CompletionType.MEGA_SATAN , entity = EntityType.ENTITY_MEGA_SATAN },
      { id = CompletionType.ULTRA_GREED, entity = EntityType.ENTITY_ULTRA_GREED },
      { id = CompletionType.HUSH       , entity = EntityType.ENTITY_HUSH },
      { id = CompletionType.DELIRIUM   , entity = EntityType.ENTITY_DELIRIUM },
      { id = CompletionType.MOTHER     , entity = EntityType.ENTITY_MOTHER },
      { id = CompletionType.BEAST      , entity = EntityType.ENTITY_BEAST },
    }
    for _, boss in ipairs(completionTypes) do
      if boss.entity then
        local entityConfig = EntityConfig.GetEntity(boss.entity, boss.variant)
        boss.name = mod:localize('Entities', entityConfig:GetName())
      end
      local nameLength = utf8.len(boss.name) -- string.len
      if nameLength > longestName then
        longestName = nameLength
      end
    end
    
    ImGui.AddElement('shenanigansTabCharactersBosses', '', ImGuiElement.SeparatorText, 'Completion Marks')
    local txtHelpId = 'shenanigansTxtCharactersBossesHelp'
    ImGui.AddText('shenanigansTabCharactersBosses', '', false, txtHelpId)
    ImGui.SetHelpmarker(txtHelpId, 'Start a new run with selected character(s) + difficulty. Then come back here and choose one or more bosses to receive your completion marks + associated achievements.')
    for i, boss in ipairs(completionTypes) do
      ImGui.AddButton('shenanigansTabCharactersBosses', 'shenanigansBtnCharactersBosses' .. i, mod:padName(boss.name, longestName), function()
        if Isaac.IsInGame() and not game:AchievementUnlocksDisallowed() and Isaac.GetChallenge() == Challenge.CHALLENGE_NULL and game:GetVictoryLap() == 0 then
          local gameData = Isaac.GetPersistentGameData()
          if boss.id == CompletionType.MOMS_HEART then
            gameData:IncreaseEventCounter(EventCounter.MOM_KILLS, 1)
          elseif boss.id == CompletionType.ISAAC then
            gameData:IncreaseEventCounter(EventCounter.ISAAC_KILLS, 1)
          elseif boss.id == CompletionType.SATAN then
            gameData:IncreaseEventCounter(EventCounter.SATAN_KILLS, 1)
          elseif boss.id == CompletionType.BOSS_RUSH then
            gameData:IncreaseEventCounter(EventCounter.BOSSRUSHS_CLEARED, 1)
          elseif boss.id == CompletionType.BLUE_BABY then
            gameData:IncreaseEventCounter(EventCounter.BLUE_BABY_KILLS, 1)
          elseif boss.id == CompletionType.LAMB then
            gameData:IncreaseEventCounter(EventCounter.LAMB_KILLS, 1)
          elseif boss.id == CompletionType.MEGA_SATAN then
            gameData:IncreaseEventCounter(EventCounter.MEGA_SATAN_KILLS, 1)
          elseif boss.id == CompletionType.HUSH then
            gameData:IncreaseEventCounter(EventCounter.HUSH_KILLS, 1)
          elseif boss.id == CompletionType.DELIRIUM then
            gameData:IncreaseEventCounter(EventCounter.DELIRIUM_KILLS, 1)
          elseif boss.id == CompletionType.MOTHER then
            gameData:IncreaseEventCounter(EventCounter.MOTHER_KILLS, 1)
          elseif boss.id == CompletionType.BEAST then
            gameData:IncreaseEventCounter(EventCounter.BEAST_KILLS, 1)
          end
          game:RecordPlayerCompletion(boss.id)
          ImGui.PushNotification('Recorded completion mark: ' .. boss.name, ImGuiNotificationType.SUCCESS, 5000)
        else
          ImGui.PushNotification('Recording completion marks only works in a run (no seeded runs, challenges, victory laps, etc)', ImGuiNotificationType.ERROR, 5000)
        end
      end, false)
      ImGui.AddElement('shenanigansTabCharactersBosses', '', ImGuiElement.SameLine, '')
      local txtStatId = 'shenanigansTxtCharactersBosses' .. i
      ImGui.AddText('shenanigansTabCharactersBosses', '', false, txtStatId)
      ImGui.AddCallback(txtStatId, ImGuiCallback.Render, function()
        local gameData = Isaac.GetPersistentGameData()
        if boss.id == CompletionType.MOMS_HEART then
          ImGui.UpdateText(txtStatId, 'Kills: ' .. gameData:GetEventCounter(EventCounter.MOM_KILLS))
        elseif boss.id == CompletionType.ISAAC then
          ImGui.UpdateText(txtStatId, 'Kills: ' .. gameData:GetEventCounter(EventCounter.ISAAC_KILLS))
        elseif boss.id == CompletionType.SATAN then
          ImGui.UpdateText(txtStatId, 'Kills: ' .. gameData:GetEventCounter(EventCounter.SATAN_KILLS))
        elseif boss.id == CompletionType.BOSS_RUSH then
          ImGui.UpdateText(txtStatId, 'Clears: ' .. gameData:GetEventCounter(EventCounter.BOSSRUSHS_CLEARED))
        elseif boss.id == CompletionType.BLUE_BABY then
          ImGui.UpdateText(txtStatId, 'Kills: ' .. gameData:GetEventCounter(EventCounter.BLUE_BABY_KILLS))
        elseif boss.id == CompletionType.LAMB then
          ImGui.UpdateText(txtStatId, 'Kills: ' .. gameData:GetEventCounter(EventCounter.LAMB_KILLS))
        elseif boss.id == CompletionType.MEGA_SATAN then
          ImGui.UpdateText(txtStatId, 'Kills: ' .. gameData:GetEventCounter(EventCounter.MEGA_SATAN_KILLS))
        elseif boss.id == CompletionType.ULTRA_GREED then
          ImGui.UpdateText(txtStatId, 'Coins: ' .. gameData:GetEventCounter(EventCounter.GREED_DONATION_MACHINE_COUNTER))
        elseif boss.id == CompletionType.HUSH then
          ImGui.UpdateText(txtStatId, 'Kills: ' .. gameData:GetEventCounter(EventCounter.HUSH_KILLS))
        elseif boss.id == CompletionType.DELIRIUM then
          ImGui.UpdateText(txtStatId, 'Kills: ' .. gameData:GetEventCounter(EventCounter.DELIRIUM_KILLS))
        elseif boss.id == CompletionType.MOTHER then
          ImGui.UpdateText(txtStatId, 'Kills: ' .. gameData:GetEventCounter(EventCounter.MOTHER_KILLS))
        elseif boss.id == CompletionType.BEAST then
          ImGui.UpdateText(txtStatId, 'Kills: ' .. gameData:GetEventCounter(EventCounter.BEAST_KILLS))
        end
      end)
    end
    
    local importText = ''
    ImGui.AddElement('shenanigansTabCharactersImportExport', '', ImGuiElement.SeparatorText, 'Import')
    ImGui.AddText('shenanigansTabCharactersImportExport', 'Paste JSON here:', false, '')
    ImGui.AddInputTextMultiline('shenanigansTabCharactersImportExport', 'shenanigansTxtCharactersImport', '', function(txt)
      importText = txt
    end, importText, 12)
    for i, v in ipairs({
                        { text = 'Cut'        , func = function()
                                                         if importText ~= '' then
                                                           Isaac.SetClipboard(importText)
                                                           ImGui.UpdateData('shenanigansTxtCharactersImport', ImGuiData.Value, '')
                                                           importText = ''
                                                         end
                                                       end },
                        { text = 'Copy'       , func = function()
                                                         if importText ~= '' then
                                                           Isaac.SetClipboard(importText)
                                                         end
                                                       end },
                        { text = 'Paste'      , func = function()
                                                         local clipboard = Isaac.GetClipboard()
                                                         if clipboard then
                                                           ImGui.UpdateData('shenanigansTxtCharactersImport', ImGuiData.Value, clipboard)
                                                           importText = clipboard
                                                         end
                                                       end },
                        { text = 'Import JSON', func = function()
                                                         local jsonImported, msg = mod:processImportedJson(importText)
                                                         ImGui.PushNotification(msg, jsonImported and ImGuiNotificationType.SUCCESS or ImGuiNotificationType.ERROR, 5000)
                                                       end },
                      })
    do
      ImGui.AddButton('shenanigansTabCharactersImportExport', 'shenanigansBtnCharactersImport' .. i, v.text, v.func, false)
      if i < 4 then
        ImGui.AddElement('shenanigansTabCharactersImportExport', '', ImGuiElement.SameLine, '')
      end
    end
    
    local exportBooleans = {
      builtInCharacters = true,
      visibleModdedCharacters = true,
      hiddenModdedCharacters = true,
    }
    ImGui.AddElement('shenanigansTabCharactersImportExport', '', ImGuiElement.SeparatorText, 'Export')
    for i, v in ipairs({
                        { text = 'Export built-in characters?'      , exportBoolean = 'builtInCharacters' },
                        { text = 'Export visible modded characters?', exportBoolean = 'visibleModdedCharacters' },
                        { text = 'Export hidden modded characters?' , exportBoolean = 'hiddenModdedCharacters' },
                      })
    do
      local chkCharactersExportId = 'shenanigansChkCharactersExport' .. i
      ImGui.AddCheckbox('shenanigansTabCharactersImportExport', chkCharactersExportId, v.text, function(b)
        exportBooleans[v.exportBoolean] = b
      end, exportBooleans[v.exportBoolean])
    end
    ImGui.AddButton('shenanigansTabCharactersImportExport', 'shenanigansBtnCharactersExport', 'Copy JSON to clipboard', function()
      if Isaac.SetClipboard(mod:getJsonExport(exportBooleans.builtInCharacters, exportBooleans.visibleModdedCharacters, exportBooleans.hiddenModdedCharacters)) then
        ImGui.PushNotification('Copied JSON to clipboard', ImGuiNotificationType.INFO, 5000)
      end
    end, false)
  end
  
  function mod:processCharacter(character)
    ImGui.AddElement(character.tab, '', ImGuiElement.SeparatorText, character.name)
    local chkUnlockedId = 'shenanigansChkCharacterUnlocked' .. character.id
    ImGui.AddCheckbox(character.tab, chkUnlockedId, 'Unlocked?', nil, false)
    if character.mod then
      ImGui.SetHelpmarker(chkUnlockedId, character.mod)
    end
    ImGui.AddCallback(chkUnlockedId, ImGuiCallback.Render, function()
      local gameData = Isaac.GetPersistentGameData()
      local playerConfig = EntityConfig.GetPlayer(character.id)
      local achievement = mod:getAchievementID(playerConfig)
      local unlocked = achievement <= 0 or gameData:Unlocked(achievement)
      ImGui.UpdateData(chkUnlockedId, ImGuiData.Value, unlocked)
    end)
    ImGui.AddCallback(chkUnlockedId, ImGuiCallback.Edited, function(b)
      local playerConfig = EntityConfig.GetPlayer(character.id)
      local achievement = mod:getAchievementID(playerConfig)
      if achievement > 0 then
        mod:unlockLock(achievement, b)
      end
    end)
    if character.achievements then
      for i, achievement in ipairs(character.achievements) do
        local chkAchievementId = 'shenanigansChkCharacterAchievement' .. character.id .. '_' .. achievement
        local chkAchievementText = string.gsub(character.achievementsText[i], '(#[%w_]+)', function(s)
          return mod:localize('Items', s)
        end)
        ImGui.AddCheckbox(character.tab, chkAchievementId, chkAchievementText, nil, false)
        ImGui.AddCallback(chkAchievementId, ImGuiCallback.Render, function()
          local gameData = Isaac.GetPersistentGameData()
          ImGui.UpdateData(chkAchievementId, ImGuiData.Value, gameData:Unlocked(achievement))
        end)
        ImGui.AddCallback(chkAchievementId, ImGuiCallback.Edited, function(b)
          mod:unlockLock(achievement, b)
        end)
      end
    end
    if character.id == PlayerType.PLAYER_EDEN or character.id == PlayerType.PLAYER_EDEN_B then
      local intEdenTokensId = 'shenanigansIntCharacterEdenTokens' .. character.id
      ImGui.AddInputInteger(character.tab, intEdenTokensId, 'Tokens', nil, 0, 1, 100)
      ImGui.AddCallback(intEdenTokensId, ImGuiCallback.Render, function()
        local gameData = Isaac.GetPersistentGameData()
        ImGui.UpdateData(intEdenTokensId, ImGuiData.Value, gameData:GetEventCounter(EventCounter.EDEN_TOKENS))
      end)
      ImGui.AddCallback(intEdenTokensId, ImGuiCallback.Edited, function(num)
        local gameData = Isaac.GetPersistentGameData()
        gameData:IncreaseEventCounter(EventCounter.EDEN_TOKENS, num - gameData:GetEventCounter(EventCounter.EDEN_TOKENS))
      end)
    end
    for _, boss in ipairs({
                           { id = CompletionType.MOMS_HEART , entity = EntityType.ENTITY_MOMS_HEART },
                           { id = CompletionType.ISAAC      , entity = EntityType.ENTITY_ISAAC },
                           { id = CompletionType.SATAN      , entity = EntityType.ENTITY_SATAN },
                           { id = CompletionType.BOSS_RUSH  , name = 'Boss Rush' },
                           { id = CompletionType.BLUE_BABY  , entity = EntityType.ENTITY_ISAAC, variant = 1 },
                           { id = CompletionType.LAMB       , entity = EntityType.ENTITY_THE_LAMB },
                           { id = CompletionType.MEGA_SATAN , entity = EntityType.ENTITY_MEGA_SATAN },
                           { id = CompletionType.ULTRA_GREED, entity = EntityType.ENTITY_ULTRA_GREED }, -- ULTRA_GREEDIER
                           { id = CompletionType.HUSH       , entity = EntityType.ENTITY_HUSH },
                           { id = CompletionType.DELIRIUM   , entity = EntityType.ENTITY_DELIRIUM },
                           { id = CompletionType.MOTHER     , entity = EntityType.ENTITY_MOTHER },
                           { id = CompletionType.BEAST      , entity = EntityType.ENTITY_BEAST },
                         })
    do
      if boss.entity then
        local entityConfig = EntityConfig.GetEntity(boss.entity, boss.variant)
        boss.name = mod:localize('Entities', entityConfig:GetName())
      end
      local cmbCompletionMarkId = 'shenanigansCmbCharacterCompletionMark' .. character.id .. '_' .. boss.id
      ImGui.AddCombobox(character.tab, cmbCompletionMarkId, boss.name, nil, { 'Off', 'Normal', 'Hard' }, 0, true)
      ImGui.AddCallback(cmbCompletionMarkId, ImGuiCallback.Render, function()
        ImGui.UpdateData(cmbCompletionMarkId, ImGuiData.Value, Isaac.GetCompletionMark(character.id, boss.id))
      end)
      ImGui.AddCallback(cmbCompletionMarkId, ImGuiCallback.Edited, function(num)
        Isaac.SetCompletionMark(character.id, boss.id, num)
      end)
    end
  end
  
  mod:setupImGuiMenu()
  mod:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, mod.onModsLoaded)
end