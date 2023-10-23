local dipToBlackPanel = Graphics.image.new(400,240, Graphics.kColorBlack)
local dipToWhitePanel = Graphics.image.new(400,240, Graphics.kColorWhite)

local metroNexusPanels = {
	Graphics.image.new(80,240, Graphics.kColorWhite),
	Graphics.image.new(80,240, Graphics.kColorWhite),
	Graphics.image.new(80,240, Graphics.kColorWhite),
	Graphics.image.new(80,240, Graphics.kColorWhite),
	Graphics.image.new(80,240, Graphics.kColorWhite)
}

local widgetSatchelPanels = {
	Graphics.image.new(400,48, Graphics.kColorWhite),
	Graphics.image.new(400,48, Graphics.kColorWhite),
	Graphics.image.new(400,48, Graphics.kColorWhite),
	Graphics.image.new(400,48, Graphics.kColorWhite),
	Graphics.image.new(400,48, Graphics.kColorWhite)
}
Graphics.lockFocus(widgetSatchelPanels[1])
Graphics.setDitherPattern(0.4, Graphics.image.kDitherTypeScreen)
Graphics.fillRect(0,0,400,48)
Graphics.lockFocus(widgetSatchelPanels[2])
Graphics.setDitherPattern(0.7, Graphics.image.kDitherTypeScreen)
Graphics.fillRect(0,0,400,48)
Graphics.lockFocus(widgetSatchelPanels[3])
Graphics.setDitherPattern(0.25, Graphics.image.kDitherTypeBayer8x8)
Graphics.fillRect(0,0,400,48)
Graphics.lockFocus(widgetSatchelPanels[4])
Graphics.setDitherPattern(0.5, Graphics.image.kDitherTypeDiagonalLine)
Graphics.fillRect(0,0,400,48)
Graphics.lockFocus(widgetSatchelPanels[5])
Graphics.setDitherPattern(0.8, Graphics.image.kDitherTypeHorizontalLine)
Graphics.fillRect(0,0,400,48)
Graphics.unlockFocus()

--- Constants
-- @section constants

Noble.Transition = {}

class("BaseTransition", nil, Noble.Transition).extends()
function Noble.Transition.BaseTransition:init(onComplete, onMidpoint, duration, hold, easing, ...)
	self.onMidpoint = onMidpoint
	self.onMidpointCalled = false
	self.onComplete = onComplete
	self.onCompleteCalled = false
	self.duration = duration or 1
	self.out = onMidpoint == nil
	if hold ~= nil then
		self.hold = hold
	else
		self.hold = 200
	end
	self.easing = easing or Ease.inOutSine
	local start = self.out and 1 or 0
	self.animator = Graphics.animator.new(self.duration / 2, start, 1 - start, self.easing)
	self.screenshot = Utilities.screenshot()
end
function Noble.Transition.BaseTransition:update()
	if self.animator:ended() and not self.onCompleteCalled then
		if self.onMidpoint ~= nil and not self.onMidpointCalled then
			if self.hold_timer == nil then
				self.hold_timer = Timer.new(self.hold, function()
					self.out = true
					self:onMidpoint()
					self.onMidpointCalled = true
					self.animator = Graphics.animator.new(self.duration / 2, 1, 0, self.easing)
				end)
			end
		else
			self:onComplete()
			self.onCompleteCalled = true
		end
	end
	self:draw()
end
function Noble.Transition.BaseTransition:draw() end

class("OutTransition", nil, Noble.Transition).extends(Noble.Transition.BaseTransition)
function Noble.Transition.OutTransition:init(onComplete, onMidpoint, duration, hold, easing, ...)
	Noble.Transition.OutTransition.super.init(self, onComplete, nil, duration, hold, easing, ...)
	if onMidpoint ~= nil then
		onMidpoint(self)
	end
end

class("Cut", nil, Noble.Transition).extends(Noble.Transition.BaseTransition)
function Noble.Transition.Cut:init(onComplete, onMidpoint)
	if onMidpoint ~= nil then
		onMidpoint(self)
	end
	if onComplete ~= nil then
		onComplete(self)
	end
end

local dipToBlackPanel = Graphics.image.new(400,240, Graphics.kColorBlack)
class("DipToBlack", nil, Noble.Transition).extends(Noble.Transition.BaseTransition)
function Noble.Transition.DipToBlack:init(onComplete, onMidpoint, duration, hold, easing, dither, ...)
	Noble.Transition.DipToBlack.super.init(self, onComplete, onMidpoint, duration, hold, easing, ...)
	self.dither = dither or Graphics.image.kDitherTypeBayer4x4
end
function Noble.Transition.DipToBlack:draw()
	dipToBlackPanel:drawFaded(0, 0, self.animator:currentValue(), self.dither)
end

local dipToWhitePanel = Graphics.image.new(400, 240, Graphics.kColorWhite)
class("DipToWhite", nil, Noble.Transition).extends(Noble.Transition.BaseTransition)
function Noble.Transition.DipToWhite:init(onComplete, onMidpoint, duration, hold, easing, dither, ...)
	Noble.Transition.DipToWhite.super.init(self, onComplete, onMidpoint, duration, hold, easing, ...)
	self.dither = dither or Graphics.image.kDitherTypeBayer4x4
end
function Noble.Transition.DipToWhite:draw()
	dipToWhitePanel:drawFaded(0, 0, self.animator:currentValue(), self.dither)
end

class("CrossDissolve", nil, Noble.Transition).extends(Noble.Transition.OutTransition)
function Noble.Transition.CrossDissolve:init(onComplete, onMidpoint, duration, hold, easing, dither, ...)
	Noble.Transition.CrossDissolve.super.init(self, onComplete, onMidpoint, duration, hold, easing, ...)
	self.dither = dither or Graphics.image.kDitherTypeBayer4x4
end
function Noble.Transition.CrossDissolve:draw()
	self.screenshot:drawFaded(0, 0, self.animator:currentValue(), self.dither)
end

class("SlideOffLeft", nil, Noble.Transition).extends(Noble.Transition.OutTransition)
function Noble.Transition.SlideOffLeft:draw()
	self.screenshot:draw(-400 + self.animator:currentValue() * 400, 0)
end

class("SlideOffRight", nil, Noble.Transition).extends(Noble.Transition.OutTransition)
function Noble.Transition.SlideOffRight:draw()
	self.screenshot:draw(400 - self.animator:currentValue() * 400, 0)
end

class("SlideOffUp", nil, Noble.Transition).extends(Noble.Transition.OutTransition)
function Noble.Transition.SlideOffUp:draw()
	self.screenshot:draw(0, -240 + self.animator:currentValue() * 240)
end

class("SlideOffDown", nil, Noble.Transition).extends(Noble.Transition.OutTransition)
function Noble.Transition.SlideOffDown:draw()
	self.screenshot:draw(0, 240 - self.animator:currentValue() * 240)
end

class("DipWidgetSatchel", nil, Noble.Transition).extends(Noble.Transition.BaseTransition)
function Noble.Transition.DipWidgetSatchel:draw()
	local progress = self.animator:currentValue()
	if not self.out then
		widgetSatchelPanels[1]:draw(0, -48 + progress * 48*1 )
		widgetSatchelPanels[2]:draw(0, -48 + progress * 48*2 )
		widgetSatchelPanels[3]:draw(0, -48 + progress * 48*3 )
		widgetSatchelPanels[4]:draw(0, -48 + progress * 48*4 )
		widgetSatchelPanels[5]:draw(0, -48 + progress * 48*5 )
	else
		widgetSatchelPanels[1]:draw(0, 48*0 + (1 - progress) * 48*5)
		widgetSatchelPanels[2]:draw(0, 48*1 + (1 - progress) * 48*4)
		widgetSatchelPanels[3]:draw(0, 48*2 + (1 - progress) * 48*3)
		widgetSatchelPanels[4]:draw(0, 48*3 + (1 - progress) * 48*2)
		widgetSatchelPanels[5]:draw(0, 48*4 + (1 - progress) * 48*1)
	end
end

class("DipMetroNexus", nil, Noble.Transition).extends(Noble.Transition.BaseTransition)
function Noble.Transition.DipMetroNexus:draw()
	local progress = self.animator:currentValue()

	if not self.out then
		metroNexusPanels[1]:draw(000, (-1 + math.clamp(progress * 1, 0, 1)) * 240 )
		metroNexusPanels[2]:draw(080, (-1 + math.clamp(progress * 1.5, 0, 1)) * 240 )
		metroNexusPanels[3]:draw(160, (-1 + math.clamp(progress * 2, 0, 1)) * 240 )
		metroNexusPanels[4]:draw(240, (-1 + math.clamp(progress * 2.5, 0, 1)) * 240 )
		metroNexusPanels[5]:draw(320, (-1 + math.clamp(progress * 3, 0, 1)) * 240 )
	else
		metroNexusPanels[1]:draw(000, math.clamp(progress * 1, 0, 1) * -240 + 240)
		metroNexusPanels[2]:draw(080, math.clamp(progress * 1.5, 0, 1) * -240 + 240)
		metroNexusPanels[3]:draw(160, math.clamp(progress * 2, 0, 1) * -240 + 240)
		metroNexusPanels[4]:draw(240, math.clamp(progress * 2.5, 0, 1) * -240 + 240)
		metroNexusPanels[5]:draw(320, math.clamp(progress * 3, 0, 1) * -240 + 240)
	end
end

class("Animation", nil, Noble.Transition).extends(Noble.Transition.BaseTransition)
function Noble.Transition.Animation:init(onComplete, onMidpoint, duration, hold, easing, it)
	Noble.Transition.Animation.super.init(self, onComplete, onMidpoint, duration, hold, easing)
	self.it = it
end
function Noble.Transition.Animation:draw()
	local progress = self.animator:currentValue()
	local it_len = #self.it
	local index = 1
	if not self.out then
		index = math.clamp((progress * it_len) // 2, 1, it_len)
	else
		index = math.clamp((progress * it_len) // 2, 1, it_len)
	end
	self.it[index]:draw(0, 0)
end

class("Spotlight", nil, Noble.Transition).extends(Noble.Transition.BaseTransition)
function Noble.Transition.Spotlight:init(onComplete, onMidpoint, duration, hold, easing, x1, y1, x2, y2)
	Noble.Transition.Animation.super.init(self, onComplete, onMidpoint, duration, hold, easing)
	self.x1, self.y1 = x1, y1
	self.x2, self.y2 = x2 or x1, y2 or y1
end
function Noble.Transition.Spotlight:draw()
	dipToBlackPanel:drawFaded(0, 0, self.animator:currentValue(), Graphics.image.kDitherTypeBayer4x4)
	Graphics.setColor(Graphics.kColorClear)
	if not self.out then
		Graphics.fillCircleAtPoint(self.x1, self.y1, (1 - self.animator:currentValue()) * 400)
	else
		Graphics.fillCircleAtPoint(self.x2, self.y2, (1 - self.animator:currentValue()) * 400)
	end
end

--- An all-time classic.
Noble.Transition.Cut.name = "Cut"
--- A simple cross-fade.
Noble.Transition.CrossDissolve.name = "Cross dissolve"

--- Fade to black, then to the next scene.
Noble.Transition.DipToBlack.name = "Dip to black"
--- Fade to white, then to the next scene.
Noble.Transition.DipToWhite.name = "Dip to white"

--- An "accordion" transition, from "Widget Satchel" by Noble Robot.
Noble.Transition.DipWidgetSatchel.name = "Widget Satchel"
--- A "cascade" transition, from "Metro Nexus" by Noble Robot.
Noble.Transition.DipMetroNexus.name = "Metro Nexus"

--- The existing scene slides off the left side of the screen, revealing the next scene.
Noble.Transition.SlideOffLeft.name = "Slide off left"
--- The existing scene slides off the right side of the screen, revealing the next scene.
Noble.Transition.SlideOffRight.name = "Slide off right"
--- The existing scene slides off the top of the screen.
Noble.Transition.SlideOffUp.name = "Slide off up"
--- The existing scene slides off the bottom of the screen, revealing the next scene.
Noble.Transition.SlideOffDown.name = "Slide off down"