% Practice trials for LSF PhonSem task
% (c) Jeremy D. Yeaton
% Created April 2019

function runLSFphonsemPrac
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up the experiment (don't modify this section)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

settingsLSFphonsem; % Load all the settings from the file

% Keyboard setup
KbName('UnifyKeyNames');
KbCheckList = [KbName('ESCAPE')]; % all space keypresses replaced with 'j'
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
Priority(MaxPriority(window1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up stimuli lists and results file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vidFolder = [expDir,'\videos\'];

% Create shuffled stimuli list
% ShufflePhonSemStim(subID);
% 
% % Read in stimuli
% load(['stim\\shuffledStim_',num2str(subID),'.mat'],'stimuli')

% % Set up the output file
% resultsFolder = 'results';
% outputfile = fopen([resultsFolder '\resultfile_' num2str(subID) '.txt'],'a');
% fprintf(outputfile, 'subID\t trial\t videoFile\t questionFile1\t questionFile2\t response\t RT\n');


vidFolder = [expDir,'\videos\'];

consignes = {'Consignes\\instructions'};


% Read in stimuli
stimuli = readtable('stim\\stimLSFphonsemPrac.txt','Delimiter','\t');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Start screen
Screen(window1, 'FillRect', darkBlue);
Screen('DrawText',window1,'Appuyez sur le bouton vert pour commencer.', (W/2-150), (H/2), textColor);
Screen('Flip',window1);

drawCross(window1,W,H);
Screen(window1, 'FillRect', darkBlue);

% Wait for subject to press spacebar
waitForSpace(ioObj,address)

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
    waitForSpace(ioObj,address)
end
KbReleaseWait;

Screen('DrawText',window1,'Vous allez maintenant avoir un entrainement. Appuyez sur le bouton vert pour commencer.', (W/2-500), (H/2), textColor);
Screen('Flip',window1);
% Wait for subject to press spacebar
waitForSpace(ioObj,address)

for Idx = 1:height(stimuli)
    disp(['Trial ',num2str(Idx),': ',num2str(stimuli.condition(Idx)),stimuli.question{Idx}])
    moviename = [vidFolder, char(stimuli.fileID(Idx)), '.mp4'];
    % Wait until user releases keys on keyboard:
    KbReleaseWait;
    try
        % Open movie file:
        movie = Screen('OpenMovie', window1, moviename);
%         frame = 0;
        dataOut = stimuli.condition(Idx) * 5; % Define onset trigger value
%         trigVal = stimuli.condition(Idx) * 50; % Define trigger value at sign
%         trigTime = round(stimuli.trigTimes(Idx) * framePerSec);

        % Start playback engine:
        Screen('PlayMovie', movie, 1);
        
        % Draw fixation cross; sync to video onset / trigger
        Screen(window1, 'FillRect', darkBlue);
        drawCross(window1,W,H);
        tFixation = Screen('Flip', window1);
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
%             if frame < trigLen
% %                 io64(ioObj,address,dataOut); % send a signal
%                 frame = frame + 1;
%             elseif frame >= trigTime && frame < trigTime + trigLen
%                 io64(ioObj,address,trigVal); % send a signal
%                 frame = frame + 1;
%             elseif dataOut ~= 0
%                 io64(ioObj,address,0); % stop signal
%                 frame = frame + 1;
%             end
            % Release texture:
            Screen('Close', tex);
        end
        io64(ioObj,address,0); % stop signal
        % Stop playback:
        Screen('PlayMovie', movie, 0);

        % Close movie:
        Screen('CloseMovie', movie);
    catch %#ok<CTCH>
        sca;
        psychrethrow(psychlasterror);
        clear io64;
    end
    pauseCheck(pauseText,window1,W,H,textColor,trigLenS,ioObj,address)
    rt = 0;
    resp = 0;
    if length(char(stimuli.qFile1(Idx))) > 1
        % Calculate image position
        vidSize = [405 720 3];
        wOff = 360;
        imageSize = [200 200 3];
        pos1 = [((W-vidSize(2))/2 - wOff) ((H-vidSize(1))/2) ((W+vidSize(2))/2 - wOff) ((H+vidSize(1))/2)];
        pos2 = [((W-vidSize(2))/2 + wOff) ((H-vidSize(1))/2) ((W+vidSize(2))/2 + wOff) ((H+vidSize(1))/2)];
        pos3 = [((W-imageSize(2))/2 - 300) ((H-imageSize(1))/2 + 400) ((W+imageSize(2))/2 - 300) ((H+imageSize(1))/2 + 400)];
        pos4 = [((W-imageSize(2))/2 + 300) ((H-imageSize(1))/2 + 400) ((W+imageSize(2))/2 + 300) ((H+imageSize(1))/2 + 400)];
        try
            % Open movie file
            qMovie1Name = [vidFolder,'\\qFolder\\',char(stimuli.qFile1(Idx)), '.mp4'];
            qMovie2Name = [vidFolder,'\\qFolder\\',char(stimuli.qFile2(Idx)), '.mp4'];
            movie1 = Screen('OpenMovie', window1, qMovie1Name);
            movie2 = Screen('OpenMovie', window1, qMovie2Name);
            frame = 0;

            % Start playback engine:
            Screen('PlayMovie', movie1, 1);
            Screen('PlayMovie', movie2, 1);

            % Draw fixation cross; sync to video onset / trigger
            Screen(window1, 'FillRect', darkBlue);
            drawCross(window1,W,H);
            tFixation = Screen('Flip', window1);
            Screen('Flip', window1, tFixation + fixationDuration - slack,0);

            % Playback loop: Runs until end of movie or keypress:
           
            while ~KbCheck
                % Wait for next movie frame, retrieve texture handle to it
                tex(1) = Screen('GetMovieImage', window1, movie1);
                tex(2) = Screen('GetMovieImage', window1, movie2);

                % Valid texture returned? A negative value means end of movie reached:
                if tex(1)<=0 || tex(2)<=0
                    % We're done, break out of loop:
                    break;
                end

                % Draw the new texture immediately to screen:
%                 Screen('DrawTexture', window1, smRDisplay, [], pos1);
%                 Screen('DrawTexture', window1, smVDisplay, [], pos2);
                Screen('FillOval',window1,[178,34,34],pos3);
                Screen('FillOval',window1,[0,128,0],pos4);
                Screen('DrawTexture', window1, tex(1),[],pos1);
                Screen('DrawTexture', window1, tex(2),[],pos2);
%                 Screen('Flip', window1);
%                 Screen('FillOval',window1,[0 0 127],[200 200 200 200]);
%                 Screen('FillOval',window1,[127],[200 200 200 200]);
%                 Screen('DrawTexture', window1, tex(3),[],pos3);
%                 Screen('DrawTexture', window1, tex(4),[],pos4);
                
                % Update display:
                startTime = Screen('Flip', window1);
                
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

%         % Screen priority
%         Priority(MaxPriority(window1));
%         Priority(2);
        % Show the images
        
        Screen(window1, 'FillRect', darkBlue);
        Screen('FillOval',window1,[178,34,34],pos3);
        Screen('FillOval',window1,[0,128,0],pos4);
        startTime = Screen('Flip', window1); % Start of trial
        if strcmp(stimuli.repCorr{Idx},stimuli.qFile1{Idx})
            repCorr = 'f';
        else
            repCorr = 'j';
        end

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
                        if strcmp(stimuli.qFile1{Idx},stimuli.repCorr{Idx})
                            qRep = 'f';
                        else
                            qRep = 'j';
                        end
                        if strcmp(KbName(pressedKeys(1)),qRep)
                            repSignal = 200;
                        else
                            repSignal = 1;
                        end
                        io64(ioObj,address,repSignal);
%                         if strcmp(KbName(pressedKeys(1)),stimuli.repCorr(Idx))
%                             repSignal = 200;
%                         else
%                             repSignal = 1;
%                         end
%                         io64(ioObj,address,repSignal);
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
    % Save results to file
%     fprintf(outputfile, '%s\t %d\t %s\t %s\t %s\t %s\t %f\n',...
%         subID, Idx, char(stimuli.fileID(Idx)), char(stimuli.qFile1(Idx)),char(stimuli.qFile2(Idx)), resp, rt);
    % Determine whether to take a break
    if mod(Idx,breakAfterTrials) == 0
        KbReleaseWait;
        try
            % Open movie file:
            moviename = [vidFolder, '\\Consignes\\53-repos.mp4'];
            movie = Screen('OpenMovie', window1, moviename);
            dataOut = 255; % Define onset trigger value
            % Start playback engine:
            Screen('PlayMovie', movie, 1);

            % Draw fixation cross; sync to video onset / trigger
            Screen(window1, 'FillRect', darkBlue);
            drawCross(window1,W,H);
            tFixation = Screen('Flip', window1);
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
                % Release texture:
                Screen('Close', tex);
            end
            io64(ioObj,address,0); % stop signal
            % Stop playback:
            Screen('PlayMovie', movie, 0);

            % Close movie:
            Screen('CloseMovie', movie);
        catch %#ok<CTCH>
            sca;
            psychrethrow(psychlasterror);
            clear io64;
        end
        Screen('DrawText',window1,pauseText, (W/2-300), (H/2), textColor);
        Screen('Flip',window1);
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
    pauseCheck(pauseText,window1,W,H,textColor,trigLenS,ioObj,address)
    io64(ioObj,address,0);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End the experiment (don't change anything in this section)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RestrictKeysForKbCheck([]);
% fclose(outputfile);
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

function waitForSpace(ioObj,address)
    while 1
        [keyIsDown,secs,keyCode] = KbCheck;
        if keyCode(KbName('j')) == 1
            io64(ioObj,address,0);
            KbReleaseWait;
            break
        end
    end
end

function pauseCheck(messageText,window,W,H,textColor,trigLenS,ioObj,address)
    [keyIsDown,secs,keyCode] = KbCheck;
    if keyCode(KbName('p'))==1
        Screen('DrawText',window,messageText, (W/2-300), (H/2), textColor);
        Screen('Flip',window)
        io64(ioObj,address,255); % send a signal
        pause(trigLenS);
        io64(ioObj,address,0); % send a signal
        waitForSpace(ioObj,address)
    end
end
