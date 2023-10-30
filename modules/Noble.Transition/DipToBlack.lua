--- Fade to black, then to the next scene.

class("DipToBlack", nil, Noble.Transition).extends(Noble.Transition.Dip)
local transition = Noble.Transition.DipToBlack
transition.name = "Dip to Black"

local panel = Graphics.image.new(400, 240, Graphics.kColorBlack)

function transition:setCustomArguments(__arguments)
	transition.super.setCustomArguments(self, __arguments)
	self.panelImage = panel
end