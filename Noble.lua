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
import "CoreLibs/frameTimer"
import "CoreLibs/crank"

-- We create aliases for both fun and performance reasons.
Graphics = playdate.graphics
Display = playdate.display
Geometry = playdate.geometry
Ease = playdate.easingFunctions
UI = playdate.ui
File = playdate.file
Datastore = playdate.datastore
Timer = playdate.timer
FrameTimer = playdate.frameTimer

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
import 'libraries/noble/modules/Noble.Transition.lua'
import 'libraries/noble/modules/Noble.Text.lua'
import 'libraries/noble/modules/Noble.Menu.lua'
import 'libraries/noble/modules/NobleScene.lua'
import 'libraries/noble/modules/NobleSprite.lua'

--- Check to see if the game is transitioning between scenes.
-- Useful to control game logic that lives outside of a scene's `update()` method.
-- @field bool
Noble.isTransitioning = false

--- Show/hide the Playdate SDK's FPS counter.
-- @field bool
Noble.showFPS = false;

local currentScene = nil
local engineInitialized = false

-- configuration
--

local defaultConfiguration = {
	defaultTransitionDuration = 1.5,
	defaultTransitionHoldTime = 0.25,
	defaultTransition = Noble.Transition.DipToBlack,
	enableDebugBonkChecking = false,
	alwaysRedraw = true,
}
local configuration = Utilities.copy(defaultConfiguration)

--- Engine initialization. Run this once in your main.lua file to begin your game.
-- @tparam NobleScene StartingScene This is the scene your game begins with, such as a title screen, loading screen, splash screen, etc. **NOTE: Pass the scene's class name, not an instance of the scene.**
-- @number[opt=0] __launcherTransitionDuration If you want to transition from the final frame of your launch image sequence, enter a duration in seconds here.
-- @tparam[opt=Noble.Transition.CROSS_DISSOLVE] Noble.TransitionType __launcherTransitionType If a transition duration is set, use this transition type.
-- @tparam table[optional] __configuration Provide a table of Noble Engine configuration values. This will run `Noble.setConfig` for you at launch.
-- @see NobleScene
-- @see Noble.TransitionType
-- @see setConfig
function Noble.new(StartingScene, __launcherTransition, __launcherTransitionDuration, __launcherTransitionHoldTime, __launcherTransitionArguments, __configuration)

	math.randomseed(playdate.getSecondsSinceEpoch()) -- Set a new random seed at runtime.

	if (engineInitialized) then
		error("BONK: You can only run Noble.new() once.")
		return
	end

	-- If the user supplies a config object, we use it, otherwise, we set default values.
	if (__configuration ~= nil) then
		Noble.setConfig(__configuration)
	else
		Noble.resetConfig()
	end

	-- Screen drawing: see the Playdate SDK for details on these methods.
	Graphics.sprite.setBackgroundDrawingCallback(
		function (x, y, width, height)
			if (currentScene ~= nil) then
				-- Each scene has its own method for this. We only want to run one at a time.
				currentScene:drawBackground(x, y, width, height)
			else
				Graphics.clear(Graphics.kColorBlack)
			end
		end
	)
	-- Override this Playdate method that we've used already and don't want to be used again!
	Graphics.sprite.setBackgroundDrawingCallback = function(callback)
		error("BONK: Don't call Graphics.sprite.setBackgroundDrawingCallback() directly. Put background drawing code in your scenes' drawBackground() methods instead.")
	end

	-- These values are used if not set.
	local launcherTransition =			__launcherTransition or defaultConfiguration.defaultTransition
	local launcherTransitionDuration =	__launcherTransitionDuration or 1.5
	local launcherTransitionHoldTime =	__launcherTransitionHoldTime or 0
	local launcherTransitionArguments =	__launcherTransitionArguments or {}

	-- Now that everything is set, let's-a go!
	engineInitialized = true
	Noble.transition(StartingScene, launcherTransitionDuration, launcherTransitionHoldTime, launcherTransition, launcherTransitionArguments)
end

--- This checks to see if `Noble.new` has been run. It is used internally to ward off bonks.
-- @treturn bool
-- @see Noble.Bonk
function Noble.engineInitialized()
	return engineInitialized
end

--- Miscellaneous Noble Engine configuration options / default values.
-- This table cannot be edited directly. Use `Noble.getConfig` and `Noble.setConfig`.
-- @table configuration
-- @number[opt=1] defaultTransitionDuration When running `Noble.transition` if the scene transition duration is unspecified, it will take this long in seconds.
-- @number[opt=0.2] defaultTransitionHoldTime When running `Noble.transition` (and using a hold-type transition type) if the scene transition hold duration is unspecified, it will take this long in seconds.
-- @tparam[opt=Noble.TransitionType.CROSS_DISSOLVE] Noble.TransitionType defaultTransitionType When running `Noble.transition` if the transition type is unspecified, it will use this one.
-- @bool[opt=false] enableDebugBonkChecking Noble Engine-specific errors are called "Bonks." You can set this to true during development in order to check for more of them. However, it uses resources, so you will probably want to turn it off before release.
-- @bool[opt=true] alwaysRedraw This sets the Playdate SDK method `playdate.graphics.sprite.setAlwaysRedraw`. See the Playdate SDK for details on how this function works, and the reasons you might want to set it as true or false for your project.
-- @see Noble.getConfig
-- @see Noble.setConfig
-- @see Noble.Bonk.startCheckingDebugBonks

--- Retrieve miscellaneous Noble Engine configuration options / default values
-- @return A table of all configuration values
-- @see configuration
-- @see setConfig
function Noble.getConfig()
	return configuration
end

--- Optionally customize miscellaneous Noble Engine configuration options / default values. You may run this method to change these values during runtime.
-- @tparam table __configuration This is a table with your configuration values in it.
-- @see configuration
-- @see getConfig
function Noble.setConfig(__configuration)

	if (__configuration == nil) then
		error("BONK: You cannot pass a nil value to Noble.setConfig(). If you want to reset to default values, use Noble.resetConfig().")
	end

	if (__configuration.defaultTransition ~= nil)			then configuration.defaultTransition = __configuration.defaultTransition end
	if (__configuration.defaultTransitionDuration ~= nil)	then configuration.defaultTransitionDuration = __configuration.defaultTransitionDuration end
	if (__configuration.defaultTransitionHoldTime ~= nil)	then configuration.defaultTransitionHoldTime = __configuration.defaultTransitionHoldTime end

	if (__configuration.enableDebugBonkChecking ~= nil)	then
		configuration.enableDebugBonkChecking = __configuration.enableDebugBonkChecking
		if (configuration.enableDebugBonkChecking == true) then Noble.Bonk.enableDebugBonkChecking() end
	end

	if (__configuration.alwaysRedraw ~= nil) then
		configuration.alwaysRedraw = __configuration.alwaysRedraw
		Graphics.sprite.setAlwaysRedraw(configuration.alwaysRedraw)
	end

end

--- Reset miscellaneous Noble Engine configuration values to their defaults.
-- @see getConfig
-- @see setConfig
function Noble.resetConfig()
	Noble.setConfig(Utilities.copy(defaultConfiguration))
end

-- Transition stuff
--
local transitionSequence = nil
local previousSceneScreenCapture = nil

local currentTransition = nil
local queuedScene = nil

--- Transition to a new scene (at the end of this frame).
--- This method will create a new scene, mark the previous one for garbage collection, and animate between them.
--- Additional calls to this method within the same frame (before the already-called transition begins), will override previous calls. Any calls to this method once a transition begins will be ignored until the transition completes.
-- @tparam NobleScene NewScene The scene to transition to. Pass the scene's class, not an instance of the scene. You always transition from `Noble.currentScene`
-- @number[opt=1] __duration The length of the transition, in seconds.
-- @number[opt=0.2] __holdDuration For `DIP` transitions, the time spent holding at the transition midpoint. Does not increase the total transition duration, but is taken from it. So, don't make it longer than the transition duration.
-- @tparam[opt=Noble.TransitionType.DIP_TO_BLACK] Noble.TransitionType __transitionType If a transition duration is set, use this transition type.
-- @see Noble.isTransitioning
-- @see NobleScene
-- @see Noble.TransitionType
function Noble.transition(NewScene, __duration, __holdTime, __transitionType, __transitionArguments)
	if (Noble.isTransitioning) then
		-- This bonk no longer throws an error (compared to previous versions of Noble Engine), but maybe it still should?
		warn("BONK: You can't start a transition in the middle of another transition, silly!")
		return -- Let's get otta here!
	elseif (queuedScene ~= nil) then
		-- Calling this method multiple times between Noble.update() calls is probably not intentional behavior.
		warn("Soft-BONK: You are calling Noble.transition() multiple times within the same frame. Did you mean to do that?")
		-- We don't return here because maybe the developer *did* intend to override a previous call to Noble.transition().
	end

	queuedScene = NewScene()	-- Creates new scene object. Its init() function runs now.
	currentTransition = (__transitionType or configuration.defaultTransition)(
		__duration or configuration.defaultTransitionDuration,
		__holdTime or configuration.defaultTransitionHoldTime,
		__transitionArguments or {}
	)
end

local function executeTransition()
	Noble.isTransitioning = true

	Noble.Input.setHandler(nil)						-- Disable user input. (This happens after self:ext() so exit() can query input)

	if (currentScene ~= nil) then
		currentScene:exit()							-- The current scene runs its "goodbye" code. Sprites are taken out of the simulation.
	end

	local onMidpoint = function()
		currentTransition.midpointReached = true
		if (currentScene ~= nil) then
			currentScene:finish()
			currentScene = nil							-- Allows current scene to be garbage collected.
		end
		currentScene = queuedScene						-- New scene's update loop begins.
		queuedScene = nil								-- Reset!
		if (currentTransition.onMidpoint ~= nil) then
			currentTransition:onMidpoint()				-- If this transition has any custom code to run here, run it.
		end
		currentScene:enter()							-- The new scene runs its "hello" code.
	end

	local onHoldTimeElapsed = function()
		currentTransition.holdTimeElapsed = true
		if (currentTransition.onHoldTimeElapsed ~= nil) then
			currentTransition:onHoldTimeElapsed()
		end
	end

	local onComplete = function()
		Noble.isTransitioning = false		-- Reset
		if (currentTransition.onComplete ~= nil) then
			currentTransition:onComplete()	-- If this transition has any custom code to run here, run it.
		end
		currentScene:start()				-- The new scene is now active.
		currentTransition = nil				-- Clear the transition variable.
	end

	local type = currentTransition.type
	local duration = currentTransition.duration
	local durationIn = currentTransition.durationIn
	local durationOut = currentTransition.durationOut
	local holdTime = currentTransition.holdTime
	local startValue = currentTransition._sequenceStartValue
	local midpointValue = currentTransition._sequenceMidpointValue
	local resumeValue = currentTransition._sequenceResumeValue
	local completeValue = currentTransition._sequenceCompleteValue

	if (type == Noble.Transition.Type.CUT) then
		onMidpoint()
		onComplete()
	elseif (type == Noble.Transition.Type.COVER) then
		currentTransition.sequence = Sequence.new()
			:from(startValue)
			:to(midpointValue, durationIn-(holdTime/2), currentTransition.easeIn)
			:callback(onMidpoint)
			:sleep(holdTime)
			:callback(onHoldTimeElapsed)
			:to(resumeValue, 0)
			:to(completeValue, durationOut-(holdTime/2), currentTransition.easeOut)
			:callback(onComplete)
			:start()
	elseif (type == Noble.Transition.Type.MIX) then
		onMidpoint()
		onHoldTimeElapsed()
		currentTransition.sequence = Sequence.new()
			:from(startValue)
			:to(completeValue, duration, currentTransition.ease)
			:callback(onComplete)
			:start()
	end

end

local transitionCanvas = Graphics.image.new(400, 240)

local function transitionUpdate()
	transitionCanvas:clear(Graphics.kColorClear)

	Graphics.pushContext(transitionCanvas)
	currentTransition:draw()
	Graphics.popContext()

	Graphics.setImageDrawMode(currentTransition.drawMode)
	transitionCanvas:drawIgnoringOffset(0, 0)
	Graphics.setImageDrawMode(Graphics.kDrawModeCopy)
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

	-- Here we check to see if a transition currently in progress needs screenshots of the new scene.
	-- If so, we route drawing for this frame into a new context.
	if (Noble.isTransitioning and currentTransition.captureScreenshotsDuringTransition) then
		currentTransition.newSceneScreenshot = Graphics.image.new(400, 240)
		Graphics.pushContext(currentTransition.newSceneScreenshot)
	end

	Graphics.sprite.update()			-- Let's draw our sprites (and backgrounds).

	if (currentScene ~= nil) then
		currentScene:update()			-- Scene-specific update code.
	end

	if (Noble.isTransitioning) then
		if (currentTransition.captureScreenshotsDuringTransition) then
			Graphics.popContext()
		end
		transitionUpdate()
	end

	-- We want to draw the crank indicator and FPS display last
	crankIndicatorActive, crankIndicatorForced = Noble.Input.getCrankIndicatorStatus()
	if (crankIndicatorActive) then
		if (playdate.isCrankDocked() or crankIndicatorForced) then
			UI.crankIndicator:update()	-- Draw crank indicator (if requested).
		end
	end
	if (Noble.showFPS) then
		playdate.drawFPS(4, 4)
	end

	Timer.updateTimers()		-- Finally, update all SDK timers.
	FrameTimer.updateTimers() 	-- Update all frame timers

	if (Noble.Bonk.checkingDebugBonks()) then	-- Checks for code that breaks the engine.
		Noble.Bonk.checkDebugBonks()
	end

	-- Once this frame is complete, we can check to see if it's time to start transitioning to a new scene.
	if (not Noble.isTransitioning and currentTransition ~= nil) then
		executeTransition()
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
