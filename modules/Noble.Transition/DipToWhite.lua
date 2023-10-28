--- Fade to white, then to the next scene.

class("DipToWhite", nil, Noble.Transition).extends(Noble.Transition.Dip)
local transition = Noble.Transition.DipToWhite

transition.name = "Dip to White"

local panel = Graphics.image.new(400, 240, Graphics.kColorWhite)

function transition:setCustomArguments(__arguments)
	transition.super.setCustomArguments(self, __arguments)
	self.panelImage = panel
end