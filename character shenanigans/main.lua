local mod = RegisterMod('Character Shenanigans', 1)

if REPENTOGON then
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
    
    for _, player in ipairs({
                             { name = 'Isaac'         , type = PlayerType.PLAYER_ISAAC       , tab = 'shenanigansTabCharactersRegular', achievements = { Achievement.ISAAC_HOLDS_THE_D6 }, achievementsText = { 'Start with The D6?' } },
                             { name = 'Magdalene'     , type = PlayerType.PLAYER_MAGDALENE   , tab = 'shenanigansTabCharactersRegular', achievements = { Achievement.MAGDALENE_HOLDS_A_PILL }, achievementsText = { 'Start with a pill?' } },
                             { name = 'Cain'          , type = PlayerType.PLAYER_CAIN        , tab = 'shenanigansTabCharactersRegular', achievements = { Achievement.CAIN_HOLDS_PAPERCLIP }, achievementsText = { 'Start with Paper Clip?' } },
                             { name = 'Judas'         , type = PlayerType.PLAYER_JUDAS       , tab = 'shenanigansTabCharactersRegular' },
                             { name = '???'           , type = PlayerType.PLAYER_BLUEBABY    , tab = 'shenanigansTabCharactersRegular' },
                             { name = 'Eve'           , type = PlayerType.PLAYER_EVE         , tab = 'shenanigansTabCharactersRegular', achievements = { Achievement.EVE_HOLDS_RAZOR_BLADE }, achievementsText = { 'Start with Razor Blade?' } },
                             { name = 'Samson'        , type = PlayerType.PLAYER_SAMSON      , tab = 'shenanigansTabCharactersRegular', achievements = { Achievement.SAMSON_HOLDS_CHILDS_HEART }, achievementsText = { 'Start with Child\'s Heart?' } },
                             { name = 'Azazel'        , type = PlayerType.PLAYER_AZAZEL      , tab = 'shenanigansTabCharactersRegular' },
                             { name = 'Lazarus'       , type = PlayerType.PLAYER_LAZARUS     , tab = 'shenanigansTabCharactersRegular', achievements = { Achievement.LAZARUS_HOLDS_ANEMIA }, achievementsText = { 'Start with Anemic?' } },
                             { name = 'Eden'          , type = PlayerType.PLAYER_EDEN        , tab = 'shenanigansTabCharactersRegular' },
                             { name = 'The Lost'      , type = PlayerType.PLAYER_THELOST     , tab = 'shenanigansTabCharactersRegular', achievements = { Achievement.THE_LOST_HOLDS_HOLY_MANTLE }, achievementsText = { 'Start with Holy Mantle?' } },
                             { name = 'Lilith'        , type = PlayerType.PLAYER_LILITH      , tab = 'shenanigansTabCharactersRegular' },
                             { name = 'Keeper'        , type = PlayerType.PLAYER_KEEPER      , tab = 'shenanigansTabCharactersRegular', achievements = { Achievement.KEEPER_HOLDS_WOODEN_NICKEL, Achievement.KEEPER_HOLDS_STORE_KEY, Achievement.KEEPER_HOLDS_A_PENNY }, achievementsText = { 'Start with Wooden Nickel?', 'Start with Store Key?', 'Start with a penny?' } },
                             { name = 'Apollyon'      , type = PlayerType.PLAYER_APOLLYON    , tab = 'shenanigansTabCharactersRegular' },
                             { name = 'The Forgotten' , type = PlayerType.PLAYER_THEFORGOTTEN, tab = 'shenanigansTabCharactersRegular' },
                             { name = 'Bethany'       , type = PlayerType.PLAYER_BETHANY     , tab = 'shenanigansTabCharactersRegular' },
                             { name = 'Jacob and Esau', type = PlayerType.PLAYER_JACOB       , tab = 'shenanigansTabCharactersRegular' },
                             { name = 'Tainted Isaac'    , type = PlayerType.PLAYER_ISAAC_B       , tab = 'shenanigansTabCharactersTainted' },
                             { name = 'Tainted Magdalene', type = PlayerType.PLAYER_MAGDALENE_B   , tab = 'shenanigansTabCharactersTainted' },
                             { name = 'Tainted Cain'     , type = PlayerType.PLAYER_CAIN_B        , tab = 'shenanigansTabCharactersTainted' },
                             { name = 'Tainted Judas'    , type = PlayerType.PLAYER_JUDAS_B       , tab = 'shenanigansTabCharactersTainted' },
                             { name = 'Tainted ???'      , type = PlayerType.PLAYER_BLUEBABY_B    , tab = 'shenanigansTabCharactersTainted' },
                             { name = 'Tainted Eve'      , type = PlayerType.PLAYER_EVE_B         , tab = 'shenanigansTabCharactersTainted' },
                             { name = 'Tainted Samson'   , type = PlayerType.PLAYER_SAMSON_B      , tab = 'shenanigansTabCharactersTainted' },
                             { name = 'Tainted Azazel'   , type = PlayerType.PLAYER_AZAZEL_B      , tab = 'shenanigansTabCharactersTainted' },
                             { name = 'Tainted Lazarus'  , type = PlayerType.PLAYER_LAZARUS_B     , tab = 'shenanigansTabCharactersTainted' },
                             { name = 'Tainted Eden'     , type = PlayerType.PLAYER_EDEN_B        , tab = 'shenanigansTabCharactersTainted' },
                             { name = 'Tainted Lost'     , type = PlayerType.PLAYER_THELOST_B     , tab = 'shenanigansTabCharactersTainted' },
                             { name = 'Tainted Lilith'   , type = PlayerType.PLAYER_LILITH_B      , tab = 'shenanigansTabCharactersTainted' },
                             { name = 'Tainted Keeper'   , type = PlayerType.PLAYER_KEEPER_B      , tab = 'shenanigansTabCharactersTainted' },
                             { name = 'Tainted Apollyon' , type = PlayerType.PLAYER_APOLLYON_B    , tab = 'shenanigansTabCharactersTainted' },
                             { name = 'Tainted Forgotten', type = PlayerType.PLAYER_THEFORGOTTEN_B, tab = 'shenanigansTabCharactersTainted' },
                             { name = 'Tainted Bethany'  , type = PlayerType.PLAYER_BETHANY_B     , tab = 'shenanigansTabCharactersTainted' },
                             { name = 'Tainted Jacob'    , type = PlayerType.PLAYER_JACOB_B       , tab = 'shenanigansTabCharactersTainted' },
                           })
    do
      ImGui.AddElement(player.tab, '', ImGuiElement.SeparatorText, player.name)
      local chkUnlockedId = 'shenanigansChkCharacterUnlocked' .. player.type
      ImGui.AddCheckbox(player.tab, chkUnlockedId, 'Unlocked?', nil, false)
      ImGui.AddCallback(chkUnlockedId, ImGuiCallback.Render, function()
        local gameData = Isaac.GetPersistentGameData()
        local playerConfig = EntityConfig.GetPlayer(player.type)
        local achievement = playerConfig:GetAchievementID()
        local unlocked = achievement <= 0 or gameData:Unlocked(achievement)
        ImGui.UpdateData(chkUnlockedId, ImGuiData.Value, unlocked)
      end)
      ImGui.AddCallback(chkUnlockedId, ImGuiCallback.Edited, function(b)
        local gameData = Isaac.GetPersistentGameData()
        local playerConfig = EntityConfig.GetPlayer(player.type)
        local achievement = playerConfig:GetAchievementID()
        if achievement > 0 then
          if b then
            gameData:TryUnlock(achievement) -- Isaac.ExecuteCommand('achievement ' .. achievement)
          else
            Isaac.ExecuteCommand('lockachievement ' .. achievement)
          end
        end
      end)
      if player.type == PlayerType.PLAYER_EDEN or player.type == PlayerType.PLAYER_EDEN_B then
        local intEdenTokensId = 'shenanigansIntCharacterEdenTokens' .. player.type
        ImGui.AddInputInteger(player.tab, intEdenTokensId, 'Tokens', nil, 0, 1, 100)
        ImGui.AddCallback(intEdenTokensId, ImGuiCallback.Render, function()
          local gameData = Isaac.GetPersistentGameData()
          ImGui.UpdateData(intEdenTokensId, ImGuiData.Value, gameData:GetEventCounter(EventCounter.EDEN_TOKENS))
        end)
        ImGui.AddCallback(intEdenTokensId, ImGuiCallback.Edited, function(num)
          local gameData = Isaac.GetPersistentGameData()
          gameData:IncreaseEventCounter(EventCounter.EDEN_TOKENS, num - gameData:GetEventCounter(EventCounter.EDEN_TOKENS))
        end)
      end
      if player.achievements then
        for i, achievement in ipairs(player.achievements) do
          local chkAchievementId = 'shenanigansChkCharacterAchievement' .. player.type .. '_' .. achievement
          ImGui.AddCheckbox(player.tab, chkAchievementId, player.achievementsText[i], nil, false)
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
      for _, boss in ipairs({
                             { name = 'Mom\'s Heart'  , type = CompletionType.MOMS_HEART },
                             { name = 'Isaac'         , type = CompletionType.ISAAC },
                             { name = 'Satan'         , type = CompletionType.SATAN },
                             { name = 'Boss Rush'     , type = CompletionType.BOSS_RUSH },
                             { name = '???'           , type = CompletionType.BLUE_BABY },
                             { name = 'The Lamb'      , type = CompletionType.LAMB },
                             { name = 'Mega Satan'    , type = CompletionType.MEGA_SATAN },
                             { name = 'Ultra Greed'   , type = CompletionType.ULTRA_GREED }, -- ULTRA_GREEDIER
                             { name = 'Hush'          , type = CompletionType.HUSH },
                             { name = 'Delirium'      , type = CompletionType.DELIRIUM },
                             { name = 'Mother'        , type = CompletionType.MOTHER },
                             { name = 'The Beast'     , type = CompletionType.BEAST },
                           })
      do
        local cmbCompletionMarkId = 'shenanigansCmbCharacterCompletionMark' .. player.type .. '_' .. boss.type
        ImGui.AddCombobox(player.tab, cmbCompletionMarkId, boss.name, nil, { 'Off', 'Normal', 'Hard' }, 0, true)
        ImGui.AddCallback(cmbCompletionMarkId, ImGuiCallback.Render, function()
          ImGui.UpdateData(cmbCompletionMarkId, ImGuiData.Value, Isaac.GetCompletionMark(player.type, boss.type))
        end)
        ImGui.AddCallback(cmbCompletionMarkId, ImGuiCallback.Edited, function(num)
          Isaac.SetCompletionMark(player.type, boss.type, num)
        end)
      end
    end
  end
  
  mod:setupImGui()
end