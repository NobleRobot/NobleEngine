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
	self.xExit = __arguments.xExit or self.x
	self.yExit = __arguments.yExit or self.y
end

function transition:draw()
	local progress = self.sequence:get()
	self.panelImage:drawFaded(0, 0, progress, self.dither)
	Graphics.setColor(Graphics.kColorClear)
	if (not self.midpointReached ) then
		Graphics.fillCircleAtPoint(self.xEnter, self.yEnter, (1 - progress) * 400)
	else
		Graphics.fillCircleAtPoint(self.xExit, self.yExit, (1 - progress) * 400)
	end
	Graphics.setColor(Graphics.kColorBlack)
end