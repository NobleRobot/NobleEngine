---
-- A set of constants for scene transition animations.
-- @module Noble.TransitionType
-- @see Noble.transition

--- Constants
-- @section constants

Noble.TransitionType = {}

--- An all-time classic.
Noble.TransitionType.CUT = "Cut"
--- A simple cross-fade.
Noble.TransitionType.CROSS_DISSOLVE = "Cross dissolve"

Noble.TransitionType.DIP = "Dip"
--- Fade to black, then to the next scene.
Noble.TransitionType.DIP_TO_BLACK = Noble.TransitionType.DIP .. " to black"
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