class("Spotlight", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.Spotlight

transition.name = "Spotlight"
transition.type = Noble.Transition.Type.COVER

transition.easeIn = Ease.outQuad
transition.easeOut = Ease.inQuad

local panel

function transition:setCustomArguments(__arguments)
	if (panel == nil) then panel = Graphics.image.new(400,240, Graphics.kColorBlack) end
	self.dither = __arguments.dither or Graphics.image.kDitherTypeBayer4x4
	self.inX = __arguments.inX or 200
	self.inY = __arguments.inY or 120
	self.outX = __arguments.outX or self.inX
	self.outY = __arguments.outY or self.inY
end

function transition:draw()
	local progress = self.sequence:get()
	panel:drawFaded(0, 0, progress, self.dither)
	Graphics.setColor(Graphics.kColorClear)
	if (not self.midpointReached) then
		Graphics.fillCircleAtPoint(self.inX, self.inY, (1 - progress) * 400)
	else
		Graphics.fillCircleAtPoint(self.outX, self.outY, (1 - progress) * 400)
	end
	Graphics.setColor(Graphics.kColorBlack)
end