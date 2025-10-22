ExampleScene2 = {}
class("ExampleScene2").extends(ExampleScene)
local scene = ExampleScene2

function scene:setValues()
	scene.super.setValues(self)

	self.background = Graphics.image.new("assets/images/background2")

	self.color1 = Graphics.kColorWhite
	self.color2 = Graphics.kColorBlack

	self.menuX = 200
	self.menuY = 15
end

function scene:setupMenu(__menu)
	__menu:addItem("Exit", function() Noble.transition(ExampleScene, nil, Noble.Transition.DipToWhite) end)
end