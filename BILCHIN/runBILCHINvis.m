function runBILCHINvis(subID)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up the experiment (don't modify this section)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

settingsBILCHIN; % Load all the settings from the file
rand('state', sum(100*clock)); % Initialize the random number generator

% Keyboard setup
KbName('UnifyKeyNames');
KbCheckList = [KbName('ESCAPE'),KbName('SPACE')]; 
for i = 1:length(responseKeys)
    KbCheckList = [KbName(responseKeys{i}),KbCheckList];
end
RestrictKeysForKbCheck(KbCheckList);

% Screen setup
clear screen
whichScreen     = max(Screen('Screens'));%1;%
[window1, rect] = Screen('Openwindow',whichScreen,backgroundColor,[],[],2);
slack           = Screen('GetFlipInterval', window1)/2;
W               = rect(RectRight); % screen width
H               = rect(RectBottom); % screen height
Screen(window1,'FillRect',backgroundColor);
Screen('Flip', window1);
Priority(MaxPriority(window1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up stimuli lists and results file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create shuffled stimuli list
% ShuffleBILCHINStim(subID,'vis')

% Read in stimuli
% load(['stim\\shuffledStim_',num2str(subID),'_vis.mat'],'stimuli')
load(['stim\\shuffledStim_',num2str(subID),'.mat'],'stimuli')

fixationDuration = .5 + (.75-.5).*rand(height(stimuli),2);

% Set up the output file
resultsFolder = 'results';
outputfile = fopen([resultsFolder '\resultfile_' num2str(subID) '.txt'],'a');
fprintf(outputfile, 'subID\t trial\t prime\t target\t response\t RT\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Start screen
DrawFormattedText(window1,'Appuyez sur ESPACE pour commencer.', 'center','center', textColor);
Screen('Flip',window1);
Screen('TextSize', window1,76);
% Wait for subject to press spacebar
waitForSpace(ioObj,address)

for Idx = 1:height(stimuli)
%     disp(['Trial ',num2str(Idx),': ',stimuli.prime(Idx,'-',stimuli.target(Idx)])
    % Wait until user releases keys on keyboard:
    KbReleaseWait;
    % Cross 500
    drawCross(window1,W,H);
    tFixation = Screen('Flip', window1);
    Screen('Flip', window1, tFixation + fixationDuration(Idx,1) - slack,0);
    % Blank 200
    Screen(window1, 'FillRect', backgroundColor);
    tBlank = Screen('Flip', window1);
    Screen('Flip', window1,tBlank + .2 - slack,0);
    % Present prime 500
    DrawFormattedText(window1,stimuli.prime{Idx}, 'center','center', textColor);
    word = Screen('Flip', window1);
    Screen('Flip', window1,word + .5 - slack,0);
    % Blank 600
    Screen(window1, 'FillRect', backgroundColor);
    tBlank = Screen('Flip', window1,tBlank + fixationDuration(Idx,1) - slack,0);
    % Target 500
    DrawFormattedText(window1,stimuli.target{Idx}, 'center','center', textColor);
    startTime = Screen('Flip', window1,tBlank + fixationDuration(Idx,2) - slack,0);
    rt = 0;
    resp = 0;
    while ~KbCheck && GetSecs - startTime < stimDurationVis
        PsychPortAudio('GetStatus', pahandle);
    end
    respToBeMade = true;
     while respToBeMade
        [keyIsDown,secs, keyCode] = KbCheck;
        if isempty(find(keyCode, 1))
            Screen('Flip', window1,startTime + .5 - slack,0);
            DrawFormattedText(window1,'?', 'center','center', textColor);
            Screen('Flip', window1);
        end
    
    % Response
    % Get keypress response
    while GetSecs - startTime < trialTimeout
        [keyIsDown,secs,keyCode] = KbCheck;
        respTime = GetSecs;
        pressedKeys = find(keyCode);

        % ESC key quits the experiment
        if keyCode(KbName('ESCAPE')) == 1
            clear all
            close all
            clear io64;
            sca
            return;
        end

        % Check for response keys
        if ~isempty(pressedKeys)
            for i = 1:length(responseKeys)
                if KbName(responseKeys{i}) == pressedKeys(1)
                    resp = responseKeys{i};
                    rt = respTime - startTime;
%                     if strcmp(KbName(pressedKeys(1)),stimuli.repCorr(Idx))
%                         repSignal = 200;
%                     else
%                         repSignal = 1;
%                     end
%                     io64(ioObj,address,repSignal);
                end
            end
            drawCross(window1,W,H);
            Screen('Flip', window1);
        end
        % Exit loop once a response is recorded
        if rt > 0
            break;
        end
    end

    % Save results to file
    fprintf(outputfile, '%s\t %d\t %s\t %s\t %s\t %f\n',...
        num2str(subID), Idx, stimuli.prime{Idx}, stimuli.target{Idx}, resp, rt);
    % Determine whether to take a break
    if mod(Idx,breakAfterTrials) == 0
        KbReleaseWait;
        Screen('DrawText',window1,pauseText, (W/2-300), (H/2), textColor);
        Screen('Flip',window1)
        % Wait for subject to press spacebar
        waitForSpace(ioObj,address)
    else
    % Pause between trials
        if timeBetweenTrials == 0
            waitForSpace(ioObj,address)
        else
            WaitSecs(timeBetweenTrials);
        end
    end
%     pauseCheck(pauseText,window1,W,H,textColor,trigLenS,ioObj,address)
    io64(ioObj,address,0);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End the experiment (don't change anything in this section)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RestrictKeysForKbCheck([]);
fclose(outputfile);
Screen(window1,'Close');
close all
clear io64;
sca;
return

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Subfunctions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Draw a fixation cross (overlapping horizontal and vertical bar)
function drawCross(window,W,H)
    barLength = 36; % in pixels
    barWidth = 8; % in pixels
    barColor = 0;%0.5; % number from 0 (black) to 1 (white) 
    Screen('FillRect', window, barColor,[ (W-barLength)/2 (H-barWidth)/2 (W+barLength)/2 (H+barWidth)/2]);
    Screen('FillRect', window, barColor ,[ (W-barWidth)/2 (H-barLength)/2 (W+barWidth)/2 (H+barLength)/2]);
end

function waitForSpace(ioObj,address)
    while 1
        [keyIsDown,secs,keyCode] = KbCheck;
        if keyCode(KbName('SPACE')) == 1
            io64(ioObj,address,0);
            KbReleaseWait;
            break
        end
    end
end

function pauseCheck(messageText,window,W,H,textColor,ioObj,address)
    [keyIsDown,secs,keyCode] = KbCheck;
    if keyCode(KbName('p'))==1
        Screen('DrawText',window,messageText, (W/2-300), (H/2), textColor);
        Screen('Flip',window)
        io64(ioObj,address,255); % send a signal
        pause(.5);
        io64(ioObj,address,0); % send a signal
        waitForSpace(ioObj,address)
    end
end