--- A li'l game engine for Playdate.
-- @module Noble

--
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
import "CoreLibs/frameTimer"

-- We create aliases for both fun and performance reasons.
Graphics = playdate.graphics
Display = playdate.display
Geometry = playdate.geometry
Ease = playdate.easingFunctions
UI = playdate.ui
File = playdate.file
Datastore = playdate.datastore

-- In lua, variables are global by default, but having a "Global" object to put
-- variables into is useful for maintaining sanity if you're coming from an OOP language.
-- It's included here for basically no reason at all. Noble Engine doesn't use it. (◔◡◔)
Global = {}

-- It all fits inside this table, oooo!
Noble = {}

-- Third-party libraries
import 'libraries/noble/libraries/Signal'
import 'libraries/noble/libraries/Sequence'

-- Noble libraries, modules, and classes.
import 'libraries/noble/utilities/Utilities'
import 'libraries/noble/modules/Noble.Animation.lua'
import 'libraries/noble/modules/Noble.Bonk.lua'
import 'libraries/noble/modules/Noble.GameData.lua'
import 'libraries/noble/modules/Noble.Input.lua'
import 'libraries/noble/modules/Noble.Settings.lua'
import 'libraries/noble/modules/Noble.Text.lua'
import 'libraries/noble/modules/Noble.TransitionType.lua'
import 'libraries/noble/modules/Noble.Menu.lua'
import 'libraries/noble/modules/NobleScene'
import 'libraries/noble/modules/NobleSprite'

--- Check to see if the game is transitioning between scenes.
-- Useful to control game logic that lives outside of a scene's `update()` method.
-- @field bool
Noble.isTransitioning = false

--- Show/hide the Playdate SDK's FPS counter.
-- @field bool
Noble.showFPS = false;

local currentScene = nil
local engineInitialized = false

--- Engine initialization. Run this once in your main.lua file to begin your game.
-- @tparam NobleScene StartingScene This is the scene your game begins with, such as a title screen, loading screen, splash screen, etc. Pass the scene's class, not an instance of the scene.
-- @number[opt] __transitionDuration If you want to transition from the final frame of your launch image sequence, enter a duration in seconds here.
-- @tparam[opt=Noble.Transition.CROSS_DISSOLVE] Noble.TransitionType __transitionType If a transition duration is set, use this transition type.
-- @bool[opt=false] __enableDebugBonkChecking Noble Engine-specific errors are called "bonks." Set this to true during development to check for more of them. It is resource intensive, so turn it off for release.
-- @see NobleScene
-- @see Noble.TransitionType
-- @see Noble.Bonk.startCheckingDebugBonks
function Noble.new(StartingScene, __transitionDuration, __transitionType, __enableDebugBonkChecking)

	if (engineInitialized) then
		error("BONK: You can only run Noble.new() once.")
		return
	else
		-- Noble Engine refers to an engine-specific error as a "bonk." We check this before engineInitialized is set to true because we need it to be false.
		local enableDebugBonkChecking = __enableDebugBonkChecking or false
		if (enableDebugBonkChecking) then Noble.Bonk.enableDebugBonkChecking() end

		engineInitialized = true
	end

	-- Screen drawing: see the Playdate SDK for details on these methods.
	Graphics.sprite.setAlwaysRedraw(true)
	Graphics.sprite.setBackgroundDrawingCallback(
		function ()
			if (currentScene ~= nil) then
				 -- Each scene has its own method for this. We only want to run one at a time.
				currentScene:drawBackground()
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

--- This checks to see if `Noble.new` has been run. It is used internally to ward off bonks.
-- @treturn bool
-- @see Noble.Bonk
function Noble.engineInitialized()
	return engineInitialized
end


-- Transition stuff
--
local transitionSequence = nil
local previousSceneScreenCapture = nil

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

--- Transition to a new scene. This method will create a new scene, mark the previous one for garbage collection, and animate between them.
-- @tparam NobleScene NewScene The scene to transition to. Pass the scene's class, not an instance of the scene. You always transition from `Noble.currentScene`
-- @number[opt=1] __duration The length of the transition, in seconds.
-- @tparam[opt=Noble.TransitionType.DIP_TO_BLACK] Noble.TransitionType __transitionType If a transition duration is set, use this transition type.
-- @number[opt=0.2] __holdDuration For `DIP` transitions, the time spent holding at the transition midpoint. Does not increase the total transition duration, but is taken from it. So, don't make it longer than the transition duration.
-- @see NobleScene
-- @see Noble.TransitionType
function Noble.transition(NewScene, __duration, __transitionType, __holdDuration)
	if (Noble.isTransitioning) then
		error("BONK: You can't start a transition in the middle of another transition, silly!")
	end

	Noble.Input.setHandler(nil)			-- Disable user input. (This happens after self:ext() so exit() can query input)
	Noble.isTransitioning = true

	if (currentScene ~= nil) then
		currentScene:exit()				-- The current scene runs its "goodbye" code. Sprites are taken out of the simulation.
	end

	local newScene = NewScene()			-- Creates new scene object. Its init() function runs.

	local duration = __duration or 1
	local holdDuration = __holdDuration or 0.2
	currentTransitionType = __transitionType or Noble.TransitionType.DIP_TO_BLACK

	local onMidpoint = function()
		if (currentScene ~= nil) then
			currentScene:finish()
			currentScene = nil			-- Allows current scene to be garbage collected.
		end
		currentScene = newScene			-- New scene's update loop begins.
		newScene:enter()				-- The new scene runs its "hello" code.
	end

	local onComplete = function()
		previousSceneScreenCapture = nil-- Reset (if necessary).
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

local transitionCanvas = Graphics.image.new(400,240, Graphics.kColorClear)

local function transitionUpdate()
	local progress = transitionSequence:get()

	transitionCanvas:clear(Graphics.kColorClear)
	Graphics.lockFocus(transitionCanvas)

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

	Graphics.unlockFocus()
	transitionCanvas:drawIgnoringOffset(0,0)

end

--- Get the current scene object
-- @treturn NobleScene
function Noble.currentScene()
	return currentScene
end

--- Get the name of the current scene
-- @treturn string
function Noble.currentSceneName()
	return currentScene.name
end

local crankIndicatorActive = false
local crankIndicatorForced = false

-- Game loop
--
function playdate.update()
	Noble.Input.update()				-- Check for Noble Engine-specific input methods.

	Sequence.update()					-- Update all animations that use the Sequence library.

	Graphics.sprite.update()			-- Let's draw our sprites (and backgrounds).

	if (currentScene ~= nil) then
		currentScene:update()			-- Scene-specific update code.
	end

	if (Noble.isTransitioning) then
		transitionUpdate()				-- Update transition animations (if active).
	end

	crankIndicatorActive, crankIndicatorForced = Noble.Input.getCrankIndicatorStatus()
	if (crankIndicatorActive) then
		if (playdate.isCrankDocked() or crankIndicatorForced) then
			UI.crankIndicator:update()	-- Draw crank indicator (if requested).
		end
	end

	playdate.timer.updateTimers()		-- Finally, update all SDK timers.

	if (Noble.showFPS) then
		playdate.drawFPS(4, 4)
	end

	if (Noble.Bonk.checkingDebugBonks()) then	-- Checks for code that breaks the engine.
		Noble.Bonk.checkDebugBonks()
	end

end

function playdate.gameWillPause()
	if (currentScene ~= nil) then
		currentScene:pause()
	end
end

function playdate.gameWillResume()
	if (currentScene ~= nil) then
		currentScene:resume()
	end
end