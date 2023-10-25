--- Fade to black, then to the next scene.

Noble.Transition.DipToBlack = {}
class("DipToBlack", nil, Noble.Transition).extends(Noble.Transition.Dip)
local transition = Noble.Transition.DipToBlack

transition.name = "Dip to Black"

local panel

function transition:init(__duration,  __holdTime, __easeInFunction, __easeOutFunction, __dither, __x, __y)
	if (panel == nil) then panel = Graphics.image.new(400,240, Graphics.kColorBlack) end
	transition.super.init(self, __duration, __holdTime, panel, __easeInFunction, __easeOutFunction, __dither, __x, __y)

	self.onComplete = function()
		print("hello!")
	end
end