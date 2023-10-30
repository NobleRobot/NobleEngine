-- A wipe transition using an animated mask in the form of an imagetable.

class("ImagetableMask", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.ImagetableMask
transition.name = "Imagetable Mask"

-- Properties
transition._type = Noble.Transition.Type.MIX

-- Override default arguments
transition.ease = Ease.linear

function transition:setCustomArguments(__arguments)

	-- Arguments
	self.imagetable = __arguments.imagetable or Graphics.imagetable.new("libraries/noble/assets/images/BoltTransitionEnter")
	self.reverse = __arguments.reverse or false
	self.flipX = __arguments.flipX or false
	self.flipY = __arguments.flipY or false
	self.rotate = __arguments.rotate or false
	self.hasTransparency = __arguments.hasTransparency or true
	self.invert = __arguments.invert or false

	-- "Private" variables
	self._flipValue = Noble.Transition.Imagetable.getFlipValue(self.rotate, self.flipX, self.flipY)
	self._imagetableLength = self.imagetable and #self.imagetable or 0
	self._maskBackground = nil
	self._maskForegroundDrawMode = nil
	if (self.invert ~= true) then
		self._maskBackground = Graphics.image.new(400, 240, Graphics.kColorWhite)
		self._maskForegroundDrawMode = Graphics.kDrawModeFillBlack
	else
		self._maskBackground = Graphics.image.new(400, 240, Graphics.kColorBlack)
		self._maskForegroundDrawMode = Graphics.kDrawModeFillWhite
	end

	-- Warnings
	if (__arguments.imagetableExit ~= nil) then
		warn("BONK: You've specified an 'imagetableExit' for an Noble.Transition.ImagetableMask transition. This will have no effect. ")
	end
	if ((__arguments.ease or __arguments.easeEnter or __arguments.easeExit) ~= nil) then
		warn("BONK: You've specified an ease value for an Noble.Transition.ImagetableMask transition. This will have no effect.")
	end

end

function transition:draw()
	local progress = self.sequence:get()
	local length = self._imagetableLength
	local index = math.clamp((progress * length) // 1, 1, length)
	local mask = Graphics.image.new(400, 240)

	Graphics.pushContext(mask)
		Graphics.setImageDrawMode(Graphics.kDrawModeCopy)
		self._maskBackground:draw(0,0)
		if (self.hasTransparency) then Graphics.setImageDrawMode(self._maskForegroundDrawMode) end
		self.imagetable[index]:draw(0,0, self._flipValue)
	Graphics.popContext()

	self.oldSceneScreenshot:setMaskImage(mask)
	self.oldSceneScreenshot:draw(0,0)

end