-- A wipe transition using an animated mask in the form of an imagetable.

class("AnimatedMask", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.AnimatedMask

transition.name = "Animated Mask"
transition.type = Noble.Transition.Type.IN_OUT

function transition:init(__duration, __holdTime, __imagetable, __imagetableOut)
	transition.super.init(self, __duration, __holdTime, Ease.linear,  Ease.linear)
	self.imagetable = __imagetable
	self.imagetableOut = __imagetableOut or __imagetable

	self.imagetableLength = #self.imagetable
	self.imagetableOutLength = #self.imagetableOut

	if (self.imagetable == self.imagetableOut) then
		self.sequenceInStartValue = 0
		self.sequenceMidpointValue = 1
		self.sequenceOutStartValue = 1
		self.sequenceCompleteValue = 0
	else
		self.sequenceInStartValue = 0
		self.sequenceMidpointValue = 1
		self.sequenceOutStartValue = 0
		self.sequenceCompleteValue = 1
	end
end

function transition:draw()
	local progress = self.sequence:get()
	local imagetableLength = #self.imagetable
	local imagetable
	local length
	if not self.midpointReached then
		imagetable = self.imagetable
		length = imagetableLength
	else
		imagetable = self.imagetableOut
		length = imagetableOutLength
	end
	local index = math.clamp((progress * length) // 2, 1, length)
	imagetable[index]:draw(0, 0)
end