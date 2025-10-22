import 'libraries/noble/Noble'

import 'utilities/Utilities'

import 'scenes/MainMenuScene'
import 'scenes/HouseScene'

-- Set up global variables
Global.GamePlayingField = nil

-- Set up Noble settings and game data
Noble.Settings.setup({
	Difficulty = "Medium"
})

Noble.GameData.setup({
	Score = 0
})

Noble.showFPS = true

Noble.new(MainMenuScene)