local colorTable = {
    ["white"] = 0xFFFFFF,
    ["gray"] = 0x808080,
    ["black"] = 0x000000,

    ["green"] = 0x008000,
    ["lime"] = 0x00FF00,
    ["yellow"] = 0xFFFF00,
    ["orange"] = 0xFFA500,
    ["red"] = 0xFF0000,
    ["purple"] = 0x800080,
    ["blue"] = 0x0000FF,
    ["brown"] = 0x8B4513,
    ["pink"] = 0xFFC0CB,
    ["magenta"] = 0xFF00FF,
    ["cyan"] = 0x00FFFF
}

function getColor(color)
    local value = colorTable[stringTrim(color:lower())]
    if value ~= nil then return value end
    return 0xFFFFFFFF
end
--[[

-----------------[CREDITS]-----------------
Snowen/sn0wenx: half-Save data functionality (It was very broken, I(ZSolarDev) had to spend so long fixing it :<)

ZSolarDev/zsolar1: "min:sec" to millisecond converter(and vise versa), custom checkpoint sprite,
health tweening, script customization(wrote all of this, took over a day :/), checkpoint functionality,
checkpoint hit effect customization

BlueColorsin: getColor function

I(ZSolarDev) appreciate all of the help that I got to work on this. Thank you Snowen and BlueColorsin, I appreciate it. :D



--------------[WHATS PLANNED]--------------
(When I or Me is said in this section, its reffering to ZSolarDev.)
Me and Snowen plan to make it so that the timebar resets every time you reach a checkpoint. I want to change it a bit though, because some
people will obvoiusly still want the og timebar. I think we could have a bar next to the timebar that fills up slowly until a checkpoint is reached, and
will say how much time is left till the next checkpoint is reached. It will be fill all the way up be the time a checkpoint is reached, and then reset
until the next checkpoint. Maybe we could make this bar customizable.

Please send Suggestions where this script is posted!



-------------[IF YOU NEED HELP]-------------
Please contact ZSolarDev(zsolar1) at the page where this script is posted. The pages this script is posted will contain some sort of methed
to talk to ZSolarDev(such as comments or talking in the discussion post in the Psych Ward.)



--------------[CUSTOMIZATION]--------------
----[IF YOU DO NOT WANT AN IMAGE TO APPEAR WHEN A CHECKPOINT IS HIT(OR YOU WANT SOMETHING CUSTOM CODED,) GO TO LINE 65]----
]]--
checkpointImgPath = '' -- where is the image for the checkpoint text on screen located?
checkpointSoundPath = '' -- where is the sound for the checkpoint located?
--[[

--[(Context)]--
there is an image andthat shows up on screen that says "Checkpoint!" or "Checkpoint Reached!" or
whatever is in your image. you can set the image path for what shows up on screen once you reach
a checkpoint. (the way I had worded it before didnt make sense.) a sound will also play

--[(Important when writing the paths)]--
dont add the following: "images/", "sounds/", ".png", ".ogg", "mods/".
]]--
colorCheckpointImg = false -- do you want the checkpoint image to have a custom color?
checkpointImgColor = getColor('') -- If so, whats the color of the checkpoint image? (You can type the color name of the hex code.)
--[[

--[(Description of getColor)]--
You type the name of your color. you see the names of the colors at the top of this lua script.
those are the colors the function supports. if the function doesnt support your color or you 
leave the function blank, it will just return white. If you want to use a hex code instead, you can
just replace the whole "getColor('color goes here')" with the hex code of your choice.

]]--
checkpointImgScreenTime = 1.5 -- How many seconds does it take for the checkpoint image to go on and off the screen?
----[CUSTOM CHECKPOINT HIT EFFECT]----
customCheckpointHitEffect = false -- Do you not want an image to show up once a checkpoint is reached?
--[[

--[(Description of customCheckpointHitEffect)]--
there is a function called checkpointHitEffect right below the examples. This function is called when a checkpoint
is hit and you don't want the default effect to happen. You will need to know how to script in lua if you want to make
your own. I decided to also pass in the checkpoint number that just got hit on the calling of this function.

--[(Examples of customCheckpointHitEffect)]--
function checkpointHitEffect(checkpointNumber)
    triggerEvent("Add Camera Zoom", 0.25, 0.25)
    if flashingLights then
        cameraFlash('game', 'white', 1, false)
    end
end
^^^ This makes it so that when a checkpoint is hit, the camera will zoom in and flash white(if the user has flashingLights enabled.)

function checkpointHitEffect(checkpointNumber)
    if flashingLights then
        cameraFlash('game', 'white', 1, false)
    end
    setProperty('camGame.angle', 360)
    doTweenAngle('camGameAngle', 'camGame', 0, 2, 'circOut')
end
^^^ This makes it so that when a checkpoint is hit, the camera will rotate 360° and flash white(if the user has flashingLights enabled.)
]]--
function checkpointHitEffect(checkpointNumber)
    -- Custom checkpoint hit code goes here.
    
end

debugMode = false -- If you want to manipulate this script, or at least get to know better how it works, then you can enable this.
checkpointScreen = false -- Do you want a screen at the start of your song to let the player remove checkpoints? (enabled by default if debug mode is enabled)
resetHealthOnCheckpoint = true -- Reset the player health when a checkpoint is reached?
checkpoints = { -- Type in "[checkpoint number here] = "Time here"," (Add the comma at the end or it will break.)
}
--[[
--[(Examples of checkpoints)]--
checkpoints = { 
    [1] = "0:27",
    [2] = "1:30",
} Here, there are 2 checkpoints. One at 27 seconds in, and one at 1 minute and 30 seconds in.

checkpoints = { 
    [1] = "0:27",
    [2] = "1:30",
    [3] = "1:52",
    [4] = "2:30",
    [5] = "2:47",
} Here, there are 5 checkpoints. you can see how each one of these checkpoints follows the same pattern:
checkpoints = { 
    [checkpoint number here] = "Time here",
}

--[(Important(It will break without these.))]--
MAKE SURE THAT IF IT ONLY HAS SECONDS, DO 0: AT THE START! IF IT IS A ONE DIGIT SECONDS VALUE, 
DO mins:0seconds. (ADD A 0 BEFORE THE ONE DIGIT SECONDS VALUE!!)

THEY MUST BE IN ORDER!!! IT WILL BREAK IF THE CHECKPOINT TIMES ARENT FROM LEAST TO GREATEST!!!!




---------------------[DONT EDIT ANYTHING BYOND THIS POINT (Unless you know what your doing.)]---------------------
]]--



curCheckpoint = 0
songStarted = false
setHealthOnUpdate = false
doubleFix = false


function onCreate()
    if debugMode then
        luaDebugMode = true
        checkpointScreen = true
    end
    initSaveData('songProgress'..songName)
    if debugMode then
        debugPrint('songProgress'..songName..' has been initialized.')
    end
    if debugMode and table.getn(checkpoints) < 1 then
        debugPrint('There are no checkpoints to be hit.')
    end
end

function onCreatePost()
    makeLuaSprite("checkpointImg", checkpointImgPath, 0, 0)
    screenCenter("checkpointImg", y)
    setProperty("checkpointImg.x", getProperty("checkpointImg.width") * 3.5)
    setObjectCamera("checkpointImg", 'hud')
    addLuaSprite("checkpointImg", true)
    if colorCheckpointImg then
        setProperty("checkpointImg.color", checkpointImgColor)
    end
    setHealthOnUpdate = true
    doubleFix = true
end

function setSongTime(time)
    if debugMode then
        debugPrint('Setting the song time to '..time..'.')
    end
    setPropertyFromClass('backend.Conductor', 'songPosition', time)
    setProperty('vocals.time', getSongPosition())
    setPropertyFromClass('flixel.FlxG', 'sound.music.time', getSongPosition())
end

function onSongStart()
    songStarted = true
    if getDataFromSave('songProgress'..songName, 'checkpointHit') ~= nil then
        checkpointHit = getDataFromSave('songProgress'..songName, 'checkpointHit')
    end
    if checkpointHit then
        onCheckpointRespawn()
        funy = minSecToMilliseconds(checkpoints[curCheckpoint])
        setSongTime(funy)
        setProperty('camGame.zoom', getProperty("defaultCamZoom"))
	    setProperty('camHUD.zoom', 1)
    end
    runTimer('resetHealth', 1)
    runTimer('doubleFix', 3)
end

function doTweenProperty(tag, property, value, duration, ease)
    runHaxeCode([[
        game.modchartTweens.set(']]..tag..[[', FlxTween.tween(game,{]]..property..[[: ]]..value..[[}, ]]..duration..[[, {ease: FlxEase.]]..ease..[[, 
            onComplete: function(twn:FlxTween) {
                game.callOnLuas('onTweenCompleted', [']]..tag..[[']);
                game.modchartTweens.remove(']]..tag..[[');
            }
        }));
    ]])
end

timeFrame = 110
function canBeHit(st)
    local sp = getSongPosition()
    return st > (sp - (timeFrame * 1.8)) and st < (sp + timeFrame)
end

function onUpdatePost(elapsed)
    if setHealthOnUpdate then -- So that you dont die immidiately
        for i = 0, getProperty('notes.length') - 1 do -- Code from my(ZSolarDev's) unreleased input system (sustains didnt work properly in it anyways. :p)
            if getPropertyFromGroup('notes', i, 'mustPress') then
                numberToLookFor = i
                curNoteData = (getPropertyFromGroup('notes', i, 'noteData') + 1)
                if canBeHit(getPropertyFromGroup('notes', i, 'strumTime')) then
                    removeFromGroup('notes', i)
                end
            end
        end

        setHealth(1)
        setProperty('songMisses', getDataFromSave('songProgress'..songName, 'missSave'))
    end
    if doubleFix then -- I(ZSolarDev) accept defeat, ratings dont work
	    setRatingPercent(getDataFromSave('songProgress'..songName, 'rating'))
        setRatingName(getDataFromSave('songProgress'..songName, 'ratingName'))
        setRatingFC(getDataFromSave('songProgress'..songName, 'ratingFC'))
        setProperty('totalNotesHit', getDataFromSave('songProgress'..songName, 'totalNotesHit'))
        setProperty('totalPlayed', getDataFromSave('songProgress'..songName, 'totalPlayed'))
        setProperty('songMisses', getDataFromSave('songProgress'..songName, 'missSave'))
        setProperty('scoreTxt.text', 'Score: '..score..' | Misses: '..misses..' | Rating: ?')
    end
    if songStarted and table.getn(checkpoints) > 0 then
        for _, checkpoint in ipairs(checkpoints) do
            if getPropertyFromClass("backend.Conductor", "songPosition") > minSecToMilliseconds(checkpoint) - 1 then
                if curCheckpoint < getIDFromCheckpointString(checkpoint) then
                    curCheckpoint = curCheckpoint + 1
                    if debugMode then
                        debugPrint('Incrementing the currentCheckpoint variable by 1.')
                    end
                    onCheckpointReached(curCheckpoint)
                end
            end
        end
    end
end

function onCheckpointReached(index)
    if debugMode then
        debugPrint('A checkpoint has been hit at '..checkpoints[index]..'.')
    end
    if resetHealthOnCheckpoint then
        if debugMode then
            debugPrint('Resetting health on checkpoint '..index..'.')
        end
        doTweenProperty('checkpointResetHealth', 'health', 1, 0.5, 'circOut')
    end
    if not customCheckpointHitEffect then
        if debugMode then
            debugPrint('Using default checkpoint hit effect..')
        end
        playSound(checkpointSoundPath)
        doTweenX('checkpointImgCenter', 'checkpointImg', (screenWidth - getProperty("checkpointImg.width"))/2, checkpointImgScreenTime/3, 'circOut')
    else
        if debugMode then
            debugPrint('Calling checkpointHitEffect() with index '..index..'.')
        end
        checkpointHitEffect(index)
    end

    if debugMode then
        debugPrint('setting checkpoint save data...')
    end
    setDataFromSave('songProgress'..songName, 'scoreSave', score)
    setDataFromSave('songProgress'..songName, 'totalNotesHit', getProperty('totalNotesHit'))
    setDataFromSave('songProgress'..songName, 'missSave', misses)
    setDataFromSave('songProgress'..songName, 'comboSave', combo)
    setDataFromSave('songProgress'..songName, 'totalPlayed', hits)
    setDataFromSave('songProgress'..songName, 'checkpointHit', true)
    setDataFromSave('songProgress'..songName, 'checkpoint', index)
    setDataFromSave('songProgress'..songName, 'rating', rating)
	setDataFromSave('songProgress'..songName, 'ratingName', ratingName)
	setDataFromSave('songProgress'..songName, 'ratingFC', ratingFC)
    flushSaveData('songProgress'..songName);
    if debugMode then
        debugPrint('checkpoint save data has been flushed.')
    end
end

---
--- @param tag string
--- @param ?vars ?
---
function onTweenCompleted(tag, vars)
    if tag == 'checkpointImgCenter' then
        runTimer('checkpointImgExit', checkpointImgScreenTime/3)
    end
    if tag == 'checkpointImgExitScreen' then
        setProperty('checkpointImg.x', getProperty("checkpointImg.width") * 3.5)
    end
end

---
--- @param tag string
--- @param loops integer
--- @param loopsLeft integer
---
function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'disableCheckpoints' then
        if debugMode then
            debugPrint('Checkpoints will be wiped.')
        end
        disableCheckpoints = true
        cantPress = false
        clearData()
        startCountdown()
        WarningMenuReal = false
        removeLuaSprite('warnBG', true)
        removeLuaText('warning', true)
    end
    if tag == 'keepCheckpoints' then
        if debugMode then
            debugPrint('Checkpoints will be kept.')
        end
        disableCheckpoints = false
        cantPress = false
        startCountdown()
        WarningMenuReal = false
        removeLuaSprite('warnBG', true)
        removeLuaText('warning', true)
    end

    if tag == 'fadeTxt' then
        doTweenAlpha('warningFade', 'warning', 0, 1, 'circIn')
        doTweenAlpha('warningBGFade', 'warnBG', 0, 1, 'circIn')
    end

    if tag == 'resetHealth' then
        setHealthOnUpdate = false
        setProperty('songMisses', getDataFromSave('songProgress'..songName, 'missSave'))
    end
    if tag == 'doubleFix' then
        doubleFix = false
        setProperty('songMisses', getDataFromSave('songProgress'..songName, 'missSave'))
    end
    if tag == 'checkpointImgExit' then
        doTweenX('checkpointImgExitScreen', 'checkpointImg', -(getProperty("checkpointImg.width") * 3.5), checkpointImgScreenTime/3, 'circIn')
    end
end

function getIDFromCheckpointString(c)
    for i = 1, #checkpoints do
        if checkpoints[i] == c then
            return i
        end
    end
    return nil
end

function minSecToMilliseconds(minSec)
    if minSec == nil then
        if debugMode then
            debugPrint('Returning 0 instead of nil to prevent anything bad from happening.')
        end
        return 0
    end
    local mins = stringSplit(minSec, ":")[1]
    local seconds = stringSplit(minSec, ":")[2]
    local minToSec = 60*mins
    local fullSeconds = minToSec + seconds
    local milliseconds = fullSeconds * 1000
    return milliseconds
end

function millisecondsToMinSec(milliseconds) -- Useless utility function, ill keep it just in case this is updated later.
    if debugMode then
        debugPrint('Converting '..milliseconds..' To minutes:seconds...')
    end
    local seconds = math.floor(milliseconds/1000)
    local finalMinutes = math.floor(seconds/60)
    local finalSeconds = seconds
    while finalSeconds > 59 do
        finalSeconds = finalSeconds - 60
    end
    local finalSecStr = ''
    if finalSeconds < 10 then
        finalSecStr = '0'..tostring(finalSeconds)
    else
        finalSecStr = tostring(finalSeconds)
    end
    local result = tostring(finalMinutes)..':'..finalSecStr
    if debugMode and result ~= nil then
        debugPrint('Returning '..tostring(result)..'.')
    else
        if debugMode then
            debugPrint('The returning result is nil.')
        end
    end
    return result
end

checkpointHit = false

function onCheckpointRespawn()
    if debugMode then
        debugPrint('Setting player stats...')
    end
    setProperty('songScore', getDataFromSave('songProgress'..songName, 'scoreSave'))
    setProperty('songMisses', getDataFromSave('songProgress'..songName, 'missSave'))
    setProperty('combo', getDataFromSave('songProgress'..songName, 'comboSave')) -- amazing!
    setProperty('totalNotesHit', getDataFromSave('songProgress'..songName, 'totalNotesHit'))
    setProperty('totalPlayed', getDataFromSave('songProgress'..songName, 'totalPlayed'))
    setProperty('ratingPercent', getDataFromSave('songProgress'..songName, 'rating'))
	setProperty('ratingName', getDataFromSave('songProgress'..songName, 'ratingName'))
	setProperty('ratingFC', getDataFromSave('songProgress'..songName, 'ratingFC'))
    curCheckpoint = getDataFromSave('songProgress'..songName, 'checkpoint')
    if debugMode then
        debugPrint('Defaults have been set.')
    end
end

function onGameOver()
    
end

function onGameOverConfirm(isNotGoingToMenu)
    if not isNotGoingToMenu then
        clearData()
    end
end

function onEndSong()
    clearData()
end

function clearData()
    if debugMode then
        debugPrint('Clearing save data...')
    end
    setDataFromSave('songProgress'..songName, 'scoreSave', 0)
    setDataFromSave('songProgress'..songName, 'missSave', 0)
    setDataFromSave('songProgress'..songName, 'comboSave', 0)
    setDataFromSave('songProgress'..songName, 'totalNotesHit', 0)
    setDataFromSave('songProgress'..songName, 'totalPlayed', 0)
    setDataFromSave('songProgress'..songName, 'checkpointHit', false)
    setDataFromSave('songProgress'..songName, 'checkpoint', 0)
    setDataFromSave('songProgress'..songName, 'ratingName', '?')
	setDataFromSave('songProgress'..songName, 'ratingFC', '')
	setDataFromSave('songProgress'..songName, 'misses', 0)
    flushSaveData('songProgress'..songName);
    if debugMode then
        debugPrint('Save data has been wiped.')
    end
end


local warningTxt
local allowCountdown = false
local cantPress = false

function onStartCountdown()
	if not allowCountdown and checkpointScreen then
        disableCheckpoints = false
        
        makeLuaSprite('warnBG', '', 0, 0)
        makeGraphic('warnBG', screenWidth, screenHeight, '000000')
        screenCenter('warnBG')
        setObjectCamera('warnBG', 'camOther')
        addLuaSprite('warnBG')
        setObjectCamera('warnBG', 'camOther')
        if shaders then
            makeLuaText('warning', warningTxtSHADER, 0, 0)
            setProperty('warning.x', -70)
            setTextAlignment('warning', 'center')
            addLuaText('warning')
        else
            makeLuaText('warning', [[
                Remove all checkpoints in this song?
                (Press Escape to accept, press Space/Enter to cancel)
            ]], -100, 0)
            setTextSize('warning', 10)
            setTextAlignment('warning', 'center')
            addLuaText('warning')
        end
        screenCenter('warning', 'y')
        setTextSize('warning', 25)
        setObjectCamera('warning', 'camOther')
        setObjectOrder('warnBG', 100000)
        setObjectOrder('warning', 100001)
        WarningMenuReal = true
		allowCountdown = true
        return Function_Stop  
	end
    return Function_Continue
end

function onUpdate(elapsed)
    if WarningMenuReal then
        if keyboardJustPressed('ESCAPE') and not cantPress then
            cameraFlash('camOther', 'FFFFFF', 1)
            cantPress = true
            runTimer('disableCheckpoints', 2, 1)
            runTimer('fadeTxt', 1, 1)
            playSound('cancelMenu', 1)
        end
        if not cantPress then
            if keyboardJustPressed('SPACE') or keyboardJustPressed('ENTER') then
                cameraFlash('camOther', '000000', 1)
                cantPress = true
                runTimer('keepCheckpoints', 2, 1)
                runTimer('fadeTxt', 1, 1)
                playSound('confirmMenu', 1)
            end
        end
    end
end