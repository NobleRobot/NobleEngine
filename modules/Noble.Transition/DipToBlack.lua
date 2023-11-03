--- Fade to black, then to the next scene.
-- @submodule Noble.Transition

class("DipToBlack", nil, Noble.Transition).extends(Noble.Transition.Dip)
local transition = Noble.Transition.DipToBlack
transition.name = "Dip to Black"

transition.panelImage = Graphics.image.new(400, 240, Graphics.kColorBlack)

function transition:setCustomArguments(__arguments)
	transition.super.setCustomArguments(self, __arguments)
	--self.panelImage = panel
	self.x = 0
	self.y = 0
end