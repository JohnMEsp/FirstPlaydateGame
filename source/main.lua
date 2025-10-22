import 'libraries/noble/Noble'

import 'utilities/Utilities'

import 'scenes/MainMenuScene'
import 'scenes/HouseScene'

Noble.Settings.setup({
	Difficulty = "Medium"
})

Noble.GameData.setup({
	Score = 0
})

Noble.showFPS = true

Noble.new(MainMenuScene)