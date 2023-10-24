Noble.Transition = {}
class("Transition", nil, Noble).extends()

Noble.Transition.Type = {}
Noble.Transition.Type.CUT = "Cut"
Noble.Transition.Type.IN = "In"
Noble.Transition.Type.OUT = "Out"
Noble.Transition.Type.IN_OUT = "In-Out"

function Noble.Transition:init(__duration, __holdTime, __easeInFunction, __easeOutFunction)

	if (self == Noble.Transition) then error("!!") end

	self.onMidpointCalled = false
	self.onCompleteCalled = false
	self.duration = __duration or 1
	self.out = false

	self.easeInFunction = __easeInFunction or Ease.linear
	self.easeOutFunction = __easeOutFunction or Ease.linear

	if (self.type == Noble.Transition.Type.CUT) then
		self.duration = 0
		self.holdTime = 0
	else
		if __holdTime ~= nil then
			self.holdTime = __holdTime
		else
			self.holdTime = 200
		end
	end

	if (self.type == Noble.Transition.Type.OUT) then
		self.out = true
		self.screenshot = Utilities.screenshot()
	end

	local start = self.out and 1 or 0
	self.animator = Graphics.animator.new(self.duration / 2, start, 1 - start, self.easeInFunction)
end

function Noble.Transition:draw() end


-- Noble Engine built-in transitions.
import 'libraries/noble/modules/Noble.Transition/AnimatedMask.lua'
import 'libraries/noble/modules/Noble.Transition/CrossDissolve.lua'
import 'libraries/noble/modules/Noble.Transition/Cut.lua'
import 'libraries/noble/modules/Noble.Transition/Dip.lua'
import 'libraries/noble/modules/Noble.Transition/DipToBlack.lua'
import 'libraries/noble/modules/Noble.Transition/DipToWhite.lua'
import 'libraries/noble/modules/Noble.Transition/MetroNexus.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOff.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOffLeft.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOffRight.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOffUp.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOffDown.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOn.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOnLeft.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOnRight.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOnUp.lua'
import 'libraries/noble/modules/Noble.Transition/SlideOnDown.lua'
import 'libraries/noble/modules/Noble.Transition/Spotlight.lua'
import 'libraries/noble/modules/Noble.Transition/WidgetSatchel.lua'










-- class("OutTransition", nil, Noble.Transition).extends(Noble.Transition)
-- function Noble.Transition.OutTransition:init(onComplete, onMidpoint, duration, hold, easing, ...)
-- 	Noble.Transition.OutTransition.super.init(self, onComplete, nil, duration, hold, easing, ...)
-- 	if onMidpoint ~= nil then
-- 		onMidpoint(self)
-- 	end
-- end

-- local dipToBlackPanel = Graphics.image.new(400,240, Graphics.kColorBlack)
-- class("DipToBlack", nil, Noble.Transition).extends(Noble.Transition)
-- function Noble.Transition.DipToBlack:init(onComplete, onMidpoint, duration, hold, easing, dither, ...)
-- 	Noble.Transition.DipToBlack.super.init(self, onComplete, onMidpoint, duration, hold, easing, ...)
-- 	self.dither = dither or Graphics.image.kDitherTypeBayer4x4
-- end
-- function Noble.Transition.DipToBlack:draw()
-- 	dipToBlackPanel:drawFaded(0, 0, self.animator:currentValue(), self.dither)
-- end

-- local dipToWhitePanel = Graphics.image.new(400, 240, Graphics.kColorWhite)
-- class("DipToWhite", nil, Noble.Transition).extends(Noble.Transition)
-- function Noble.Transition.DipToWhite:init(onComplete, onMidpoint, duration, hold, easing, dither, ...)
-- 	Noble.Transition.DipToWhite.super.init(self, onComplete, onMidpoint, duration, hold, easing, ...)
-- 	self.dither = dither or Graphics.image.kDitherTypeBayer4x4
-- end
-- function Noble.Transition.DipToWhite:draw()
-- 	dipToWhitePanel:drawFaded(0, 0, self.animator:currentValue(), self.dither)
-- end


-- class("SlideOffLeft", nil, Noble.Transition).extends(Noble.Transition.OutTransition)
-- function Noble.Transition.SlideOffLeft:draw()
-- 	self.screenshot:draw(-400 + self.animator:currentValue() * 400, 0)
-- end

-- class("SlideOffRight", nil, Noble.Transition).extends(Noble.Transition.OutTransition)
-- function Noble.Transition.SlideOffRight:draw()
-- 	self.screenshot:draw(400 - self.animator:currentValue() * 400, 0)
-- end

-- class("SlideOffUp", nil, Noble.Transition).extends(Noble.Transition.OutTransition)
-- function Noble.Transition.SlideOffUp:draw()
-- 	self.screenshot:draw(0, -240 + self.animator:currentValue() * 240)
-- end

-- class("SlideOffDown", nil, Noble.Transition).extends(Noble.Transition.OutTransition)
-- function Noble.Transition.SlideOffDown:draw()
-- 	self.screenshot:draw(0, 240 - self.animator:currentValue() * 240)
-- end




-- --- An all-time classic.

-- --- A simple cross-fade.
-- Noble.Transition.CrossDissolve.name = "Cross dissolve"

-- --- Fade to black, then to the next scene.
-- Noble.Transition.DipToBlack.name = "Dip to black"
-- --- Fade to white, then to the next scene.
-- Noble.Transition.DipToWhite.name = "Dip to white"

-- --- An "accordion" transition, from "Widget Satchel" by Noble Robot.
-- Noble.Transition.DipWidgetSatchel.name = "Widget Satchel"
-- --- A "cascade" transition, from "Metro Nexus" by Noble Robot.
-- Noble.Transition.DipMetroNexus.name = "Metro Nexus"

-- --- The existing scene slides off the left side of the screen, revealing the next scene.
-- Noble.Transition.SlideOffLeft.name = "Slide off left"
-- --- The existing scene slides off the right side of the screen, revealing the next scene.
-- Noble.Transition.SlideOffRight.name = "Slide off right"
-- --- The existing scene slides off the top of the screen.
-- Noble.Transition.SlideOffUp.name = "Slide off up"
-- --- The existing scene slides off the bottom of the screen, revealing the next scene.
-- Noble.Transition.SlideOffDown.name = "Slide off down"