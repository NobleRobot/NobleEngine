--- Fade to white, then to the next scene.

class("DipToWhite", nil, Noble.Transition).extends(Noble.Transition.Dip)
local transition = Noble.Transition.DipToWhite

transition.name = "Dip to White"

local panel

function transition:init(__duration,  __holdTime, __easeInFunction, __easeOutFunction, __dither, __x, __y)
	if (panel == nil) then panel = Graphics.image.new(400,240, Graphics.kColorWhite) end
	transition.super.init(self, __duration, __holdTime, panel, __easeInFunction, __easeOutFunction, __dither, __x, __y)
end