-- A wipe transition using an animated mask in the form of an imagetable.

class("Imagetable", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.Imagetable
transition.name = "Imagetable"

transition.type = Noble.Transition.Type.COVER
transition.drawMode = Graphics.kDrawModeCopy

function transition:setCustomArguments(__arguments)

	self.imagetable = __arguments.imagetable or Graphics.imagetable.new("libraries/noble/assets/images/BoltTransition")
	self.imagetableOut = __arguments.imagetableOut or Graphics.imagetable.new("libraries/noble/assets/images/BoltTransition2")

	self.imagetableLength = self.imagetable and #self.imagetable or 0
	self.imagetableOutLength = self.imagetableOut and #self.imagetableOut or 0

	self.color = __arguments.color or Graphics.kColorBlack
	self.invertMask = __arguments.invertMask or false

	if (self.imagetable == self.imagetableOut) then
		self.sequenceStartValue = 0
		self.sequenceMidpointValue = 1
		self.sequenceResumeValue = 1
		self.sequenceCompleteValue = 0
	else
		self.sequenceStartValue = 0
		self.sequenceMidpointValue = 1
		self.sequenceResumeValue = 0
		self.sequenceCompleteValue = 1
	end
end

function transition:draw()
	local progress = self.sequence:get()
	local imagetable
	local length
	if not self.holdTimeElapsed then
		imagetable = self.imagetable
		length = self.imagetableLength
	else
		imagetable = self.imagetableOut
		length = self.imagetableOutLength
	end
	local index = math.clamp((progress * length) // 1, 1, length)
	imagetable[index]:draw(0, 0)
end