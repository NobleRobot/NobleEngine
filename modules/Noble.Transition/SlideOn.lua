class("SlideOn", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.SlideOn
transition.name = "Slide On"

-- Properties
transition._type = Noble.Transition.Type.MIX
transition._sequenceStartValue = 1
transition._sequenceCompleteValue = 0
transition._captureScreenshotsDuringTransition = true

-- Override default arguments
transition.ease = Ease.outQuart

function transition:setCustomArguments(__arguments)
	self.x = __arguments.x or 0
	self.y = __arguments.y or 0
	self.rotation = __arguments.rotation or 0
end

function transition:draw()
	transition.super.draw(self)
	local progress = self.sequence:get()
	self.oldSceneScreenshot:draw(0,0)
	self.newSceneScreenshot:drawRotated(
		self.x * progress + 200,
		self.y * progress + 120,
		self.rotation * progress
	)
end