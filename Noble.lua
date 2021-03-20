--- Noble Engine
-- @module Noble
-- @author Mark LaCroix

--
-- Noble Engine: A li'l game engine for Playdate.
--
-- by Mark LaCroix
-- https://noblerobot.com/
--

-- Playdate libraries
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/animation"
import "CoreLibs/animator"
import "CoreLibs/object"
import "CoreLibs/ui"
import "CoreLibs/math"
import "CoreLibs/timer"
import "CoreLibs/crank"

-- We create aliases for both fun and performance reasons.
Graphics = playdate.graphics
Display = playdate.display
Geometry = playdate.geometry
Ease = playdate.easingFunctions
UI = playdate.ui
File = playdate.file
Datastore = playdate.datastore

-- In lua, varibles are global by default, but having a "Global" object to put
-- varibles into is useful for maintaining sanity if you're coming from an OOP language.
Global = {}

Noble = {}
Noble.currentScene = nil
Noble.isTransitioning = false
Noble.showFPS = false;

-- Third-party libraries
import 'libraries/noble/libraries/Signal'
import 'libraries/noble/libraries/Sequence'

-- Noble libraries
import 'libraries/noble/utilities/Utilities'
import 'libraries/noble/NobleScene'

-- Noble modules and classes
import 'libraries/noble/Menu'
import 'libraries/noble/Noble.Settings'
import 'libraries/noble/Noble.Input'


function playdate.crankDocked()
	if (Noble.Input.currentHandler.crankDocked ~= nil) then
		Noble.Input.currentHandler.crankDocked()
	end
end
function playdate.crankUndocked()
	if (Noble.Input.currentHandler.crankUndocked ~= nil) then
		Noble.Input.currentHandler.crankDocked()
	end
end

local updateCrankIndicator = false

------
-- Enable/disable on-screen crank indicator.
-- @param __bool Set true to start showing the on-screen crank indicator. Set false to stop showing it.
function Noble.showCrankIndicator(__bool)
	if (__bool) then
		UI.crankIndicator:start()
	end
	updateCrankIndicator = __bool
end







-- Fonts/Text
--
Noble.Text = {}
Noble.Text.system = Graphics.getSystemFont()
Noble.Text.small = Graphics.font.new("libraries/noble/assets/fonts/NobleSans")
Noble.Text.medium = Graphics.font.new("libraries/noble/assets/fonts/NobleSlab")
Noble.Text.large = Graphics.font.new("libraries/noble/assets/fonts/SatchelRoughed")
local currentFont = Noble.Text.system

Noble.Text.ALIGN_LEFT = kTextAlignment.left
Noble.Text.ALIGN_RIGHT = kTextAlignment.right
Noble.Text.ALIGN_CENTER = kTextAlignment.center

function Noble.Text.getCurrentFont() return currentFont end
function Noble.Text.setFont(__font, __variant)
	currentFont = __font
	local variant = __variant or Graphics.font.kVariantNormal
	Graphics.setFont(__font, variant)
end

function Noble.Text.draw(__string, __x, __y, __alignment, __localized, __font)
	if (__alignment == nil) then __alignment = kTextAlignment.left end
	if (__localized == nil) then __localized = false end
	if (__font ~= nil) then Graphics.setFont(__font) end -- Temporary font
	if (__localized) then
		Graphics.drawLocalizedTextAligned(__string, __x, __y, __alignment)
	else
		Graphics.drawTextAligned(__string, __x, __y, __alignment)
	end
	if (__font ~= nil) then Graphics.setFont(currentFont) end	-- Reset
end



-- Engine initialization
--
local engineInitialized = false

-- StartingScene:NobleScene 						| This is the scene your game begins with, usually a title screen or main menu.
-- transitionDuration:number 						| If you want to transition from the final frame of your launch image sequence, enter a duration in seconds here.
-- transitionType = Noble.Transition.CROSS_DISSOLVE | See Noble.Transition for included transition types.
-- checkForExtraBonks:bool = false 					| Noble Engine-specific errors are called "bonks." Set this to true during development to check for more of them. It is resource intensive, so turn it off for release
-- Game initialization, run this once in your main.lua file.
function Noble.new(StartingScene, __transitionDuration, __transitionType, __checkForExtraBonks)
	if (engineInitialized) then
		error("BONK: You can only run Noble.new() once.")
		return
	else
		engineInitialized = true
	end

	-- Noble Engine refers to an engine-specific error as a "bonk."
	local checkForExtraBonks = __checkForExtraBonks or false
	if (checkForExtraBonks) then Noble.Bonks.startChecking() end

	-- Screen drawing: see the Playdate SDK for details on these methods.
	Graphics.sprite.setAlwaysRedraw(true)
	Graphics.sprite.setBackgroundDrawingCallback(
		function ()
			if (Noble.currentScene ~= nil) then
				 -- Each scene has its own method for this. We only want to run one at a time.
				Noble.currentScene:drawBackground()
			end
		end
	)
	-- Override Playdate methods we've used already, and don't want to be used again, with Bonks!
	Graphics.sprite.setBackgroundDrawingCallback = function(callback)
		error("BONK: Don't call Graphics.sprite.setBackgroundDrawingCallback() directly. Put background drawing code in your scenes' drawBackground() methods instead.")
	end

	local transitionType = Noble.TransitionType.CUT
	if (__transitionDuration ~= nil) then
		transitionType = __transitionType or Noble.TransitionType.CROSS_DISSOLVE
	end

	-- Now that everything is set, let's-a go!
	Noble.transition(StartingScene, __transitionDuration, transitionType)
end



-- Scene Management
--
local transitionSequence = nil
local previousSceneScreenCapture = nil

Noble.TransitionType = {}
Noble.TransitionType.CUT = "Cut"
Noble.TransitionType.DIP = "Dip"
Noble.TransitionType.DIP_TO_BLACK = Noble.TransitionType.DIP .. " to black"
Noble.TransitionType.DIP_TO_WHITE = Noble.TransitionType.DIP .. " to white"
Noble.TransitionType.DIP_CUSTOM = Noble.TransitionType.DIP .. ": Custom"
Noble.TransitionType.DIP_WIDGET_SATCHEL = Noble.TransitionType.DIP .. ": Widget Satchel"
Noble.TransitionType.DIP_METRO_NEXUS = Noble.TransitionType.DIP .. ": Metro Nexus"
Noble.TransitionType.CROSS_DISSOLVE = "Cross dissolve"
Noble.TransitionType.SLIDE_OFF = "Slide off"
Noble.TransitionType.SLIDE_OFF_LEFT = Noble.TransitionType.SLIDE_OFF .. ": left"
Noble.TransitionType.SLIDE_OFF_RIGHT = Noble.TransitionType.SLIDE_OFF .. ": right"
Noble.TransitionType.SLIDE_OFF_UP = Noble.TransitionType.SLIDE_OFF .. ": up"
Noble.TransitionType.SLIDE_OFF_DOWN = Noble.TransitionType.SLIDE_OFF .. ": down"

local currentTransitionType = nil

local dipToBlackPanel = Graphics.image.new(400,240, Graphics.kColorBlack)
local dipToWhitePanel = Graphics.image.new(400,240, Graphics.kColorWhite)

local metroNexusPanels = {
	Graphics.image.new(80,240, Graphics.kColorWhite),
	Graphics.image.new(80,240, Graphics.kColorWhite),
	Graphics.image.new(80,240, Graphics.kColorWhite),
	Graphics.image.new(80,240, Graphics.kColorWhite),
	Graphics.image.new(80,240, Graphics.kColorWhite)
}

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

-- NewScene:NobleScene 									| The scene to transition to. You always transition from Noble.currentScene
-- duration:number = 1 									| Duration of the transition, in seconds.
-- transitionType = Noble.TransitionType.DIP_TO_BLACK 	| See Noble.Transition for included transition types.
-- holdDuration:number = 0.2							| The time spent holding at the transition midpoint. Does not increase the transition duration.
-- Game initialization, run this once in your main.lua file.
function Noble.transition(NewScene, __duration, __transitionType, __holdDuration)
	if (Noble.isTransitioning) then
		print("BONK ALERT: You can't start a transition in the middle of another transition, silly!")
		return
	end

	local newScene = NewScene()			-- Creates new scene object. Its init() function runs.

	Noble.isTransitioning = true

	if (Noble.currentScene ~= nil) then
		Noble.currentScene:exit()		-- The current scene runs its "goodbye" code.
	end

	Noble.Input.setHandler(nil)			-- Disable user input. (This happens after self:ext() so exit() can query input)

	local duration = __duration or 1
	local holdDuration = __holdDuration or 0.2
	currentTransitionType = __transitionType

	local onMidpoint = function()
		Noble.currentScene = nil		-- Allows current scene to be garbage collected.

		Noble.currentScene = newScene	-- New scene's update loop begins.
		newScene:enter()				-- The new scene runs its "hello" code.
	end
	local onComplete = function()
		previousSceneScreenCapture = nil-- Reset (if neccessary).
		Noble.isTransitioning = false	-- Reset
		newScene:start()				-- The new scene is now active.
	end

	if (Utilities.startsWith(currentTransitionType, Noble.TransitionType.DIP)) then
		transitionSequence = Sequence.new()
			:from(0)
			:to(1, (duration-holdDuration)/2, Ease.linear)
			:callback(onMidpoint)
			:sleep(holdDuration)
			:to(2, (duration-holdDuration)/2, Ease.linear)
			:callback(onComplete)
	else
		previousSceneScreenCapture = Utilities.screenshot()
		onMidpoint()
		transitionSequence = Sequence.new()
			:from(0)
			:to(1, duration, Ease.linear)
			:callback(onComplete)
	end
	transitionSequence:start()
end

local function transitionUpdate()
	local progress = transitionSequence:get()

	-- Transition type: Dip to black
	if (currentTransitionType == Noble.TransitionType.DIP_TO_BLACK) then
		if (progress < 1) then
			dipToBlackPanel:drawFaded(0, 0, Ease.outQuad(progress, 0, 1, 1), Graphics.image.kDitherTypeBayer4x4)
		elseif (progress < 2) then
			dipToBlackPanel:drawFaded(0, 0, 1 - Ease.inQuad(progress - 1, 0, 1, 1), Graphics.image.kDitherTypeBayer4x4)
		end

	-- Transition type: Dip to white
	elseif (currentTransitionType == Noble.TransitionType.DIP_TO_WHITE) then
		if (progress < 1) then
			dipToWhitePanel:drawFaded(0, 0, Ease.outQuad(progress, 0, 1, 1), Graphics.image.kDitherTypeBayer8x8)
		elseif (progress < 2) then
			dipToWhitePanel:drawFaded(0, 0, 1 - Ease.inQuad(progress - 1, 0, 1, 1), Graphics.image.kDitherTypeBayer8x8)
		end

	-- Transition type: Cross dissolve (aka: crossfade)
	elseif (currentTransitionType == Noble.TransitionType.CROSS_DISSOLVE) then
		-- if previousSceneScreenCapture == nil then
		-- 	previousSceneScreenCapture = Utilities.screenshot()
		-- end
		if (progress < 1) then
			previousSceneScreenCapture:drawFaded(0, 0, 1 - Ease.inOutQuart(progress, 0, 1, 1), Graphics.image.kDitherTypeBayer4x4)
		-- else
		-- 	previousSceneScreenCapture = nil -- Reset
		end

	-- -- Transition type: Custom Fade
	-- elseif (Noble.Transition.type == Noble.Transition.DIP_CUSTOM) then
	-- 	if (progress < 1) then
	-- 		Graphics.setPattern(Pattern.fade[math.floor(progress*#Pattern.fade) + 1])
	-- 	elseif (progress < 2) then
	-- 		Graphics.setPattern(Pattern.fade[#Pattern.fade * 2 - (math.floor(progress * #Pattern.fade))])
	-- 	end
	-- 	Graphics.fillRect(0, 0, 400, 240)

	-- Transition type: Widget Satchel (horizontal "color" panels)
	elseif (currentTransitionType == Noble.TransitionType.DIP_WIDGET_SATCHEL) then
		if (progress < 1) then
			widgetSatchelPanels[1]:draw(0, -48 + Ease.outCubic(progress, 0, 1, 1) * 48*1 )
			widgetSatchelPanels[2]:draw(0, -48 + Ease.outCubic(progress, 0, 1, 1) * 48*2 )
			widgetSatchelPanels[3]:draw(0, -48 + Ease.outCubic(progress, 0, 1, 1) * 48*3 )
			widgetSatchelPanels[4]:draw(0, -48 + Ease.outCubic(progress, 0, 1, 1) * 48*4 )
			widgetSatchelPanels[5]:draw(0, -48 + Ease.outCubic(progress, 0, 1, 1) * 48*5 )
		elseif (progress < 2) then
			widgetSatchelPanels[1]:draw(0, 48*0 + Ease.inCubic(progress - 1, 0, 1, 1) * 48*5)
			widgetSatchelPanels[2]:draw(0, 48*1 + Ease.inCubic(progress - 1, 0, 1, 1) * 48*4)
			widgetSatchelPanels[3]:draw(0, 48*2 + Ease.inCubic(progress - 1, 0, 1, 1) * 48*3)
			widgetSatchelPanels[4]:draw(0, 48*3 + Ease.inCubic(progress - 1, 0, 1, 1) * 48*2)
			widgetSatchelPanels[5]:draw(0, 48*4 + Ease.inCubic(progress - 1, 0, 1, 1) * 48*1)
		end

	-- Transition type: Metro Nexus (vertical white panels)
	elseif (currentTransitionType == Noble.TransitionType.DIP_METRO_NEXUS) then
		if (progress < 1) then
			metroNexusPanels[1]:draw(000, (-1 + Ease.outQuint(progress, 0, 1, 1)) * 240 )
			metroNexusPanels[2]:draw(080, (-1 + Ease.outQuart(progress, 0, 1, 1)) * 240 )
			metroNexusPanels[3]:draw(160, (-1 + Ease.outQuart(progress, 0, 1, 1)) * 240 )
			metroNexusPanels[4]:draw(240, (-1 + Ease.outCubic(progress, 0, 1, 1)) * 240 )
			metroNexusPanels[5]:draw(320, (-1 + Ease.outSine (progress, 0, 1, 1)) * 240 )
		elseif (progress < 2) then
			metroNexusPanels[1]:draw(000, (1 - Ease.inQuint(progress - 1, 0, 1, 1)) * -240 + 240)
			metroNexusPanels[2]:draw(080, (1 - Ease.inQuart(progress - 1, 0, 1, 1)) * -240 + 240)
			metroNexusPanels[3]:draw(160, (1 - Ease.inQuart(progress - 1, 0, 1, 1)) * -240 + 240)
			metroNexusPanels[4]:draw(240, (1 - Ease.inCubic(progress - 1, 0, 1, 1)) * -240 + 240)
			metroNexusPanels[5]:draw(320, (1 - Ease.inSine (progress - 1, 0, 1, 1)) * -240 + 240)
		end

	-- Transition type: Slide
	elseif (currentTransitionType == Noble.TransitionType.SLIDE_OFF_LEFT) then
		if (progress < 1) then
			previousSceneScreenCapture:draw(Ease.inQuart(progress, 0, 1, 1) * -400, 0)
		end
	elseif (currentTransitionType == Noble.TransitionType.SLIDE_OFF_RIGHT) then
		if (progress < 1) then
			previousSceneScreenCapture:draw(Ease.inQuart(progress, 0, 1, 1) * 400, 0)
		end
	elseif (currentTransitionType == Noble.TransitionType.SLIDE_OFF_UP) then
		if (progress < 1) then
			previousSceneScreenCapture:draw(0, Ease.inQuart(progress, 0, 1, 1) * -240)
		end
	elseif (currentTransitionType == Noble.TransitionType.SLIDE_OFF_DOWN) then
		if (progress < 1) then
			previousSceneScreenCapture:draw(0, Ease.inQuart(progress, 0, 1, 1) * 240, 0)
		end

	end
end



-- Bonk
-- Noble Engine overrides/supercedes some Playdate SDK behavior. A "bonk" is what happens when your game breaks the engine.
-- You can check for bonks with "checkForBonks"
--
Noble.Bonks = {}
local bonksAreSetup = false
local checkingForBonks = false
local function setupBonks()
	Noble.Bonks.crankDocked = playdate.crankDocked
	Noble.Bonks.crankUndocked = playdate.crankUndocked
	Noble.Bonks.update = playdate.update
	Noble.Bonks.pause = playdate.gameWillPause
	Noble.Bonks.resume = playdate.gameWillResume
	bonksAreSetup = true
end
function Noble.startCheckingForBonks()
	if (bonksAreSetup == false) then
		setupBonks()
	end
	checkingForBonks = true
end
function Noble.stopCheckingForBonks()
	Noble.Bonks = {}
	checkingForBonks = false
	bonksAreSetup = false
end
local function bonkUpdate()
	if (Graphics.sprite.getAlwaysRedraw() == false) then
		error("BONK: Don't use Graphics.sprite.setAlwaysRedraw(false) unless you know what you're doing...")
	end
	if (playdate.crankDocked ~= Noble.Bonks.crankDocked) then
		error("BONK: Don't manaully define playdate.crankDocked(). Create a crankDocked() inside of an inputHandler instead.")
	end
	if (playdate.crankUndocked ~= Noble.Bonks.crankUndocked) then
		error("BONK: Don't manaully define playdate.crankUndocked(). Create a crankUndocked() inside of an inputHandler instead.")
	end
	if (playdate.update ~= Noble.Bonks.update) then
		error("BONK: Don't manaully define playdate.update(). Put update code in your scenes' update() methods instead.")
	end
	if (playdate.gameWillPause ~= Noble.Bonks.pause) then
		error("BONK: Don't manaully define playdate.gameWillPause(). Put pause code in your scenes' pause() methods instead.")
	end
	if (playdate.gameWillResume ~= Noble.Bonks.resume) then
		error("BONK: Don't manaully define playdate.gameWillResume(). Put resume code in your scenes' resume() methods instead.")
	end
	if (Noble.Input.currentHandler == nil) then
		error("BONK: Don't set Noble.Input.currentHandler to nil directly. To disable input, use Noble.Input.setHandler() (without an arguement) instead.")
	end
	if (Noble.currentScene.baseColor == Graphics.kColorClear) then
		error("BONK: Don't set a scene's baseColor to Graphics.kColorClear, silly.")
	end
end



-- Game loop
--
function playdate.update()
	Noble.Input.update()							-- Check for Noble Engine-specific input methods.

	Sequence.update()						-- Update all animations that use the Sequence library.

	Graphics.sprite.update()				-- Let's draw our sprites (and backgrounds).

	if (Noble.currentScene ~= nil) then
		Noble.currentScene:update()			-- Scene-specific update code.
	end

	if (Noble.isTransitioning) then
		transitionUpdate()					-- Update transition animations (if active).
	end

	if (updateCrankIndicator and playdate.isCrankDocked()) then
		UI.crankIndicator:update()			-- Draw crank indicator (if requested).
	end

	playdate.timer.updateTimers()			-- Finally, update all SDK timers.

	if (Noble.showFPS) then
		playdate.drawFPS(4, 4)
	end
	if (checkingForBonks) then				-- Checks for code that breaks the engine.
		bonkUpdate()
	end

end
function playdate.gameWillPause()
	if (Noble.currentScene ~= nil) then
		Noble.currentScene:gameWillPause()
	end
end
function playdate.gameWillResume()
	if (Noble.currentScene ~= nil) then
		Noble.currentScene:gameWillResume()
	end
end