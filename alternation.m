% Copyright (c) 2012 Aaron Roth
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.
%

function alternation(monkeysInitial, condition)
    % ---------------------------------------------- %
    % -------------- Global variables -------------- %
    % ---------------------------------------------- %
    
    % Colors.
    colorBackground = [0 0 0];
    colorYellow     = [255 255 0];
    
    % Coordinates.
    centerX         = 512;                  % X pixel coordinate for the screen center.
    centerY         = 384;                  % Y pixel coordinate for the screen center.
    hfWidth         = 88;                   % Half the width of the fixation boxes.
    
    % Values to calculate fixation boxes.
    fixBoundXMax    = centerX + hfWidth;
    fixBoundXMin    = centerX - hfWidth;
    fixBoundYMax    = centerY + hfWidth;
    fixBoundYMin    = centerY - hfWidth;
    
    leftBoundXMax   = centerX;
    leftBoundXMin   = centerX;
    leftBoundYMax   = centerY;
    leftBoundYMin   = centerY;
    
    rightBoundXMax  = centerX;
    rightBoundXMin  = centerX;
    rightBoundYMax  = centerY;
    rightBoundYMin  = centerY;
    
    % References.
    monkeyScreen    = 1;                    % Number of the screen the monkey sees.
    trackedEye      = 2;                    % Values: 1 (left eye), 2 (right eye).
    
    % Delays.
    smallDelay      = 1.0;
    mediumDelay     = 3.0;
    largeDelay      = 4.5;
    
    % Rewards.
    smallReward     = 0.045;
    mediumReward    = 0.078;
    largeReward     = 0.11;
    
    % Saving.
    data            = struct([]);           % Workspace variable where trial data is saved.
    riskySkewsData  = '/Data/Alternation';  % Directory where .mat files are saved.
    saveCommand     = NaN;                  % Command string that will save .mat files.
    varName         = 'data';               % Name of the variable to save in the workspace.
    
    % Stimuli.
    dotRadius       = 10;                   % Radius of the fixation dot.
    fixAdj          = 1;
    
    % Times.
    ITI             = 2;                    % Intertrial interval (set below).
    minFixTime      = 0.1;                  % Minimum time monkey must fixate to start trial.
    timeToFix       = intmax;               % Amount of time monkey is given to fixate.
    
    % Trial.
    altTracker      = 0;                    % Keeps track of the alternations.
    currTrial       = 0;                    % Current trial.
    delayOnLeft     = 0;                    % Delay before reward given for a left choice.
    delayOnRight    = 0;                    % Delay before reward given for a right choice.
    rewardOnLeft    = 0;                    % Reward to be given for a left choice.
    rewardOnRight   = 0;                    % Reward to be given for a right choice.
    stimOnLeft      = '';                   % Stimulus to be displayed on the left.
    stimOnRight     = '';                   % Stimulus to be displayed on the right.
    
    % ---------------------------------------------- %
    % ------------------- Setup -------------------- %
    % ---------------------------------------------- %
    
    % Run condition A.
    if condition == 1
        imgCoral = imread('images/coral.jpg', 'jpg');
        imgDesert = imread('images/desert.jpg', 'jpg');
    % Run condition B.
    elseif condition == 2
        imgFlower = imread('images/flower.jpg', 'jpg');
        imgSunset = imread('images/sunset.jpg', 'jpg');
    else
        disp('Error: Illegal value for the "condition" argument passed to "alternation"');
        disp('Value must be either 1 (Condition A) or 2 (Condition B)');
        return;
    end
    
    % Saving.
    % prepare_for_saving;
    
    % Window.
    % window = setup_window;
    
    % Eyelink.
    setup_eyelink;
    
    % ---------------------------------------------- %
    % ------------ Main experiment loop ------------ %
    % ---------------------------------------------- %
    
    running = true;
    while running
        run_single_trial;
        
        % print_stats();
        
        % Check for pausing or quitting during ITI.
        startingTime = GetSecs;
        while ITI > (GetSecs - startingTime)
            key = key_check;
            
            % Pause experiment.
            if key.pause == 1
                pause(key);
            end
            
            % Exit experiment.
            if key.escape == 1
                running = false;
            end
        end
    end
    
    % Screen('CloseAll');
    
    % ---------------------------------------------- %
    % ----------------- Functions ------------------ %
    % ---------------------------------------------- %
    
    % Determines if the eye has fixated within the given bounds
    % for the given duration before the given timeout occurs.
    function [fixation, area] = check_fixation(type, duration, timeout)
        startTime = GetSecs;
        
        % Keep checking for fixation until timeout occurs.
        while timeout > (GetSecs - startTime)
            [xCoord, yCoord] = get_eye_coords;
            
            % Determine if one, two, or three locations are being tracked.
            if strcmp(type, 'single')
                % Determine if eye is within the fixation boundary.
                if xCoord >= fixBoundXMin && xCoord <= fixBoundXMax && ...
                   yCoord >= fixBoundYMin && yCoord <= fixBoundYMax
                    % Determine if eye maintained fixation for given duration.
                    checkFixBreak = fix_break_check(fixBoundXMin, fixBoundXMax, ...
                                                    fixBoundYMin, fixBoundYMax, ...
                                                    duration);
                    
                    if checkFixBreak == false
                        % Fixation was obtained for desired duration.
                        fixation = true;
                        area = 'single';
                        
                        return;
                    end
                end
            elseif strcmp(type, 'double')
                % Determine if eye is within the left option boundary.
                if xCoord >= leftBoundXMin && xCoord <= leftBoundXMax && ...
                   yCoord >= leftBoundYMin && yCoord <= leftBoundYMax
                    % Determine if eye maintained fixation for given duration.
                    checkFixBreak = fix_break_check(leftBoundXMin, leftBoundXMax, ...
                                                    leftBoundYMin, leftBoundYMax, ...
                                                    duration);
                    
                    if checkFixBreak == false
                        % Fixation was obtained for desired duration.
                        fixation = true;
                        area = 'double';
                        
                        return;
                    end
                % Determine if eye is within the right option boundary.
                elseif xCoord >= rightBoundXMin && xCoord <= rightBoundXMax && ...
                       yCoord >= rightBoundYMin && yCoord <= rightBoundYMax
                    % Determine if eye maintained fixation for given duration.
                    checkFixBreak = fix_break_check(rightBoundXMin, rightBoundXMax, ...
                                                    rightBoundYMin, rightBoundYMax, ...
                                                    duration);
                    
                    if checkFixBreak == false
                        % Fixation was obtained for desired duration.
                        fixation = true;
                        area = 'double';
                        
                        return;
                    end
                end
            else
                disp('Fixation being checked with an illegal value for the "type" parameter.');
            end
        end
        
        % Timeout reached.
        fixation = false;
        area = 'none';
    end
    
    % Draws a thin line on top of the invisible fixation boundaries.
    function draw_fixation_bounds()
        Screen('FrameRect', window, colorYellow, [fixBoundXMin fixBoundYMin ...
                                                  fixBoundXMax fixBoundYMax], 1);
        Screen('Flip', window);
    end
    
    % Draws the fixation point on the screen.
    function draw_fixation_point(color)
        Screen('FillOval', window, color, [centerX - dotRadius + fixAdj; ...
                                           centerY - dotRadius; ...
                                           centerX + dotRadius - fixAdj; ...
                                           centerY + dotRadius]);
        Screen('Flip', window);
    end
    
    % Checks if the eye breaks fixation bounds before end of duration.
    function fixationBreak = fix_break_check(xBoundMin, xBoundMax, ...
                                             yBoundMin, yBoundMax, ...
                                             duration)
        fixStartTime = GetSecs;
        
        % Keep checking for fixation breaks for the entire duration.
        while duration > (GetSecs - fixStartTime)
            [xCoord, yCoord] = get_eye_coords;
            
            % Determine if the eye has left the fixation boundaries.
            if xCoord < xBoundMin || xCoord > xBoundMax || ...
               yCoord < yBoundMin || yCoord > yBoundMax
                % Eye broke fixation before end of duration.
                fixationBreak = true;
                
                return;
            end
        end
        
        % Eye maintained fixation for entire duration.
        fixationBreak = false;
    end

    % Creates the values for a stimulus presentation.
    function generate_trial_vars(taskType)
        % Determine what trial type it will be.
        possibleCondATrials = [{'AB'}, {'BA'}];
        randIndex = rand_int(2);
        currTrialType = char(possibleCondATrials(randIndex));
        
        % Determine positioning.
        randIndex = rand_int(2);
        stimOnLeft = currTrialType(randIndex);
        tempCurrType = currTrialType;
        tempCurrType(randIndex) = [];
        stimOnRight = tempCurrType(1);
        
        if taskType == 1
            % Set alternating rewards for the "B" stimulus in Condition A.
            if strcmp(stimOnLeft, 'A')
                rewardOnLeft = mediumReward;
                
                if altTracker == 0
                    rewardOnRight = smallReward;
                    altTracker = 1;
                else
                    rewardOnRight = largeReward;
                    altTracker = 0;
                end
            else
                rewardOnRight = mediumReward;
                
                if altTracker == 0
                    rewardOnLeft = smallReward;
                    altTracker = 1;
                else
                    rewardOnLeft = largeReward;
                    altTracker = 0;
                end
            end
            
            % Set constant delays in Condition A.
            delayOnLeft = smallDelay;
            delayOnRight = smallDelay;
        elseif taskType == 2
            % Set alternating delays to reward for the "B" stimulus in Condition B.
            if strcmp(stimOnLeft, 'A')
                delayOnLeft = mediumDelay;
                
                if altTracker == 0
                    delayOnRight = smallDelay;
                    altTracker = 1;
                else
                    delayOnRight = largeDelay;
                    altTracker = 0;
                end
            else
                delayOnRight = mediumDelay;
                
                if altTracker == 0
                    delayOnLeft = smallDelay;
                    altTracker = 1;
                else
                    delayOnLeft = largeDelay;
                    altTracker = 0;
                end
            end
            
            % Set constant rewards in Condition B.
            rewardOnLeft = mediumReward;
            rewardOnRight = mediumReward;
        else
            disp('Error: Illegal value for the "taskType" argument passed to "generate_trial_vars"');
            disp('Value must be either 1 or 2');
            return;
        end
    end
    
    % Returns the current x and y coordinants of the given eye.
    function [xCoord, yCoord] = get_eye_coords()
        sampledPosition = Eyelink('NewestFloatSample');
        
        xCoord = sampledPosition.gx(trackedEye);
        yCoord = sampledPosition.gy(trackedEye);
    end
    
    % Checks to see what key was pressed.
    function key = key_check()
        % Assign key codes to some variables.
        stopKey = KbName('ESCAPE');
        pauseKey = KbName('RightControl');
        
        % Make sure default values of key are zero.
        key.pressed = 0;
        key.escape = 0;
        key.pause = 0;
        
        % Get info about any key that was just pressed.
        [~, ~, keyCode] = KbCheck;
        
        % Check pressed key against the keyCode array of 256 key codes.
        if keyCode(stopKey)
            key.escape = 1;
            key.pressed = 1;
        end
        
        if keyCode(pauseKey)
            key.pause = 1;
            key.pressed = 1;
        end
    end
    
    % Makes a folder and file where data will be saved.
    function prepare_for_saving()
        cd(riskySkewsData);
        
        % Check if cell ID was passed in with monkey's initial.
        if numel(monkeysInitial) == 1
            initial = monkeysInitial;
            cell = '';
        else
            initial = monkeysInitial(1);
            cell = monkeysInitial(2);
        end
        
        dateStr = datestr(now, 'yymmdd');
        filename = [initial dateStr '.' cell '1.<TrialNameInitials>.mat'];
        folderNameDay = [initial dateStr];
        
        % Make and/or enter a folder where .mat files will be saved.
        if exist(folderNameDay, 'dir') == 7
            cd(folderNameDay);
        else
            mkdir(folderNameDay);
            cd(folderNameDay);
        end
        
        % Make sure the filename for the .mat file is not already used.
        fileNum = 1;
        while fileNum ~= 0
            if exist(filename, 'file') == 2
                fileNum = fileNum + 1;
                filename = [initial dateStr '.' cell num2str(fileNum) '.<TrialNameInitials>.mat'];
            else
                fileNum = 0;
            end
        end
        
        saveCommand = ['save ' filename ' ' varName];
    end
    
    % TODO: Add appropriate print out.
    % Prints current trial stats.
    function print_stats()
        % Convert percentages to strings.
        blockPercentCorrStr  = strcat(num2str(blockPercentCorr), '%');
        totalPercentCorrStr  = strcat(num2str(totalPercentCorr), '%');
        currBlockTrialStr    = num2str(currBlockTrial);
        trialCountStr        = num2str(trialCount);
        
        home;
        disp('             ');
        disp('****************************************');
        disp('             ');
        fprintf('Block trials: % s', currBlockTrialStr);
        disp('             ');
        fprintf('Total trials: % s', trialCountStr);
        disp('             ');
        disp('             ');
        disp('----------------------------------------');
        disp('             ');
        fprintf('Block correct: % s', blockPercentCorrStr);
        disp('             ');
        fprintf('Total correct: % s', totalPercentCorrStr);
        disp('             ');
        disp('             ');
        disp('****************************************');
    end
    
    function k = pause(k)
        disp('             ');
        disp('\\\\\\\\\\\\\\\\\\\\\\\\\\\\          /////////////////////////////');
        disp(' \\\\\\\\\\\\\\\\\\\\\\\\\\\\ PAUSED /////////////////////////////');
        disp('  |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||');
        
        while k.pressed == 1
            k = key_check;
        end
        
        pause = 1;
        while pause == 1 && k.escape ~= 1
            k = key_check;
            
            if k.pause == 1
                pause = 0;
            end
        end
        
        while k.pressed == 1
            k = key_check;
        end
        
        disp('             ');
        disp('  ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||');
        disp(' /////////////////////////// UNPAUSED \\\\\\\\\\\\\\\\\\\\\\\\\\\');
        disp('///////////////////////////            \\\\\\\\\\\\\\\\\\\\\\\\\\\');
        disp('             ');
    end
    
    % Returns a random int between 1 (inclusive) and integer + 1 (inclusive).
    function randInt = rand_int(integer)
        randInt = floor(rand(1) * integer + 1);
    end
    
    % Rewards monkey using the juicer with the passed duration.
    function reward(rewardDuration)
        if rewardDuration ~= 0
            % Get a reference the juicer device and set reward duration.
            daq = DaqDeviceIndex;
            
            % Open juicer.
            DaqAOut(daq, 0, .6);
            
            startTime = GetSecs;
            
            % Keep looping to keep juicer open until reward end.
            while (GetSecs - startTime) < rewardDuration
            end
            
            % Close juicer.
            DaqAOut(daq, 0, 0);
        end
    end
    
    % Does exactly what you freakin' think it does.
    function run_single_trial()
        % draw_fixation_point(colorYellow);
        if condition == 1
            generate_trial_vars(1);
        else
            generate_trial_vars(2);
        end
        
        % send_and_save;
    end

    % Saves trial data to a .mat file.
    function send_and_save()
        % Save variables to a .mat file.
        data(currTrial).trial = currTrial;  % The trial number for this trial.
        
        eval(saveCommand);
    end
    
    % Sets up the Eyelink system.
    function setup_eyelink()
        abortSetup = false;
        setupMode = 2;
        
        % Connect Eyelink to computer if unconnected.
        if ~Eyelink('IsConnected')
            Eyelink('Initialize');
        end
        
        % Start recording eye position.
        Eyelink('StartRecording');
        
        % Set some preferences.
        Eyelink('Command', 'randomize_calibration_order = NO');
        Eyelink('Command', 'force_manual_accept = YES');
        
        Eyelink('StartSetup');
        
        % Wait until Eyelink actually enters setup mode.
        while ~abortSetup && Eyelink('CurrentMode') ~= setupMode
            [keyIsDown, ~, keyCode] = KbCheck;
            
            if keyIsDown && keyCode(KbName('ESCAPE'))
                abortSetup = true;
                disp('Aborted while waiting for Eyelink!');
            end
        end
        
        % Put Eyelink in output mode.
        Eyelink('SendKeyButton', double('o'), 0, 10);
        
        % Start recording.
        Eyelink('SendKeyButton', double('o'), 0, 10);
    end
    
    % Sets up a new window and sets preferences for it.
    function window = setup_window()
        % Print only PTB errors.
        Screen('Preference', 'VisualDebugLevel', 1);
        
        % Suppress the print out of all PTB warnings.
        Screen('Preference', 'Verbosity', 0);
        
        % Setup a screen for displaying stimuli for this session.
        window = Screen('OpenWindow', monkeyScreen, colorBackground);
    end
end