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
    colorCyan       = [0 255 255];
    colorYellow     = [255 255 0];
    colorWhite      = [255 255 255];
    
    % Coordinates.
    centerX         = 512;                  % X pixel coordinate for the screen center.
    centerY         = 384;                  % Y pixel coordinate for the screen center.
    endsBoundAdj    = 384;                  % Coordinate adjustment.
    hfWidth         = 88;                   % Half the width of the fixation boxes.
    imageWidth      = 300;                  % The width of the presented images.
    imageHeight     = 400;                  % The height of the presented images.
    sideBoundAdj    = 211;                  % Coordinate adjustment.
    
    % Values to calculate fixation boxes.
    fixBoundXMax    = centerX + hfWidth;
    fixBoundXMin    = centerX - hfWidth;
    fixBoundYMax    = centerY + hfWidth;
    fixBoundYMin    = centerY - hfWidth;
    
    % Fixation bondaries for the left stimulus.
    leftBoundXMax   = 2 * centerX - 4 * hfWidth - imageWidth;
    leftBoundXMin   = centerX - imageWidth - sideBoundAdj;
    leftBoundYMax   = centerY + endsBoundAdj;
    leftBoundYMin   = centerY - endsBoundAdj;
    
    % Fixation boundaries for the right stimulus.
    rightBoundXMax  = centerX + imageWidth + sideBoundAdj;
    rightBoundXMin  = 4 * hfWidth + imageWidth;
    rightBoundYMax  = centerY + endsBoundAdj;
    rightBoundYMin  = centerY - endsBoundAdj;
    
    % Coordinates for drawing the left stimulus image. 
    leftStimXMax    = centerX - 2 * hfWidth;
    leftStimXMin    = centerX - 2 * hfWidth - imageWidth;
    leftStimYMax    = centerY + imageHeight / 2;
    leftStimYMin    = centerY - imageHeight / 2;
    
    % Coordinates for drawing the right stimulus image.
    rightStimXMax   = centerX + 2 * hfWidth + imageWidth;
    rightStimXMin   = centerX + 2 * hfWidth;
    rightStimYMax   = centerY + imageHeight / 2;
    rightStimYMin   = centerY - imageHeight / 2;
    
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
    alternationData = '/Data/Alternation';  % Directory where .mat files are saved.
    saveCommand     = NaN;                  % Command string that will save .mat files.
    varName         = 'data';               % Name of the variable to save in the workspace.
    
    % Stimuli.
    feedThick       = 10;                   % Thickness of the feedback border.
    dotRadius       = 10;                   % Radius of the fixation dot.
    fixAdj          = 1;
    
    % Times.
    chooseFixTime   = 0.4;                  % Time needed to look at option to select it.
    condADutyCycle  = 4.0;                  % Duty cycle: Time from beginning to end of trial.
    condBITI        = 1.0;                  % ITI for Condition B.
    ITI             = 0;                    % Intertrial interval (set below).
    minFixTime      = 0.1;                  % Minimum time monkey must fixate to start trial.
    timeToFix       = intmax;               % Amount of time monkey is given to fixate.
    
    % Trial.
    aCount          = 0;                    % Number of times the A trial option was chosen.
    altTracker      = 0;                    % Keeps track of the alternations.
    aOverBLowShort  = 0;                    % Times A was chosen over B when B was low or short.
    aOverBHighLong  = 0;                    % Times A was chosen over B when B was high or long.
    pAOverBLowShort = 0;                    % Percent A was chosen over B when B was low or short.
    pAOverBHighLong = 0;                    % Percent A was chosen over B when B was high or long.
    percentAOverall = 0;                    % Percent A chosen over B overall.
    choiceMade      = '';                   % What the subject chose; A or B.
    currTrial       = 0;                    % Current trial.
    decisionTime    = 0;                    % Time monkey took to make a decision.
    delayGiven      = 0;                    % The delay given on the current trial.
    delayOnLeft     = 0;                    % Delay before reward given for a left choice.
    delayOnRight    = 0;                    % Delay before reward given for a right choice.
    rewardGiven     = 0;                    % Reward actually received.
    rewardOnLeft    = 0;                    % Reward to be given for a left choice.
    rewardOnRight   = 0;                    % Reward to be given for a right choice.
    screenFlip      = true;                 % Whether or not the screen should be "flipped."
    stimOnLeft      = '';                   % Stimulus to be displayed on the left.
    stimOnRight     = '';                   % Stimulus to be displayed on the right.
    totalLowShort   = 0;                    % Total # of times a low or short B stimulus was present.
    totalHighLong   = 0;                    % Total # of times a high or long B stimulus was present.
    
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
    prepare_for_saving;
    
    % Window.
    window = setup_window;
    
    % Eyelink.
    setup_eyelink;
    
    % ---------------------------------------------- %
    % ------------ Main experiment loop ------------ %
    % ---------------------------------------------- %
    
    running = true;
    while running
        run_single_trial;
        
        print_stats();
        
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
    
    Screen('CloseAll');
    
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
                    draw_feedback('left', colorWhite);
                    
                    % Determine if eye maintained fixation for given duration.
                    checkFixBreak = fix_break_check(leftBoundXMin, leftBoundXMax, ...
                                                    leftBoundYMin, leftBoundYMax, ...
                                                    duration);
                    
                    if checkFixBreak == false
                        % Fixation was obtained for desired duration.
                        fixation = true;
                        area = 'left';
                        
                        return;
                    else
                        draw_stimuli;
                    end
                % Determine if eye is within the right option boundary.
                elseif xCoord >= rightBoundXMin && xCoord <= rightBoundXMax && ...
                       yCoord >= rightBoundYMin && yCoord <= rightBoundYMax
                    draw_feedback('right', colorWhite);
                    
                    % Determine if eye maintained fixation for given duration.
                    checkFixBreak = fix_break_check(rightBoundXMin, rightBoundXMax, ...
                                                    rightBoundYMin, rightBoundYMax, ...
                                                    duration);
                    
                    if checkFixBreak == false
                        % Fixation was obtained for desired duration.
                        fixation = true;
                        area = 'right';
                        
                        return;
                    else
                        draw_stimuli;
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

    % Draw colored outlines around options for feedback.
    function draw_feedback(location, color)
        if strcmp(location, 'left')
            if strcmp(stimOnLeft, 'A') || strcmp(stimOnLeft, 'B')
                screenFlip = false;
                draw_stimuli;
                Screen('FrameRect', window, color, [leftStimXMin, leftStimYMin, ...
                                                    leftStimXMax, leftStimYMax], feedThick);
                Screen('Flip', window);
            end
        elseif strcmp(location, 'right')
            if strcmp(stimOnRight, 'A') || strcmp(stimOnRight, 'B')
                screenFlip = false;
                draw_stimuli;
                Screen('FrameRect', window, color, [rightStimXMin, rightStimYMin, ...
                                                    rightStimXMax, rightStimYMax], feedThick);
                Screen('Flip', window);
            end
        end
        
        screenFlip = true;
    end
    
    % Draws the fixation point on the screen.
    function draw_fixation_point(color)
        Screen('FillOval', window, color, [centerX - dotRadius + fixAdj; ...
                                           centerY - dotRadius; ...
                                           centerX + dotRadius - fixAdj; ...
                                           centerY + dotRadius]);
        Screen('Flip', window);
    end

    % Draws the stimuli on the screen depending on the trial type.
    function draw_stimuli()
        Screen('FillOval', window, colorBackground, [centerX - dotRadius + fixAdj; ...
                                                     centerY - dotRadius; ...
                                                     centerX + dotRadius - fixAdj; ...
                                                     centerY + dotRadius]);
        
        % Set image variables.
        if condition == 1
            imgA = imgCoral;
            imgB = imgDesert;
        else
            imgA = imgFlower;
            imgB = imgSunset;
        end
        
        if strcmp(stimOnLeft, 'A')
            Screen('PutImage', window, imgA, [leftStimXMin, leftStimYMin, ...
                                              leftStimXMax, leftStimYMax]);
        elseif strcmp(stimOnLeft, 'B')
            Screen('PutImage', window, imgB, [leftStimXMin, leftStimYMin, ...
                                              leftStimXMax, leftStimYMax]);
        end
        
        if strcmp(stimOnRight, 'A')
            Screen('PutImage', window, imgA, [rightStimXMin, rightStimYMin, ...
                                              rightStimXMax, rightStimYMax]);
        elseif strcmp(stimOnRight, 'B')
            Screen('PutImage', window, imgB, [rightStimXMin, rightStimYMin, ...
                                              rightStimXMax, rightStimYMax]);
        end
        
        if screenFlip
            Screen('Flip', window);
        end
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
        cd(alternationData);
        
        % Check if cell ID was passed in with monkey's initial.
        if numel(monkeysInitial) == 1
            initial = monkeysInitial;
            cell = '';
        else
            initial = monkeysInitial(1);
            cell = monkeysInitial(2);
        end
        
        dateStr = datestr(now, 'yymmdd');
        filename = [initial dateStr '.' cell '1.A.mat'];
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
                filename = [initial dateStr '.' cell num2str(fileNum) '.A.mat'];
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
        aPercentStr     = strcat(num2str(percentAOverall), '%');
        aOverBLowStr    = strcat(num2str(pAOverBLowShort), '%');
        aOverBHighStr   = strcat(num2str(pAOverBHighLong), '%');
        trialCountStr   = num2str(currTrial);
        rewardGivenStr  = num2str(rewardGiven);
        decisionTimeStr = num2str(decisionTime);
        delayGivenStr   = num2str(delayGiven);
        
        if condition == 1
            conditionStr = 'A (alternating rewards)';
            choiceStrA   = 'A (coral)';
            choiceStrB   = 'B (desert)';
            
            if strcmp(choiceMade, 'A')
                chosenImageStr = choiceStrA;
            else
                chosenImageStr = choiceStrB;
            end
        else
            conditionStr = 'B (alternating delays)';
            choiceStrA   = 'A (flower)';
            choiceStrB   = 'B (sunset)';
            
            if strcmp(choiceMade, 'A')
                chosenImageStr = choiceStrA;
            else
                chosenImageStr = choiceStrB;
            end
        end

        home;
        disp('             ');
        disp('****************************************');
        disp('             ');
        fprintf('Condition type: % s', conditionStr);
        disp('             ');
        fprintf('Total trials: % s', trialCountStr);
        disp('             ');
        disp('             ');
        disp('----------------------------------------');
        disp('             ');
        fprintf('Choice made: % s', chosenImageStr);
        disp('             ');
        fprintf('Decision time: % s', decisionTimeStr);
        disp('             ');
        fprintf('Reward delay: % s', delayGivenStr); 
        disp('             ');
        fprintf('Reward duration: % s', rewardGivenStr);
        disp('             ');
        disp('             ');
        disp('----------------------------------------');
        disp('             ');
        fprintf('Chose A: % s', aPercentStr);
        disp('             ');
        fprintf('Chose A over B low/short: % s', aOverBLowStr);
        disp('             ');
        fprintf('Chose A over B high/long: % s', aOverBHighStr);
        disp('             ');
        disp('             ');
        disp('****************************************');
    end

    pAOverBLowShort = 0;                    % Percent A was chosen over B when B was low or short.
    pAOverBHighLong = 0;                    % Percent A was chosen over B when B was high or long.
    percentAOverall = 0;                    % Percent A chosen over B overall.
    
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
        currTrial = currTrial + 1;
        
        % Run Condition A.
        if condition == 1
            generate_trial_vars(1);
        % Run Condition B.
        else
            generate_trial_vars(2);
        end

        draw_fixation_point(colorYellow);
        
        % Start timer only if this is Condition A.
        if condition == 1
            startTime = GetSecs;
        end

        % Check for fixation.
        [fixating, ~] = check_fixation('single', minFixTime, timeToFix);

        if fixating
            draw_stimuli;
            
            startClock = GetSecs;

            fixatingOnTarget = false;
            while ~fixatingOnTarget
                % Check for fixation on either targets.
                [fixatingOnTarget, area] = check_fixation('double', chooseFixTime, timeToFix);

                if fixatingOnTarget
                    endClock = GetSecs;
                    decisionTime = endClock - startClock;
                    
                    if strcmp(area, 'left')
                        % Display feedback stimuli.
                        draw_feedback('left', colorCyan);

                        % Give delay.
                        WaitSecs(delayOnLeft);

                        % Give appropriate reward.
                        reward(rewardOnLeft);

                        % Clear screen.
                        Screen('FillRect', window, colorBackground, ...
                               [0 0 (centerX * 2) (centerY * 2)]);
                        Screen('Flip', window);
                        
                        % Counter updates.
                        if strcmp(stimOnLeft, 'A')
                            choiceMade = 'A';
                            aCount = aCount + 1;
                            
                            if altTracker == 0
                                aOverBLowShort = aOverBLowShort + 1;
                                totalLowShort = totalLowShort + 1;
                            else
                                aOverBHighLong = aOverBHighLong + 1;
                                totalHighLong = totalHighLong + 1;
                            end
                        else
                            choiceMade = 'B';
                            
                            if altTracker == 0
                                totalLowShort = totalLowShort + 1;
                            else
                                totalHighLong = totalHighLong + 1;
                            end
                        end
                        
                        delayGiven = delayOnLeft;
                        rewardGiven = rewardOnLeft;
                    elseif strcmp(area, 'right')
                        % Display feedback stimuli.
                        draw_feedback('right', colorCyan);

                        % Give delay.
                        WaitSecs(delayOnRight);

                        % Give appropriate reward.
                        reward(rewardOnRight);

                        % Clear screen.
                        Screen('FillRect', window, colorBackground, ...
                               [0 0 (centerX * 2) (centerY * 2)]);
                        Screen('Flip', window);
                        
                        % Counter updates.
                        if strcmp(stimOnRight, 'A')
                            choiceMade = 'A';
                            aCount = aCount + 1;
                            
                            if altTracker == 0
                                aOverBLowShort = aOverBLowShort + 1;
                                totalLowShort = totalLowShort + 1;
                            else
                                aOverBHighLong = aOverBHighLong + 1;
                                totalHighLong = totalHighLong + 1;
                            end
                        else
                            choiceMade = 'B';
                            
                            if altTracker == 0
                                totalLowShort = totalLowShort + 1;
                            else
                                totalHighLong = totalHighLong + 1;
                            end
                        end
                        
                        delayGiven = delayOnLeft;
                        rewardGiven = rewardOnRight;
                    end
                    
                    % End timer and calculate ITI if this is Condition A.
                    if condition == 1
                        endTime = GetSecs;
                        elapsedTime = endTime - startTime;
                        ITI = condADutyCycle - elapsedTime;
                        if ITI < 0
                            ITI = 0;
                        end
                    % Just set ITI if this is Condition B.
                    else
                        ITI = condBITI;
                    end
                end
            end
        end
        
        save_trial_data;
    end

    % Saves trial data to a .mat file.
    function save_trial_data()
        % Calculations to create saved trial data.
        percentAOverall = round((aCount / currTrial) * 100);
        
        if totalLowShort == 0
            pAOverBLowShort = 0;
        else
            pAOverBLowShort = round((aOverBLowShort / totalLowShort) * 100);
        end
        
        if totalHighLong == 0
            pAOverBHighLong = 0;
        else
            pAOverBHighLong = round((aOverBHighLong / totalHighLong) * 100);
        end
        
        % Save variables to a .mat file.
        data(currTrial).trial = currTrial;               % The trial number for this trial.
        data(currTrial).condition = condition;           % 0 for Condition A; 1 for Condition B.
        data(currTrial).percentA = percentAOverall;      % Percent times A was chosen overall.
        data(currTrial).perAOverBLow = pAOverBLowShort;  % Percent A chosen over a B low or short.
        data(currTrial).perAOverBHigh = pAOverBHighLong; % Percent A chosen over a B high or long.
        data(currTrial).stimOnLeft = stimOnLeft;         % A or B.
        data(currTrial).stimOnRight = stimOnRight;       % A or B.
        data(currTrial).delayOnLeft = delayOnLeft;       % Just what it says.
        data(currTrial).delayOnRight = delayOnRight;     % Just what it says.
        data(currTrial).rewardOnLeft = rewardOnLeft;     % Just what it says.
        data(currTrial).rewardOnRight = rewardOnRight;   % Just what it says.
        data(currTrial).choiceMade = choiceMade;         % Option selected.
        data(currTrial).decisionTime = decisionTime; % How long it took the monkey to make a choice.
        data(currTrial).delayGiven = delayGiven;         % The delay the monkey experienced.
        data(currTrial).rewardGiven = rewardGiven;       % Reward actually received.
        data(currTrial).smallDelay = smallDelay;         % Just what it says.
        data(currTrial).mediumDelay = mediumDelay;       % Just what it says.
        data(currTrial).largeDelay = largeDelay;         % Just what it says.
        data(currTrial).smallReward = smallReward;       % Just what it says.
        data(currTrial).mediumReward = mediumReward;     % Just what it says.
        data(currTrial).largeReward = largeReward;       % Just what it says.
        data(currTrial).chooseFixTime = chooseFixTime;   % Time needed to look at option to select it.
        data(currTrial).condADutyCycle = condADutyCycle; % Condition A's duty cycle.
        data(currTrial).ITI = ITI;                       % Intertrial interval.
        data(currTrial).minFixTime = minFixTime;         % Minimum time monkey must fixate to start trial.
        data(currTrial).timeToFix = timeToFix;           % Amount of time monkey is given to fixate.
        data(currTrial).trackedEye = trackedEye;         % which eye was tracked on the monkey.
        
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