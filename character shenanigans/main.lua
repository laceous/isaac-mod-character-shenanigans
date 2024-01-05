local mod = RegisterMod('Character Shenanigans', 1)

if REPENTOGON then
  function mod:onSaveSlotLoad()
    mod:RemoveCallback(ModCallbacks.MC_POST_SAVESLOT_LOAD, mod.onSaveSlotLoad)
    mod:setupImGui()
  end
  
  function mod:localize(category, key)
    local s = Isaac.GetString(category, key)
    return (s == nil or s == 'StringTable::InvalidCategory' or s == 'StringTable::InvalidKey') and key or s
  end
  
  function mod:getModdedCharacters()
    local i = PlayerType.NUM_PLAYER_TYPES -- 41, EntityConfig.GetMaxPlayerType()
    local playerConfig = EntityConfig.GetPlayer(i)
    local characters = {}
    
    while playerConfig do
      if not playerConfig:IsHidden() and not playerConfig:IsTainted() then
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
  
  function mod:hasPlayerType(characters, playerType)
    for _, character in ipairs(characters) do
      if character:GetPlayerType() == playerType then
        return true
      end
    end
    
    return false
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
      local gameData = Isaac.GetPersistentGameData()
      local playerConfig = EntityConfig.GetPlayer(character.id)
      local achievement = playerConfig:GetAchievementID()
      if achievement > 0 then
        if b then
          gameData:TryUnlock(achievement) -- Isaac.ExecuteCommand('achievement ' .. achievement)
        else
          Isaac.ExecuteCommand('lockachievement ' .. achievement)
        end
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
          local gameData = Isaac.GetPersistentGameData()
          if b then
            gameData:TryUnlock(achievement)
          else
            Isaac.ExecuteCommand('lockachievement ' .. achievement)
          end
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
  
  mod:AddCallback(ModCallbacks.MC_POST_SAVESLOT_LOAD, mod.onSaveSlotLoad)
end