Noble.Transition = {}
class("Transition", nil, Noble).extends()

Noble.Transition.Type = {}
Noble.Transition.Type.CUT = "Cut"
Noble.Transition.Type.IN_OUT = "In-Out"
Noble.Transition.Type.IN = "In"
Noble.Transition.Type.OUT = "Out"

function Noble.Transition:init(__duration, __holdTime, __easeInFunction, __easeOutFunction)

	self.sequence = nil
	self.sequenceInStartValue = 0
	self.sequenceMidpointValue = 1
	self.sequenceOutStartValue = 1
	self.sequenceCompleteValue = 0

	self.onMidpoint = nil
	self.onHoldTimeElapsed = nil
	self.onComplete = nil

	self.midpointReached = false
	self.holdTimeElapsed = false

	self.duration = __duration or Noble.getConfig().defaultTransitionDuration
	self.holdTime = __holdTime or Noble.getConfig().defaultTransitionHoldTime

	self.easeInFunction = __easeInFunction or Ease.linear
	self.easeOutFunction = __easeOutFunction or Ease.linear

	if (self.type == Noble.Transition.Type.OUT) then
		self.screenshot = Utilities.screenshot()
	end

end

function Noble.Transition:draw() end


-- Noble Engine built-in transitions.
import 'libraries/noble/modules/Noble.Transition/Cut.lua'
--
import 'libraries/noble/modules/Noble.Transition/CrossDissolve.lua'
import 'libraries/noble/modules/Noble.Transition/AnimatedMask.lua'
--
import 'libraries/noble/modules/Noble.Transition/Dip.lua'
import 'libraries/noble/modules/Noble.Transition/DipToBlack.lua'
import 'libraries/noble/modules/Noble.Transition/DipToWhite.lua'
--
import 'libraries/noble/modules/Noble.Transition/SlideOff.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOffLeft.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOffRight.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOffUp.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOffDown.lua'
--
import 'libraries/noble/modules/Noble.Transition/SlideOn.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOnLeft.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOnRight.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOnUp.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOnDown.lua'
import 'libraries/noble/modules/Noble.Transition/Spotlight.lua'
--
import 'libraries/noble/modules/Noble.Transition/MetroNexus.lua'
import 'libraries/noble/modules/Noble.Transition/WidgetSatchel.lua'