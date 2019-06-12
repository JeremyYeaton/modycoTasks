function runLSFsyntPrac
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up the experiment (don't modify this section)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

settingsLSFsyntax; % Load all the settings from the file
rand('state', sum(100*clock)); % Initialize the random number generator

% Keyboard setup
KbName('UnifyKeyNames');
KbCheckList = [KbName('ESCAPE')];
for i = 1:length(responseKeys)
    KbCheckList = [KbName(responseKeys{i}),KbCheckList];
end
RestrictKeysForKbCheck(KbCheckList);

% Screen setup
clear screen
whichScreen = 1;%max(Screen('Screens'));
[window1, rect] = Screen('Openwindow',whichScreen,backgroundColor,[],[],2);
slack = Screen('GetFlipInterval', window1)/2;
W=rect(RectRight); % screen width
H=rect(RectBottom); % screen height
Screen(window1,'FillRect',backgroundColor);
Screen('Flip', window1);

pauseText = 'Break time. Press space bar when you''re ready to continue';

qTrigVal = 251;
pauseVal = 255;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up stimuli lists and results file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vidFolder = [expDir,'\videos\'];

consignes = {'Consigne1-bonjour','Consigne 2','Consigne 3'};
c2Bis = imread(fullfile([expDir,'\videos\Consigne2bis.jpeg']));

% Read in stimuli
stimuli = readtable('stim\\stimLSFsyntaxPrac.txt','Delimiter','\t');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Start screen
Screen('DrawText',window1,'Appuyez sur le bouton vert pour commencer.', (W/2-250), (H/2), textColor);
Screen('Flip',window1)

smRDisplay   = Screen('MakeTexture', window1, smR);
smVDisplay   = Screen('MakeTexture', window1, smV);
c2BisDisplay = Screen('MakeTexture', window1, c2Bis);

% Wait for subject to press spacebar
waitForSpace

for C = 1:length(consignes)
    moviename = [vidFolder, consignes{C}, '.mp4'];
    % Wait until user releases keys on keyboard:
    KbReleaseWait;
    try
        % Open movie file:
        movie = Screen('OpenMovie', window1, moviename);
        frame = 0;

        % Start playback engine:
        Screen('PlayMovie', movie, 1);
        
        % Draw fixation cross; sync to video onset / trigger
        drawCross(window1,W,H);
        tFixation = Screen('Flip', window1);
%         Screen(window1, 'FillRect', backgroundColor);
        Screen('Flip', window1, tFixation + fixationDuration - slack,0);
        
        % Play first frame
        tex = Screen('GetMovieImage', window1, movie);
        Screen('DrawTexture', window1, tex);
        Screen('Flip', window1,tFixation + fixationDuration + slack,0);
        
        % Playback loop: Runs until end of movie or keypress:
        while ~KbCheck
            % Wait for next movie frame, retrieve texture handle to it
            tex = Screen('GetMovieImage', window1, movie);

            % Valid texture returned? A negative value means end of movie reached:
            if tex<=0
                % We're done, break out of loop:
                break;
            end

            % Draw the new texture immediately to screen:
            Screen('DrawTexture', window1, tex);
            
            % Update display:
            Screen('Flip', window1);
            % Release texture:
            Screen('Close', tex);
        end
        % Stop playback:
        Screen('PlayMovie', movie, 0);

        % Close movie:
        Screen('CloseMovie', movie);
    catch %#ok<CTCH>
        sca;
        psychrethrow(psychlasterror);
        clear io64;
    end
    Screen('DrawText',window1,'Appuyez sur le bouton vert pour continuer', (W/2-150), (H/2), textColor);
    Screen('Flip',window1);
    % Wait for subject to press spacebar
    waitForSpace
    if C == 2
        % Calculate image position
        imgDims = size(c2Bis);
        imageSize = [2*imgDims(1) 2*imgDims(2) 3];
        pos = [((W-imageSize(2))/2) ((H-imageSize(1))/2) ((W+imageSize(2))/2) ((H+imageSize(1))/2)];
        KbReleaseWait;
        Screen('DrawTexture', window1, c2BisDisplay, [], pos);
        Screen('DrawText',window1,'Appuyez sur le bouton vert pour continuer', (W/2-150), (H/4)*3, textColor);
        Screen('Flip',window1);
        % Wait for subject to press spacebar
        waitForSpace
    end
end
KbReleaseWait;
Screen('DrawText',window1,'Vous allez maintenant avoir un entrainement. Appuyez sur le bouton vert pour commencer.', (W/2-500), (H/2), textColor);
Screen('Flip',window1)
% Wait for subject to press spacebar
waitForSpace

% Practice trials
for Idx = 1:height(stimuli)
    moviename = [vidFolder, char(stimuli.fileID(Idx)), '.mp4'];
    % Wait until user releases keys on keyboard:
    KbReleaseWait;
    try
        % Open movie file:
        movie = Screen('OpenMovie', window1, moviename);
        frame = 0;
        dataOut = stimuli.condition(Idx) * 50; % Define trigger valu

        % Start playback engine:
        Screen('PlayMovie', movie, 1);
        
        % Draw fixation cross; sync to video onset / trigger
        drawCross(window1,W,H);
        tFixation = Screen('Flip', window1);
%         Screen(window1, 'FillRect', backgroundColor);
        Screen('Flip', window1, tFixation + fixationDuration - slack,0);
        
        % Play first frame
        tex = Screen('GetMovieImage', window1, movie);
        Screen('DrawTexture', window1, tex);
        Screen('Flip', window1,tFixation + fixationDuration + slack,0);
        io64(ioObj,address,dataOut); % send a signal
        
        % Playback loop: Runs until end of movie or keypress:
        while ~KbCheck
            % Wait for next movie frame, retrieve texture handle to it
            tex = Screen('GetMovieImage', window1, movie);

            % Valid texture returned? A negative value means end of movie reached:
            if tex<=0
                % We're done, break out of loop:
                break;
            end

            % Draw the new texture immediately to screen:
            Screen('DrawTexture', window1, tex);
            
            % Update display:
            Screen('Flip', window1);
            if frame < 12
                frame = frame + 1;
            elseif dataOut ~= 0
                io64(ioObj,address,0); % stop signal
            end
            % Release texture:
            Screen('Close', tex);
        end
        % Stop playback:
        Screen('PlayMovie', movie, 0);

        % Close movie:
        Screen('CloseMovie', movie);
    catch %#ok<CTCH>
        sca;
        psychrethrow(psychlasterror);
        clear io64;
    end
    io64(ioObj,address,0); % stop signal
    pauseCheck(pauseText,window1,W,H,textColor)
    if length(char(stimuli.qFile(Idx))) > 1
        % Calculate image position
        imageSize = [200 200 3];
        pos1 = [((W-imageSize(2))/2 - 300) ((H-imageSize(1))/2 + 400) ((W+imageSize(2))/2 - 300) ((H+imageSize(1))/2 + 400)];
        pos2 = [((W-imageSize(2))/2 + 300) ((H-imageSize(1))/2 + 400) ((W+imageSize(2))/2 + 300) ((H+imageSize(1))/2 + 400)];
        try
            % Open movie file
            qMovieName = [vidFolder, char(stimuli.qFile(Idx)), '.mp4'];
            movie = Screen('OpenMovie', window1, qMovieName);
            frame = 0;

            % Start playback engine:
            Screen('PlayMovie', movie, 1);

            % Draw fixation cross; sync to video onset / trigger
            drawCross(window1,W,H);
            tFixation = Screen('Flip', window1);
            Screen('Flip', window1, tFixation + fixationDuration - slack,0);
            io64(ioObj,address,qTrigVal); 
%             % Play first frame
%             tex = Screen('GetMovieImage', window1, movie);
%             Screen('DrawTexture', window1, tex);
%             Screen('Flip', window1,tFixation + fixationDuration + slack,0);

            % Playback loop: Runs until end of movie or keypress:
            while ~KbCheck
                % Wait for next movie frame, retrieve texture handle to it
                tex = Screen('GetMovieImage', window1, movie);

                % Valid texture returned? A negative value means end of movie reached:
                if tex<=0
                    % We're done, break out of loop:
                    break;
                end

                % Draw the new texture immediately to screen:
                Screen('DrawTexture', window1, smRDisplay, [], pos1);
                Screen('DrawTexture', window1, smVDisplay, [], pos2);
                Screen('DrawTexture', window1, tex);
                
                % Update display:
                Screen('Flip', window1);
                % Release texture:
                Screen('Close', tex);
            end
            % Stop playback:
            Screen('PlayMovie', movie, 0);
            io64(ioObj,address,0); 

            % Close movie:
            Screen('CloseMovie', movie);
        catch %#ok<CTCH>
            sca;
            psychrethrow(psychlasterror);
            clear io64;
        end
%         % Screen priority
%         Priority(MaxPriority(window1));
%         Priority(2);
        % Show the images
        rt = 0;
        resp = 0;
        Screen(window1, 'FillRect', backgroundColor);
        Screen('DrawTexture', window1, smRDisplay, [], pos1);
        Screen('DrawTexture', window1, smVDisplay, [], pos2);
        startTime = Screen('Flip', window1); % Start of trial
    %     Screen('DrawTexture', window1, blankDisplay, [], pos);

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
    end
    if mod(Idx,breakAfterTrials) == 0
        Screen('DrawText',window1,pauseText, (W/2-300), (H/2), textColor);
        Screen('Flip',window1)
        waitForSpace
    else
    % Pause between trials
        if timeBetweenTrials == 0
            waitForSpace
        else
            WaitSecs(timeBetweenTrials);
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End the experiment (don't change anything in this section)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RestrictKeysForKbCheck([]);
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
    barLength = 16; % in pixels
    barWidth = 2; % in pixels
    barColor = 255;%0.5; % number from 0 (black) to 1 (white) 
    Screen('FillRect', window, barColor,[ (W-barLength)/2 (H-barWidth)/2 (W+barLength)/2 (H+barWidth)/2]);
    Screen('FillRect', window, barColor ,[ (W-barWidth)/2 (H-barLength)/2 (W+barWidth)/2 (H+barLength)/2]);
end

function waitForSpace
    KbReleaseWait;
    while 1
        [~,~,keyCode] = KbCheck;
        if keyCode(KbName('j')) == 1
            break
        end
    end
end

function pauseCheck(messageText,window,W,H,textColor)
    [~,~,keyCode] = KbCheck;
    if keyCode(KbName('p'))==1
        Screen('DrawText',window,messageText, (W/2-300), (H/2), textColor);
        Screen('Flip',window)
        io64(ioObj,address,255); % send a signal
        pause(trigLen * (1/framePerSec));
        io64(ioObj,address,0); % send a signal
        waitForSpace
    end
end