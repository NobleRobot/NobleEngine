local pd <const> = playdate
local gfx <const> = pd.graphics

---
-- A set of constants for scene transition animations.
-- @module Noble.TransitionType
-- @see Noble.transition

--- Constants
-- @section constants

Noble.Transition = {}

class("BaseTransition", nil, Noble.Transition).extends()
function Noble.Transition.BaseTransition:init(fin, mid, duration, hold, easing)
    self.mid = mid
    self.mid_called = false
    self.fin = fin
    self.fin_called = false
    self.duration = duration or 1
    if hold ~= nil then
        self.hold = hold
    else
        self.hold = 200
    end
    self.easing = easing or pd.easingFunctions.linear
    self.animator = gfx.animator.new(self.duration, 0, 1, self.easing)
    self.screenshot = Utilities.screenshot()
end
function Noble.Transition.BaseTransition:update()
    if self.animator:ended() and not self.fin_called then
        if self.mid ~= nil and not self.mid_called then
            if self.hold_timer == nil then
                self.hold_timer = pd.timer.new(self.hold, function()
                    self:draw()
                    self:mid()
                    self.mid_called = true
                    self.animator = gfx.animator.new(self.duration, 1, 0, self.easing)
                end)
            end
        else
            self:fin()
            self.fin_called = true
        end
        self:draw()
    else
        self:draw()
    end
end
function Noble.Transition.BaseTransition:draw() end

class("Cut", nil, Noble.Transition).extends(Noble.Transition.BaseTransition)
function Noble.Transition.Cut:init(fin, mid)
    if mid ~= nil then
        mid()
    end
    if fin ~= nil then
        fin()
    end
end

local dipToBlackPanel = Graphics.image.new(400,240, Graphics.kColorBlack)
class("DipToBlack", nil, Noble.Transition).extends(Noble.Transition.BaseTransition)
function Noble.Transition.DipToBlack:draw()
    print(self.animator:currentValue())
    dipToBlackPanel:drawFaded(0, 0, self.animator:currentValue(), Graphics.image.kDitherTypeBayer4x4)
end

local dipToWhitePanel = Graphics.image.new(400, 240, Graphics.kColorWhite)
class("DipToWhite", nil, Noble.Transition).extends(Noble.Transition.BaseTransition)
function Noble.Transition.DipToWhite:draw()
    dipToWhitePanel:drawFaded(0, 0, self.animator:currentValue(), Graphics.image.kDitherTypeBayer4x4)
end

class("CrossDissolve", nil, Noble.Transition).extends(Noble.Transition.BaseTransition)
function Noble.Transition.CrossDissolve:draw()
    self.screenshot:drawFaded(0, 0, self.animator:currentValue(), Graphics.image.kDitherTypeBayer4x4)
end

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

class("DipWidgetSatchel", nil, Noble.Transition).extends(Noble.Transition.BaseTransition)
function Noble.Transition.DipWidgetSatchel:draw()
    local progress = self.animator:currentValue()
    widgetSatchelPanels[1]:draw(0, -48 + progress * 48*1 )
    widgetSatchelPanels[2]:draw(0, -48 + progress * 48*2 )
    widgetSatchelPanels[3]:draw(0, -48 + progress * 48*3 )
    widgetSatchelPanels[4]:draw(0, -48 + progress * 48*4 )
    widgetSatchelPanels[5]:draw(0, -48 + progress * 48*5 )
end

Noble.TransitionType = Noble.Transition
--- An all-time classic.
Noble.TransitionType.CUT = "Cut"
Noble.TransitionType.CUT = Noble.Transition.Cut
--- A simple cross-fade.
Noble.TransitionType.CROSS_DISSOLVE = "Cross dissolve"
Noble.TransitionType.CROSS_DISSOLVE = Noble.Transition.CrossDissolve

Noble.TransitionType.DIP = "Dip"
--- Fade to black, then to the next scene.
Noble.TransitionType.DIP_TO_BLACK = Noble.TransitionType.DIP .. " to black"
Noble.TransitionType.DIP_TO_BLACK = Noble.Transition.DipToBlack
--- Fade to white, then to the next scene.
Noble.TransitionType.DIP_TO_WHITE = Noble.TransitionType.DIP .. " to white"

Noble.TransitionType.DIP_CUSTOM = Noble.TransitionType.DIP .. ": Custom"
--- An "accordion" transition, from "Widget Satchel" by Noble Robot.
Noble.TransitionType.DIP_WIDGET_SATCHEL = Noble.TransitionType.DIP .. ": Widget Satchel"
--- A "cascade" transition, from "Metro Nexus" by Noble Robot.
Noble.TransitionType.DIP_METRO_NEXUS = Noble.TransitionType.DIP .. ": Metro Nexus"

Noble.TransitionType.SLIDE_OFF = "Slide off"
--- The existing scene slides off the left side of the screen, revealing the next scene.
Noble.TransitionType.SLIDE_OFF_LEFT = Noble.TransitionType.SLIDE_OFF .. ": left"
--- The existing scene slides off the right side of the screen, revealing the next scene.
Noble.TransitionType.SLIDE_OFF_RIGHT = Noble.TransitionType.SLIDE_OFF .. ": right"
--- The existing scene slides off the top of the screen.
Noble.TransitionType.SLIDE_OFF_UP = Noble.TransitionType.SLIDE_OFF .. ": up"
--- The existing scene slides off the bottom of the screen, revealing the next scene.
Noble.TransitionType.SLIDE_OFF_DOWN = Noble.TransitionType.SLIDE_OFF .. ": down"
