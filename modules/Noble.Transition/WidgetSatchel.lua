class("WidgetSatchel", nil, Noble.Transition).extends(Noble.Transition)
local transition = Noble.Transition.WidgetSatchel

transition.name = "Widget Satchel"
transition.type = Noble.Transition.Type.IN_OUT

local widgetSatchelPanels

function transition:init(__duration,  __holdTime)
	transition.super.init(self, __duration, __holdTime, Ease.outCubic, Ease.inCubic)

	--if (widgetSatchelPanels == nil) then
		widgetSatchelPanels = {
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
	--end

end

function transition:draw()
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