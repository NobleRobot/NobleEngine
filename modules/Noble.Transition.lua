local pd <const> = playdate
local gfx <const> = pd.graphics

local metroNexusPanels <const> = {
	Graphics.image.new(80,240, Graphics.kColorWhite),
	Graphics.image.new(80,240, Graphics.kColorWhite),
	Graphics.image.new(80,240, Graphics.kColorWhite),
	Graphics.image.new(80,240, Graphics.kColorWhite),
	Graphics.image.new(80,240, Graphics.kColorWhite)
}
local widgetSatchelPanels <const> = {
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

local swipe = Graphics.imagetable.new("assets/images/swipe")
---
-- A set of constants for scene transition animations.
-- @module Noble.TransitionType
-- @see Noble.transition

--- Constants
-- @section constants

Noble.Transition = {}

class("BaseTransition", nil, Noble.Transition).extends()
function Noble.Transition.BaseTransition:init(fin, mid, duration, hold, easing, ...)
    self.mid = mid
    self.mid_called = false
    self.fin = fin
    self.fin_called = false
    self.duration = duration or 1
    self.out = mid == nil
    if hold ~= nil then
        self.hold = hold
    else
        self.hold = 200
    end
    self.easing = easing or pd.easingFunctions.inOutSine
    local start = self.out and 1 or 0
    self.animator = gfx.animator.new(self.duration / 2, start, 1 - start, self.easing)
    self.screenshot = Utilities.screenshot()
end
function Noble.Transition.BaseTransition:update()
    if self.animator:ended() and not self.fin_called then
        if self.mid ~= nil and not self.mid_called then
            if self.hold_timer == nil then
                self.hold_timer = pd.timer.new(self.hold, function()
                    self.out = true
                    self:mid()
                    self.mid_called = true
                    self.animator = gfx.animator.new(self.duration / 2, 1, 0, self.easing)
                end)
            end
        else
            self:fin()
            self.fin_called = true
        end
    end
    self:draw()
end
function Noble.Transition.BaseTransition:draw() end

class("Cut", nil, Noble.Transition).extends(Noble.Transition.BaseTransition)
function Noble.Transition.Cut:init(fin, mid)
    if mid ~= nil then
        mid(self)
    end
    if fin ~= nil then
        fin(self)
    end
end

local dipToBlackPanel = Graphics.image.new(400,240, Graphics.kColorBlack)
class("DipToBlack", nil, Noble.Transition).extends(Noble.Transition.BaseTransition)
function Noble.Transition.DipToBlack:draw()
    dipToBlackPanel:drawFaded(0, 0, self.animator:currentValue(), Graphics.image.kDitherTypeBayer4x4)
end

local dipToWhitePanel = Graphics.image.new(400, 240, Graphics.kColorWhite)
class("DipToWhite", nil, Noble.Transition).extends(Noble.Transition.BaseTransition)
function Noble.Transition.DipToWhite:draw()
    dipToWhitePanel:drawFaded(0, 0, self.animator:currentValue(), Graphics.image.kDitherTypeBayer4x4)
end

class("CrossDissolve", nil, Noble.Transition).extends(Noble.Transition.BaseTransition)
function Noble.Transition.CrossDissolve:init(fin, mid, duration, hold, easing)
    Noble.Transition.CrossDissolve.super.init(self, fin, nil, duration, hold, easing)
    if mid ~= nil then
        mid(self)
    end
end
function Noble.Transition.CrossDissolve:draw()
    self.screenshot:drawFaded(0, 0, self.animator:currentValue(), Graphics.image.kDitherTypeBayer4x4)
end

class("SlideOffLeft", nil, Noble.Transition).extends(Noble.Transition.BaseTransition)
function Noble.Transition.SlideOffLeft:init(fin, mid, duration, hold, easing)
    Noble.Transition.SlideOffLeft.super.init(self, fin, nil, duration, hold, easing)
    if mid ~= nil then
        mid(self)
    end
end
function Noble.Transition.SlideOffLeft:draw()
    self.screenshot:draw(-400 + self.animator:currentValue() * 400, 0)
end

class("SlideOffRight", nil, Noble.Transition).extends(Noble.Transition.BaseTransition)
function Noble.Transition.SlideOffRight:init(fin, mid, duration, hold, easing)
    Noble.Transition.SlideOffRight.super.init(self, fin, nil, duration, hold, easing)
    if mid ~= nil then
        mid(self)
    end
end
function Noble.Transition.SlideOffRight:draw()
    self.screenshot:draw(400 - self.animator:currentValue() * 400, 0)
end

class("SlideOffUp", nil, Noble.Transition).extends(Noble.Transition.BaseTransition)
function Noble.Transition.SlideOffUp:init(fin, mid, duration, hold, easing)
    Noble.Transition.SlideOffUp.super.init(self, fin, nil, duration, hold, easing)
    if mid ~= nil then
        mid(self)
    end
end
function Noble.Transition.SlideOffUp:draw()
    self.screenshot:draw(0, -240 + self.animator:currentValue() * 240)
end

class("SlideOffDown", nil, Noble.Transition).extends(Noble.Transition.BaseTransition)
function Noble.Transition.SlideOffDown:init(fin, mid, duration, hold, easing)
    Noble.Transition.SlideOffDown.super.init(self, fin, nil, duration, hold, easing)
    if mid ~= nil then
        mid(self)
    end
end
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
function Noble.Transition.Animation:init(fin, mid, duration, hold, easing, it)
    Noble.Transition.Animation.super.init(self, fin, mid, duration, hold, easing, it)
    self.it = it or swipe
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

Noble.TransitionType = Noble.Transition
--- An all-time classic.
Noble.TransitionType.CUT = "Cut"
Noble.TransitionType.CUT = Noble.Transition.Cut
--- A simple cross-fade.
Noble.TransitionType.CROSS_DISSOLVE = "Cross dissolve"
Noble.TransitionType.CROSS_DISSOLVE = Noble.Transition.CrossDissolve

--- Fade to black, then to the next scene.
Noble.TransitionType.DIP_TO_BLACK = Noble.Transition.DipToBlack
--- Fade to white, then to the next scene.
Noble.TransitionType.DIP_TO_WHITE = Noble.Transition.DipToWhite

-- Noble.TransitionType.DIP_CUSTOM = Noble.TransitionType.DIP .. ": Custom"
--- An "accordion" transition, from "Widget Satchel" by Noble Robot.
Noble.TransitionType.DIP_WIDGET_SATCHEL = Noble.Transition.DipWidgetSatchel
--- A "cascade" transition, from "Metro Nexus" by Noble Robot.
-- Noble.TransitionType.DIP_METRO_NEXUS = Noble.TransitionType.DIP .. ": Metro Nexus"
Noble.TransitionType.DIP_METRO_NEXUS = Noble.Transition.DipMetroNexus

--- The existing scene slides off the left side of the screen, revealing the next scene.
Noble.TransitionType.SLIDE_OFF_LEFT = Noble.Transition.SlideOffLeft
--- The existing scene slides off the right side of the screen, revealing the next scene.
Noble.TransitionType.SLIDE_OFF_RIGHT = Noble.Transition.SlideOffRight
--- The existing scene slides off the top of the screen.
Noble.TransitionType.SLIDE_OFF_UP = Noble.Transition.SlideOffUp
--- The existing scene slides off the bottom of the screen, revealing the next scene.
Noble.TransitionType.SLIDE_OFF_DOWN = Noble.Transition.SlideOffDown
