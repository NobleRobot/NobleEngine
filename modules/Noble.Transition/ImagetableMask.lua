-- A wipe transition using an animated mask in the form of an imagetable.

class("ImagetableMask", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.ImagetableMask
transition.name = "Imagetable Mask"

transition.type = Noble.Transition.Type.MIX
transition.sequenceStartValue = 0
transition.sequenceCompleteValue = 1

transition.drawMode = Graphics.kDrawModeCopy
transition.ease = Ease.linear
transition.hasTransparency = true
transition.invertMask = false

function transition:setCustomArguments(__arguments)

	self.imagetable = __arguments.imagetable or Graphics.imagetable.new("libraries/noble/assets/images/BetelgeuseTransition")
	self.imagetableLength = self.imagetable and #self.imagetable or 0

	-- Warnings
	if (__arguments.imagetableOut ~= nil) then
		warn("BONK: You've specified an 'imagetableOut' for an Noble.Transition.ImagetableMask transition. This will have no effect. ")
	end
	if (self.ease ~= Ease.linear) then
		warn("BONK: You've specified an ease value other than 'Ease.linear' for an Noble.Transition.ImagetableMask transition. This will have no effect.")
	end

	self.maskBackground = nil
	self.maskForegroundDrawMode = nil
	if (self.invertMask ~= true) then
		self.maskBackground = Graphics.image.new(400, 240, Graphics.kColorWhite)
		self.maskForegroundDrawMode = Graphics.kDrawModeFillBlack
	else
		self.maskBackground = Graphics.image.new(400, 240, Graphics.kColorBlack)
		self.maskForegroundDrawMode = Graphics.kDrawModeFillWhite
	end
	if (self.hasTransparency ~= true) then
		self.maskForegroundDrawMode = Graphics.kDrawModeCopy
	end

end

function transition:draw()
	local progress = self.sequence:get()
	local length = self.imagetableLength
	local index = math.clamp((progress * length) // 1, 1, length)
	local mask = Graphics.image.new(400, 240)

	Graphics.pushContext(mask)
		Graphics.setImageDrawMode(Graphics.kDrawModeCopy)
		self.maskBackground:draw(0,0)
		if (self.hasTransparency) then Graphics.setImageDrawMode(self.maskForegroundDrawMode) end
		self.imagetable[index]:draw(0,0)
	Graphics.popContext()

	self.oldSceneScreenshot:setMaskImage(mask)
	self.oldSceneScreenshot:draw(0,0)

end