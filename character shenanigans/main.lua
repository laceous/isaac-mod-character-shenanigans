local mod = RegisterMod('Character Shenanigans', 1)
local json = require('json')

if REPENTOGON then
  function mod:onRender()
    mod:RemoveCallback(ModCallbacks.MC_MAIN_MENU_RENDER, mod.onRender)
    mod:RemoveCallback(ModCallbacks.MC_POST_RENDER, mod.onRender)
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
  
  function mod:localize(category, key)
    local s = Isaac.GetString(category, key)
    return (s == nil or s == 'StringTable::InvalidCategory' or s == 'StringTable::InvalidKey') and key or s
  end
  
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
  
  function mod:getModdedCharacterId(sourceIdAndName)
    for _, character in ipairs(mod:getModdedCharacters()) do
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
      gameData:TryUnlock(achievement) -- Isaac.ExecuteCommand('achievement ' .. achievement)
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
              if math.type(boss) == 'integer' and math.type(w) == 'integer' and mod:isBossType(boss) and w >= 0 then -- 0=off,1=normal,>=2=hard
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
  
  function mod:getJsonExport(inclBuiltInCharacters, inclModdedCharacters)
    local s = '{'
    
    s = s .. '\n  "completionMarks": {'
    local hasAtLeastOneCharacter = false
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
          s = s .. mod:getJsonCharacterExport(character, name)
          hasAtLeastOneCharacter = true
        end
      end
    end
    if inclModdedCharacters then
      for _, character in ipairs(mod:getModdedCharacters()) do
        local sourceId = mod:getXmlPlayerSourceId(character:GetPlayerType())
        if sourceId then
          local name = 'M-' .. sourceId .. '-' .. character:GetName()
          if character:IsTainted() then
            name = name .. '-Tainted-'
          end
          s = s .. mod:getJsonCharacterExport(character:GetPlayerType(), name)
          hasAtLeastOneCharacter = true
        end
      end
    end
    if hasAtLeastOneCharacter then
      s = string.sub(s, 1, -2) -- strip last comma
    end
    s = s .. '\n  }'
    
    s = s .. '\n}'
    return s
  end
  
  function mod:getJsonCharacterExport(character, name)
    local s = ''
    
    s = s .. '\n    ' .. json.encode(name) .. ': {'
    local hasAtLeastOneBoss = false
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
        s = s .. '\n      ' .. json.encode(boss .. '-' .. keys[1]) .. ': ' .. math.floor(Isaac.GetCompletionMark(character, boss)) .. ','
        hasAtLeastOneBoss = true
      end
    end
    if hasAtLeastOneBoss then
      s = string.sub(s, 1, -2)
    end
    s = s .. '\n    },'
    
    return s
  end
  
  function mod:setupImGui()
    if not ImGui.ElementExists('shenanigansMenu') then
      ImGui.CreateMenu('shenanigansMenu', '\u{f6d1} Shenanigans')
    end
    ImGui.AddElement('shenanigansMenu', 'shenanigansMenuItemCharacters', ImGuiElement.MenuItem, '\u{f5b3} Character Shenanigans')
    ImGui.CreateWindow('shenanigansWindowCharacters', 'Character Shenanigans')
    ImGui.LinkWindowToElement('shenanigansWindowCharacters', 'shenanigansMenuItemCharacters')
    
    ImGui.AddTabBar('shenanigansWindowCharacters', 'shenanigansTabBarCharacters')
    ImGui.AddTab('shenanigansTabBarCharacters', 'shenanigansTabCharactersRegular', 'Regular')
    ImGui.AddTab('shenanigansTabBarCharacters', 'shenanigansTabCharactersTainted', 'Tainted')
    ImGui.AddTab('shenanigansTabBarCharacters', 'shenanigansTabCharactersRegularModded', 'Regular (Modded)')
    ImGui.AddTab('shenanigansTabBarCharacters', 'shenanigansTabCharactersTaintedModded', 'Tainted (Modded)')
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
      mod:processCharacter({ id = character:GetPlayerType(), name = character:GetName(), tab = character:IsTainted() and 'shenanigansTabCharactersTaintedModded' or 'shenanigansTabCharactersRegularModded' })
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
      moddedCharacters = true,
    }
    ImGui.AddElement('shenanigansTabCharactersImportExport', '', ImGuiElement.SeparatorText, 'Export')
    for i, v in ipairs({
                        { text = 'Export built-in characters?', exportBoolean = 'builtInCharacters' },
                        { text = 'Export modded characters?'  , exportBoolean = 'moddedCharacters' },
                      })
    do
      local chkCharactersExportId = 'shenanigansChkCharactersExport' .. i
      ImGui.AddCheckbox('shenanigansTabCharactersImportExport', chkCharactersExportId, v.text, function(b)
        exportBooleans[v.exportBoolean] = b
      end, exportBooleans[v.exportBoolean])
    end
    ImGui.AddButton('shenanigansTabCharactersImportExport', 'shenanigansBtnCharactersExport', 'Copy JSON to clipboard', function()
      Isaac.SetClipboard(mod:getJsonExport(exportBooleans.builtInCharacters, exportBooleans.moddedCharacters))
      ImGui.PushNotification('Copied JSON to clipboard', ImGuiNotificationType.INFO, 5000)
    end, false)
  end
  
  function mod:processCharacter(character)
    ImGui.AddElement(character.tab, '', ImGuiElement.SeparatorText, character.name)
    local chkUnlockedId = 'shenanigansChkCharacterUnlocked' .. character.id
    ImGui.AddCheckbox(character.tab, chkUnlockedId, 'Unlocked?', nil, false)
    ImGui.AddCallback(chkUnlockedId, ImGuiCallback.Render, function()
      local gameData = Isaac.GetPersistentGameData()
      local playerConfig = EntityConfig.GetPlayer(character.id)
      local achievement = playerConfig:GetAchievementID()
      local unlocked = achievement <= 0 or gameData:Unlocked(achievement)
      ImGui.UpdateData(chkUnlockedId, ImGuiData.Value, unlocked)
    end)
    ImGui.AddCallback(chkUnlockedId, ImGuiCallback.Edited, function(b)
      local playerConfig = EntityConfig.GetPlayer(character.id)
      local achievement = playerConfig:GetAchievementID()
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
  
  -- launch options allow you to skip the menu
  mod:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, mod.onRender)
  mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.onRender)
end