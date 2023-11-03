-- A dip-style transition using one or two imagetables.
-- @submodule Noble.Transition

class("Imagetable", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.Imagetable
transition.name = "Imagetable"

-- Type
transition._type = Noble.Transition.Type.COVER

-- Overrides
transition.easeEnter = Ease.linear
transition.easeExit = Ease.linear

--- Transition properties.
-- @see Noble.transition
-- @see Noble.Transition.setDefaultProperties
transition.defaultProperties = {
	holdTime = 0,
	imagetable = nil,
	imagetableEnter = Graphics.imagetable.new("libraries/noble/assets/images/BoltTransitionEnter"),
	imagetableExit = Graphics.imagetable.new("libraries/noble/assets/images/BoltTransitionExit"),
	reverse = false,
	reverseEnter = nil,
	reverseExit = nil,
	flipX = false,
	flipY = false,
	flipXEnter = nil,
	flipYEnter = nil,
	flipXExit = nil,
	flipYExit = nil,
	rotate = false,
	rotateEnter = nil,
	rotateExit = nil,
}

function transition:setProperties(__properties)

	self.imagetable = __properties.imagetable or self.defaultProperties.imagetable
	self.imagetableEnter = __properties.imagetableEnter or self.defaultProperties.imagetableEnter or self.imagetable
	self.imagetableExit = __properties.imagetableExit or self.defaultProperties.imagetableExit or self.imagetable

	self.reverse = __properties.reverse or self.defaultProperties.reverse
	self.reverseEnter = __properties.reverseEnter or self.defaultProperties.reverseEnter or self.reverse
	self.reverseExit = __properties.reverseExit or self.defaultProperties.reverseExit or self.reverse

	self.flipX = __properties.flipX or self.defaultProperties.flipX
	self.flipY = __properties.flipY or self.defaultProperties.flipY
	self.flipXEnter = __properties.flipXEnter or self.defaultProperties.flipXEnter or self.flipX
	self.flipYEnter = __properties.flipYEnter or self.defaultProperties.flipYEnter or self.flipY
	self.flipXExit = __properties.flipXExit or self.defaultProperties.flipXExit or self.flipX
	self.flipYExit = __properties.flipYExit or self.defaultProperties.flipYExit or self.flipY

	self.rotate = __properties.rotate or self.defaultProperties.rotate
	self.rotateEnter = __properties.rotateEnter or self.defaultProperties.rotateEnter or self.rotate
	self.rotateExit = __properties.rotateExit or self.defaultProperties.rotateExit or self.rotate

	-- "Private" variables
	self._frameCountEnter = self.imagetableEnter and #self.imagetableEnter or 0
	self._frameCountExit = self.imagetableExit and #self.imagetableExit or 0

	self._flipValueEnter = Noble.Transition.Imagetable.getFlipValue(self.rotateEnter, self.flipXEnter, self.flipYEnter)
	self._flipValueExit = Noble.Transition.Imagetable.getFlipValue(self.rotateExit, self.flipXExit, self.flipYExit)

	local sequence0 = (not self.reverseEnter) and 0 or 1
	local sequence1 = (not self.reverseEnter) and 1 or 0
	local sequenceExit0 = (not self.reverseExit) and 0 or 1
	local sequenceExit1 = (not self.reverseExit) and 1 or 0

	if (self.imagetableEnter == self.imagetableExit) then
		self._sequenceStartValue = sequence0
		self._sequenceMidpointValue = sequence1
		self._sequenceResumeValue = sequence1
		self._sequenceCompleteValue = sequence0
	else
		self._sequenceStartValue = sequence0
		self._sequenceMidpointValue = sequence1
		self._sequenceResumeValue = sequenceExit0
		self._sequenceCompleteValue = sequenceExit1
	end

	-- Warnings
	if ((__properties.ease or __properties.easeEnter or __properties.easeExit) ~= nil) then
		warn("BONK: You've specified an ease value for an Noble.Transition.Imagetable transition. This will have no effect.")
	end

end

function transition:draw()
	local progress = self.sequence:get()
	local imagetable
	local frameCount
	local flipValue
	if not self.holdTimeElapsed then
		imagetable = self.imagetableEnter
		frameCount = self._frameCountEnter
		flipValue = self._flipValueEnter
	else
		imagetable = self.imagetableExit
		frameCount = self._frameCountExit
		flipValue = self._flipValueExit
	end
	local index = math.clamp((progress * frameCount) // 1, 1, frameCount)
	imagetable[index]:draw(0, 0, flipValue)
end

function Noble.Transition.Imagetable.getFlipValue(__rotate, __flipX, __flipY)
	if(__rotate or (__flipX and __flipY)) then
		return Graphics.kImageFlippedXY
	else
		if(__flipX)		then return Graphics.kImageFlippedX
		elseif(__flipY) then return Graphics.kImageFlippedY end
	end
	return Graphics.kImageUnflipped
end