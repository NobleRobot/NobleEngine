class("SlideOn", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.SlideOn
transition.name = "Slide On"

transition.type = Noble.Transition.Type.MIX
transition.ease = Ease.outQuart
transition._sequenceStartValue = 1
transition._sequenceCompleteValue = 0
transition.captureScreenshotsDuringTransition = true

function transition:setCustomArguments(__arguments)
	self.x = __arguments.x
	self.y = __arguments.y
end

function transition:draw()
	transition.super.draw(self)
	local progress = self.sequence:get()
	self.oldSceneScreenshot:draw(0,0)
	self.newSceneScreenshot:draw(
		self.x * progress,
		self.y * progress
	)
end