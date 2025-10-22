ExampleScene = {}
class("ExampleScene").extends(NobleScene)
local scene = ExampleScene

function scene:setValues()
	self.background = Graphics.image.new("assets/images/background1")

	self.color1 = Graphics.kColorBlack
	self.color2 = Graphics.kColorWhite

	self.menu = nil
	self.sequence = nil

	-- self.menuX = 128
	self.menuX = 200
	self.menuY = 174
end

function scene:init()
	scene.super.init(self)

	self.logo = Graphics.image.new("libraries/noble/assets/images/NobleRobotLogo")

	self:setValues()

	self.menu = Noble.Menu.new(false, Noble.Text.ALIGN_CENTER, false, self.color1, 8,8,0, Noble.Text.FONT_MEDIUM, 4)

	self:setupMenu(self.menu)

	local crankTick = 0

	self.inputHandler = {
		upButtonDown = function()
			self.menu:selectPrevious()
		end,
		downButtonDown = function()
			self.menu:selectNext()
		end,
		cranked = function(change, acceleratedChange)
			crankTick = crankTick + change
			if (crankTick > 30) then
				crankTick = 0
				self.menu:selectNext()
			elseif (crankTick < -30) then
				crankTick = 0
				self.menu:selectPrevious()
			end
		end,
		AButtonDown = function()
			self.menu:click()
		end
	}

end

function scene:enter()
	scene.super.enter(self)
	self.sequence = Sequence.new():from(self.menuY):to(self.menuY):start()
end

function scene:start()
	scene.super.start(self)
	self.menu:activate()
end

function scene:drawBackground()
	scene.super.drawBackground(self)
	self.background:draw(0, 0)
end

function scene:update()
	scene.super.update(self)

	Graphics.setColor(self.color2)
	Graphics.setDitherPattern(0.2, Graphics.image.kDitherTypeScreen)
	self.menu:draw(self.menuX, self.sequence:get() or self.menuY)

	Graphics.setColor(Graphics.kColorWhite)
end

function scene:exit()
	scene.super.exit(self)
	self.sequence = Sequence.new():from(self.menuY):to(self.menuY)
	self.sequence:start();
end

function scene:setupMenu(__menu)
	__menu:addItem("New Game", function() Noble.transition(ExampleScene2, nil, Noble.Transition.DipToBlack) end)
end