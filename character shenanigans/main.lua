local mod = RegisterMod('Character Shenanigans', 1)

if REPENTOGON then
  function mod:onSaveSlotLoad()
    mod:RemoveCallback(ModCallbacks.MC_POST_SAVESLOT_LOAD, mod.onSaveSlotLoad)
    mod:setupImGui()
  end
  
  function mod:getModdedCharacters()
    local i = PlayerType.NUM_PLAYER_TYPES -- 41, EntityConfig.GetMaxPlayerType()
    local playerConfig = EntityConfig.GetPlayer(i)
    local characters = {}
    
    while playerConfig do
      if not playerConfig:IsHidden() then
        table.insert(characters, { id = i, config = playerConfig })
      end
      
      i = i + 1
      playerConfig = EntityConfig.GetPlayer(i)
    end
    
    return characters
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
                                -- this mostly works, but doesn't include things like "Tainted" or "and Esau"
                                -- Isaac.GetString('Players', EntityConfig.GetPlayer(character.id):GetName())
                                { name = 'Isaac'         , id = PlayerType.PLAYER_ISAAC       , tab = 'shenanigansTabCharactersRegular', achievements = { Achievement.ISAAC_HOLDS_THE_D6 }, achievementsText = { 'Start with The D6?' } },
                                { name = 'Magdalene'     , id = PlayerType.PLAYER_MAGDALENE   , tab = 'shenanigansTabCharactersRegular', achievements = { Achievement.MAGDALENE_HOLDS_A_PILL }, achievementsText = { 'Start with a pill?' } },
                                { name = 'Cain'          , id = PlayerType.PLAYER_CAIN        , tab = 'shenanigansTabCharactersRegular', achievements = { Achievement.CAIN_HOLDS_PAPERCLIP }, achievementsText = { 'Start with Paper Clip?' } },
                                { name = 'Judas'         , id = PlayerType.PLAYER_JUDAS       , tab = 'shenanigansTabCharactersRegular' },
                                { name = '???'           , id = PlayerType.PLAYER_BLUEBABY    , tab = 'shenanigansTabCharactersRegular' },
                                { name = 'Eve'           , id = PlayerType.PLAYER_EVE         , tab = 'shenanigansTabCharactersRegular', achievements = { Achievement.EVE_HOLDS_RAZOR_BLADE }, achievementsText = { 'Start with Razor Blade?' } },
                                { name = 'Samson'        , id = PlayerType.PLAYER_SAMSON      , tab = 'shenanigansTabCharactersRegular', achievements = { Achievement.SAMSON_HOLDS_CHILDS_HEART }, achievementsText = { 'Start with Child\'s Heart?' } },
                                { name = 'Azazel'        , id = PlayerType.PLAYER_AZAZEL      , tab = 'shenanigansTabCharactersRegular' },
                                { name = 'Lazarus'       , id = PlayerType.PLAYER_LAZARUS     , tab = 'shenanigansTabCharactersRegular', achievements = { Achievement.LAZARUS_HOLDS_ANEMIA }, achievementsText = { 'Start with Anemic?' } },
                                { name = 'Eden'          , id = PlayerType.PLAYER_EDEN        , tab = 'shenanigansTabCharactersRegular' },
                                { name = 'The Lost'      , id = PlayerType.PLAYER_THELOST     , tab = 'shenanigansTabCharactersRegular', achievements = { Achievement.THE_LOST_HOLDS_HOLY_MANTLE }, achievementsText = { 'Start with Holy Mantle?' } },
                                { name = 'Lilith'        , id = PlayerType.PLAYER_LILITH      , tab = 'shenanigansTabCharactersRegular' },
                                { name = 'Keeper'        , id = PlayerType.PLAYER_KEEPER      , tab = 'shenanigansTabCharactersRegular', achievements = { Achievement.KEEPER_HOLDS_WOODEN_NICKEL, Achievement.KEEPER_HOLDS_STORE_KEY, Achievement.KEEPER_HOLDS_A_PENNY }, achievementsText = { 'Start with Wooden Nickel?', 'Start with Store Key?', 'Start with a penny?' } },
                                { name = 'Apollyon'      , id = PlayerType.PLAYER_APOLLYON    , tab = 'shenanigansTabCharactersRegular' },
                                { name = 'The Forgotten' , id = PlayerType.PLAYER_THEFORGOTTEN, tab = 'shenanigansTabCharactersRegular' },
                                { name = 'Bethany'       , id = PlayerType.PLAYER_BETHANY     , tab = 'shenanigansTabCharactersRegular' },
                                { name = 'Jacob and Esau', id = PlayerType.PLAYER_JACOB       , tab = 'shenanigansTabCharactersRegular' },
                                { name = 'Tainted Isaac'    , id = PlayerType.PLAYER_ISAAC_B       , tab = 'shenanigansTabCharactersTainted' },
                                { name = 'Tainted Magdalene', id = PlayerType.PLAYER_MAGDALENE_B   , tab = 'shenanigansTabCharactersTainted' },
                                { name = 'Tainted Cain'     , id = PlayerType.PLAYER_CAIN_B        , tab = 'shenanigansTabCharactersTainted' },
                                { name = 'Tainted Judas'    , id = PlayerType.PLAYER_JUDAS_B       , tab = 'shenanigansTabCharactersTainted' },
                                { name = 'Tainted ???'      , id = PlayerType.PLAYER_BLUEBABY_B    , tab = 'shenanigansTabCharactersTainted' },
                                { name = 'Tainted Eve'      , id = PlayerType.PLAYER_EVE_B         , tab = 'shenanigansTabCharactersTainted' },
                                { name = 'Tainted Samson'   , id = PlayerType.PLAYER_SAMSON_B      , tab = 'shenanigansTabCharactersTainted' },
                                { name = 'Tainted Azazel'   , id = PlayerType.PLAYER_AZAZEL_B      , tab = 'shenanigansTabCharactersTainted' },
                                { name = 'Tainted Lazarus'  , id = PlayerType.PLAYER_LAZARUS_B     , tab = 'shenanigansTabCharactersTainted' },
                                { name = 'Tainted Eden'     , id = PlayerType.PLAYER_EDEN_B        , tab = 'shenanigansTabCharactersTainted' },
                                { name = 'Tainted Lost'     , id = PlayerType.PLAYER_THELOST_B     , tab = 'shenanigansTabCharactersTainted' },
                                { name = 'Tainted Lilith'   , id = PlayerType.PLAYER_LILITH_B      , tab = 'shenanigansTabCharactersTainted' },
                                { name = 'Tainted Keeper'   , id = PlayerType.PLAYER_KEEPER_B      , tab = 'shenanigansTabCharactersTainted' },
                                { name = 'Tainted Apollyon' , id = PlayerType.PLAYER_APOLLYON_B    , tab = 'shenanigansTabCharactersTainted' },
                                { name = 'Tainted Forgotten', id = PlayerType.PLAYER_THEFORGOTTEN_B, tab = 'shenanigansTabCharactersTainted' },
                                { name = 'Tainted Bethany'  , id = PlayerType.PLAYER_BETHANY_B     , tab = 'shenanigansTabCharactersTainted' },
                                { name = 'Tainted Jacob'    , id = PlayerType.PLAYER_JACOB_B       , tab = 'shenanigansTabCharactersTainted' },
                              })
    do
      mod:processCharacter(character)
    end
    
    for _, character in ipairs(mod:getModdedCharacters()) do
      mod:processCharacter({ name = character.config:GetName(), id = character.id, tab = character.config:IsTainted() and 'shenanigansTabCharactersTaintedModded' or 'shenanigansTabCharactersRegularModded' })
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
        ImGui.AddCheckbox(character.tab, chkAchievementId, character.achievementsText[i], nil, false)
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
                           { name = 'Mom\'s Heart'  , id = CompletionType.MOMS_HEART },
                           { name = 'Isaac'         , id = CompletionType.ISAAC },
                           { name = 'Satan'         , id = CompletionType.SATAN },
                           { name = 'Boss Rush'     , id = CompletionType.BOSS_RUSH },
                           { name = '???'           , id = CompletionType.BLUE_BABY },
                           { name = 'The Lamb'      , id = CompletionType.LAMB },
                           { name = 'Mega Satan'    , id = CompletionType.MEGA_SATAN },
                           { name = 'Ultra Greed'   , id = CompletionType.ULTRA_GREED }, -- ULTRA_GREEDIER
                           { name = 'Hush'          , id = CompletionType.HUSH },
                           { name = 'Delirium'      , id = CompletionType.DELIRIUM },
                           { name = 'Mother'        , id = CompletionType.MOTHER },
                           { name = 'The Beast'     , id = CompletionType.BEAST },
                         })
    do
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