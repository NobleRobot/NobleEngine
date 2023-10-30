class("Spotlight", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.Spotlight
transition.name = "Spotlight"

-- Properties
transition._type = Noble.Transition.Type.COVER

-- Override default arguments
transition.easeEnter = Ease.outQuad
transition.easeExit = Ease.inQuad

-- "Static" variables
local defaultPanelImage

function transition:setCustomArguments(__arguments)
	if (defaultPanelImage == nil) then defaultPanelImage = Graphics.image.new(400,240, Graphics.kColorBlack) end
	self.panelImage = __arguments.panelImage or defaultPanelImage
	self.dither = __arguments.dither or Graphics.image.kDitherTypeBayer4x4
	self.x = __arguments.x or 200
	self.y = __arguments.y or 120
	
	
	self.xEnter = __arguments.xEnter or self.x
	self.yEnter = __arguments.yEnter or self.y
	self.xEnterStart = __arguments.xEnterStart or self.xEnter
	self.yEnterStart = __arguments.yEnterStart or self.yEnter
	self.xEnterEnd = __arguments.xEnterEnd or self.xEnter
	self.yEnterEnd = __arguments.yEnterEnd or self.yEnter

	self.xExit = __arguments.xExit or self.x
	self.yExit = __arguments.yExit or self.y
	self.xExitStart = __arguments.xExitStart or self.xExit
	self.yExitStart = __arguments.yExitStart or self.yExit
	self.xExitEnd = __arguments.xExitEnd or self.xExit
	self.yExitEnd = __arguments.yExitEnd or self.yExit
end

function transition:draw()
	local progress = self.sequence:get()
	self.panelImage:drawFaded(0, 0, progress, self.dither)
	Graphics.setColor(Graphics.kColorClear)
	if (not self.midpointReached) then
		Graphics.fillCircleAtPoint(
			math.lerp(self.xEnterStart, self.xEnterEnd, progress),
			math.lerp(self.yEnterStart, self.yEnterEnd, progress),
			(1 - progress) * 233
		)
	else
		Graphics.fillCircleAtPoint(
			math.lerp(self.xExitStart, self.xExitEnd, progress),
			math.lerp(self.yExitStart, self.yExitEnd, progress),
			(1 - progress) * 233
		)
	end
	Graphics.setColor(Graphics.kColorBlack)
end