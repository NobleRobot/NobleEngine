--- An "accordion" transition, from "Widget Satchel" by Noble Robot.

class("WidgetSatchel", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.WidgetSatchel
transition.name = "Widget Satchel"

transition.type = Noble.Transition.Type.COVER
transition.sequenceCompleteValue = 2

local panels

function transition:setCustomArguments(__arguments)

	if (__arguments.easeIn or __arguments.easeIn or __arguments.ease) then
		warn("BONK: 'Noble.Transition.WidgetSatchel' does not support custom 'ease' values.")
	end

	self.easeIn = Ease.outCubit
	self.easeOut = Ease.inCubit

	if (panels == nil) then
		panels = {
			Graphics.image.new(400,48, Graphics.kColorWhite),
			Graphics.image.new(400,48, Graphics.kColorWhite),
			Graphics.image.new(400,48, Graphics.kColorWhite),
			Graphics.image.new(400,48, Graphics.kColorWhite),
			Graphics.image.new(400,48, Graphics.kColorWhite)
		}
		Graphics.lockFocus(panels[1])
			Graphics.setDitherPattern(0.4, Graphics.image.kDitherTypeScreen)
			Graphics.fillRect(0,0,400,48)
		Graphics.lockFocus(panels[2])
			Graphics.setDitherPattern(0.7, Graphics.image.kDitherTypeScreen)
			Graphics.fillRect(0,0,400,48)
		Graphics.lockFocus(panels[3])
			Graphics.setDitherPattern(0.25, Graphics.image.kDitherTypeBayer8x8)
			Graphics.fillRect(0,0,400,48)
		Graphics.lockFocus(panels[4])
			Graphics.setDitherPattern(0.5, Graphics.image.kDitherTypeDiagonalLine)
			Graphics.fillRect(0,0,400,48)
		Graphics.lockFocus(panels[5])
			Graphics.setDitherPattern(0.8, Graphics.image.kDitherTypeHorizontalLine)
			Graphics.fillRect(0,0,400,48)
		Graphics.unlockFocus()
	end

end

function transition:draw()
	local progress = self.sequence:get()
	if (not self.midpointReached) then
		panels[1]:draw(0, -48 + (progress * (48*1)) )
		panels[2]:draw(0, -48 + (progress * (48*2)) )
		panels[3]:draw(0, -48 + (progress * (48*3)) )
		panels[4]:draw(0, -48 + (progress * (48*4)) )
		panels[5]:draw(0, -48 + (progress * (48*5)) )
	else
		panels[1]:draw(0, 48*0 + (progress - 1) * 48*5)
		panels[2]:draw(0, 48*1 + (progress - 1) * 48*4)
		panels[3]:draw(0, 48*2 + (progress - 1) * 48*3)
		panels[4]:draw(0, 48*3 + (progress - 1) * 48*2)
		panels[5]:draw(0, 48*4 + (progress - 1) * 48*1)
	end
end