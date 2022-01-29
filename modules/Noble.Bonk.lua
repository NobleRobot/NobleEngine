--- Engine-specific error handling.
-- Noble Engine overrides/supersedes some Playdate SDK behavior. A "bonk" is what happens when your game breaks the engine.
--
-- Most bonks will throw during normal operation, but others ("debug bonks") introduce some execution overhead so are not
-- checked by default.
--
-- @module Noble.Bonk
--
Noble.Bonk = {}

local bonksAreSetup = false

local checkingForBonks = false

local debugBonks = {}

-- You cannot run this directly. Run Noble.new() with __enableDebugBonkChecking as true to enable debug bonk checking.
function Noble.Bonk.enableDebugBonkChecking()
	if (bonksAreSetup == false) then
		if (Noble.engineInitialized() == false) then
			debugBonks.update = playdate.update
			debugBonks.pause = playdate.gameWillPause
			debugBonks.resume = playdate.gameWillResume
			debugBonks.crankDocked = playdate.crankDocked
			debugBonks.crankUndocked = playdate.crankUndocked
			bonksAreSetup = true
		else
			error("BONK-BONK: You cannot run this directly. Run Noble.new() with __enableDebugBonkChecking as true.")
		end
	else
		print("BONK-BONK: You have already run Noble.new() with __enableDebugBonkChecking as true, you cannot run this directly.")
	end
end


--- Begin checking for debug bonks, <strong>on every frame</strong>. This introduces needless overhead, so don't do it in a release build.
-- You can only run this if you ran previously `Noble.new()` with `__enableDebugBonkChecking` as true, which you should also not do in a release build.
	-- @see Noble.new
function Noble.Bonk.startCheckingDebugBonks()
	if (checkingForBonks == false) then
		if (bonksAreSetup) then
			checkingForBonks = true
		else
			error("BONK-BONK: You cannot run this unless debug bonk checking is enabled.")
		end
	end
end

--- Stop checking for debug bonks on every frame.
--
-- <strong>NOTE: You can only run this if debug bonk checking is enabled.</strong>
function Noble.Bonk.stopCheckingDebugBonks()
	if (checkingForBonks) then
		if (bonksAreSetup) then
			checkingForBonks = false
		else
			error("BONK-BONK: You cannot run this unless debug bonk checking is enabled.")
		end
	end
end

--- Disable the ability to check for debug bonks. It frees up some memory. Once you disable debug bonk checking, you cannot re-enable it.
--
-- <strong>NOTE: You can only run this if debug bonk checking is enabled.</strong>
function Noble.Bonk.disableDebugBonkChecking()
	if (bonksAreSetup) then
		debugBonks = {}
		bonksAreSetup = false
	else
		error("BONK-BONK: You cannot run this unless debug bonk checking is enabled.")
	end
end

--- Are we debug bonk checking for debug bonks?
-- @treturn bool
function Noble.Bonk.checkingDebugBonks()
	return checkingForBonks
end

--- Manually check for debug bonks.
-- This method runs every frame when `checkingDebugBonks` is true, but you may call it manually instead.
--
-- <strong>NOTE: You can only run this if debug bonk checking is enabled.</strong>
function Noble.Bonk.checkDebugBonks()

	if (playdate.crankDocked ~= debugBonks.crankDocked) then
		error("BONK: Don't manually define playdate.crankDocked(). Create a crankDocked() inside of an inputHandler instead.")
	end
	if (playdate.crankUndocked ~= debugBonks.crankUndocked) then
		error("BONK: Don't manually define playdate.crankUndocked(). Create a crankUndocked() inside of an inputHandler instead.")
	end
	if (playdate.update ~= debugBonks.update) then
		error("BONK: Don't manually define playdate.update(). Put update code in your scenes' update() methods instead.")
	end
	if (playdate.gameWillPause ~= debugBonks.pause) then
		error("BONK: Don't manually define playdate.gameWillPause(). Put pause code in your scenes' pause() methods instead.")
	end
	if (playdate.gameWillResume ~= debugBonks.resume) then
		error("BONK: Don't manually define playdate.gameWillResume(). Put resume code in your scenes' resume() methods instead.")
	end
	if (Graphics.sprite.getAlwaysRedraw() == false) then
		error("BONK: Don't use Graphics.sprite.setAlwaysRedraw(false) unless you know what you're doing...")
	end
	if (Noble.currentScene.backgroundColor == Graphics.kColorClear) then
		error("BONK: Don't set a scene's backgroundColor to Graphics.kColorClear, silly.")
	end

end