--- The existing scene slides off the screen, revealing the next scene.

class("SlideOff", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.SlideOff
transition.name = "Slide Off"

-- Properties
transition._type = Noble.Transition.Type.MIX

-- Override default arguments
transition.ease = Ease.inQuart

function transition:setCustomArguments(__arguments)
	self.x = __arguments.x or 0
	self.y = __arguments.y or 0
	self.rotation = __arguments.rotation or 0
end

function transition:draw()
	transition.super.draw(self)
	local progress = self.sequence:get()
	self.oldSceneScreenshot:drawRotated(
		self.x * progress + 200,
		self.y * progress + 120,
		self.rotation * progress
	)
end