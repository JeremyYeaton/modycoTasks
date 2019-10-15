function runBILCHINaud(subID)
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
whichScreen     = 1;%max(Screen('Screens'));%1;%
[window1, rect] = Screen('Openwindow',whichScreen,backgroundColor,[],[],2);
slack           = Screen('GetFlipInterval', window1)/2;
W               = rect(RectRight); % screen width
H               = rect(RectBottom); % screen height
Screen(window1,'FillRect',backgroundColor);
Screen('Flip', window1);
Priority(MaxPriority(window1));

% Audio setup
device = [];
InitializePsychSound;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up stimuli lists and results file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create shuffled stimuli list
if mod(subID,2) == 0
    reps = {'f','j'};
else
    reps = {'j','f'};
end
ShuffleBILCHINStim(subID,'aud',reps)

% Read in stimuli
load(['stim\\shuffledStim_',num2str(subID),'_aud.mat'],'stimuli')
taskStim = stimuli;

% Initialize fixation duration vectors
fixationDuration = .5 + (.75-.5).*rand(height(stimuli),2);

% Set up the output file
resultsFolder = 'results';
outputfile = fopen([resultsFolder '\resultfile_' num2str(subID) '.txt'],'a');
fprintf(outputfile, 'subID\t trial\t prime\t target\t response\t ACC \t RT\n');

% Trigger constant for auditory modality
modVal = 100;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Start screen
DrawFormattedText(window1,'Appuyez sur ESPACE pour commencer.', 'center','center', textColor);
% Screen('DrawText',window1,'Appuyez sur ESPACE pour commencer.', (W/2-200), (H/2), textColor);
Screen('Flip',window1);
Screen('TextSize', window1,76);
% Wait for subject to press spacebar
waitForSpace(ioObj,address)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Instructions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('TextSize', window1,48);
DrawFormattedText(window1,['S''il y a un lien sémantique entre les deux mots, appuyez sur "',reps{2},'".\n\n',...
'S''il n''y a pas de lien sémantique entre les deux mots, appuyez sur "',reps{1},'".\n\n\n',...
'Appuyez sur la barre ESPACE pour essayer.'], 'center','center', textColor);
Screen('Flip',window1);
% Wait for subject to press spacebar
waitForSpace(ioObj,address)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Practice
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('stim\\practice.mat','stimuli')

for Idx = 1:height(stimuli)
    disp(['Trial ',num2str(Idx),': ',stimuli.prime{Idx},'-',stimuli.target{Idx},' (',num2str(stimuli.condition(Idx)),')'])
    % Wait until user releases keys on keyboard:
    KbReleaseWait;
    % Cross 500
    drawCross(window1,W,H);
    tFixation = Screen('Flip', window1);
    % Present prime 1000 ms
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Read WAV file from filesystem:
    wavfilename = [expDir,'\\stim\\wav\\',stimuli.prime{Idx},'.wav'];
    [y, freq] = psychwavread(wavfilename);
    wavedata = y';
    nrchannels = size(wavedata,1); % Number of rows == number of channels.
    if nrchannels < 2
        wavedata = [wavedata ; wavedata];
        nrchannels = 2;
    end
    % Initialize audio player
    pahandle = PsychPortAudio('Open', device, [], 0, freq, nrchannels);
    % Fill the audio playback buffer with the audio data 'wavedata':
    PsychPortAudio('FillBuffer', pahandle, wavedata);
    % Display fixation cross for ~500 ms
    drawCross(window1,W,H);
    tFixation = Screen('Flip', window1,tFixation + fixationDuration(Idx,1) - slack,0);
    PsychPortAudio('Start', pahandle, repetitions, 0, 1); % Begin audio
    io64(ioObj,address,(modVal + stimuli.condition(Idx)*10 + primeVal)) % Send trigger
    % Blank screen
    Screen(window1, 'FillRect', backgroundColor);
    tBlank = Screen('Flip', window1, tFixation + stimDurationAud - slack,0);
    % Stop playback:
    PsychPortAudio('DeleteBuffer');
    io64(ioObj,address,0)
    PsychPortAudio('Stop', pahandle);
    % Target
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Read WAV file from filesystem:
    wavfilename = [expDir,'\\stim\\wav\\',stimuli.target{Idx},'.wav'];
    [y, freq] = psychwavread(wavfilename);
    wavedata = y';
    nrchannels = size(wavedata,1); % Number of rows == number of channels.
    if nrchannels < 2
        wavedata = [wavedata ; wavedata];
        nrchannels = 2;
    end
    % Fill the audio playback buffer with the audio data 'wavedata':
    PsychPortAudio('FillBuffer', pahandle, wavedata);
    % Display fixation cross for ~500 ms
    drawCross(window1,W,H);
    startTime = Screen('Flip', window1,tBlank + fixationDuration(Idx,2) - slack,0);
    PsychPortAudio('Start', pahandle, repetitions, 0, 1); % Start audio
    io64(ioObj,address,(modVal + stimuli.condition(Idx)*10 + trgtVal)) % Send trigger
    rt = 0;
    resp = 0;
    %%%% WORK ON THIS PART -- break on keypress/ don't show question mark%%%%
    while ~KbCheck && GetSecs - startTime < stimDurationAud
        PsychPortAudio('GetStatus', pahandle);
    end
    [~,~,keyCode] = KbCheck;
    if isempty(find(keyCode, 1))
        Screen('Flip', window1,startTime + stimDurationAud - slack,0);
        DrawFormattedText(window1,'?', 'center','center', textColor);
        Screen('Flip', window1);
        [~,~,keyCode] = KbCheck;
    end
    % Stop playback:
    PsychPortAudio('Stop', pahandle);
    io64(ioObj,address,0)
    PsychPortAudio('DeleteBuffer');
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
        ACC = 0;
        if ~isempty(pressedKeys)
            for i = 1:length(responseKeys)
                if KbName(responseKeys{i}) == pressedKeys(1)
                    resp = responseKeys{i};
                    rt = respTime - startTime;
                    ACC = strcmp(KbName(pressedKeys(1)),stimuli.correctResponse(Idx));
                end
            end
             % Blank screen
            Screen(window1, 'FillRect', backgroundColor);
            Screen('Flip', window1);
        end
        if ACC
            repSignal = correct;
        else
            repSignal = incorrect;
        end
        io64(ioObj,address,repSignal);
       
        % Exit loop once a response is recorded
        if rt > 0
            break;
        end
    end
    % Pause between trials
    if timeBetweenTrials == 0
        waitForSpace(ioObj,address)
    else
        WaitSecs(timeBetweenTrials);
    end
    pauseCheck(pauseText,window1,textColor,ioObj,address)
    PsychPortAudio('DeleteBuffer');
    PsychPortAudio('Close', pahandle);
    io64(ioObj,address,0);
end

%% Send off to the real task
Screen('TextSize', window1,48); % Make the font big
DrawFormattedText(window1,'Appuyez sur ESPACE pour commencer.', 'center','center', textColor);
Screen('Flip',window1);
% Wait for subject to press spacebar
waitForSpace(ioObj,address)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Real task
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stimuli = taskStim;

for Idx = 1:height(stimuli)
    disp(['Trial ',num2str(Idx),': ',stimuli.prime{Idx},'-',stimuli.target{Idx},' (',num2str(stimuli.condition(Idx)),')'])
    % Wait until user releases keys on keyboard:
    KbReleaseWait;
    % Cross 500
    drawCross(window1,W,H);
    
    tFixation = Screen('Flip', window1);
    % Present prime 1000 ms
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Read WAV file from filesystem:
    wavfilename = [expDir,'\\stim\\wav\\',stimuli.prime{Idx},'.wav'];
    [y, freq] = psychwavread(wavfilename);
    wavedata = y';
    nrchannels = size(wavedata,1); % Number of rows == number of channels.
    if nrchannels < 2
        wavedata = [wavedata ; wavedata];
        nrchannels = 2;
    end
    % Initialize audio player
    pahandle = PsychPortAudio('Open', device, [], 0, freq, nrchannels);
    % Fill the audio playback buffer with the audio data 'wavedata':
    PsychPortAudio('FillBuffer', pahandle, wavedata);
    % Display fixation cross for ~500 ms
    drawCross(window1,W,H);
    io64(ioObj,address,0)
    tFixation = Screen('Flip', window1,tFixation + fixationDuration(Idx,1) - slack,0);
    PsychPortAudio('Start', pahandle, repetitions, 0, 1); % Begin audio
    io64(ioObj,address,(modVal + stimuli.condition(Idx)*10 + primeVal)) % Send trigger
    % Blank screen
    Screen(window1, 'FillRect', backgroundColor);
    tBlank = Screen('Flip', window1, tFixation + stimDurationAud - slack,0);
    % Stop playback:
    PsychPortAudio('Stop', pahandle);
    io64(ioObj,address,0)
    PsychPortAudio('DeleteBuffer');
    % Target
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Read WAV file from filesystem:
    wavfilename = [expDir,'\\stim\\wav\\',stimuli.target{Idx},'.wav'];
    [y, freq] = psychwavread(wavfilename);
    wavedata = y';
    nrchannels = size(wavedata,1); % Number of rows == number of channels.
    if nrchannels < 2
        wavedata = [wavedata ; wavedata];
        nrchannels = 2;
    end
    % Fill the audio playback buffer with the audio data 'wavedata':
    PsychPortAudio('FillBuffer', pahandle, wavedata);
    % Display fixation cross for ~500 ms
    drawCross(window1,W,H);
    startTime = Screen('Flip', window1,tBlank + fixationDuration(Idx,2) - slack,0);
    PsychPortAudio('Start', pahandle, repetitions, 0, 1); % Start audio
    io64(ioObj,address,(modVal + stimuli.condition(Idx)*10 + trgtVal)) % Send trigger
    rt = 0;
    resp = 0;
    %%%% WORK ON THIS PART -- break on keypress/ don't show question mark%%%%
    while ~KbCheck && GetSecs - startTime < stimDurationAud
        PsychPortAudio('GetStatus', pahandle);
    end
    io64(ioObj,address,0)
    [~,~,keyCode] = KbCheck;
    if isempty(find(keyCode, 1))
%         Screen('Flip', window1,startTime + stimDurationVis - slack,0);
        DrawFormattedText(window1,'?', 'center','center', textColor);
        Screen('Flip', window1,startTime + stimDurationVis - slack,0);
%         Screen('Flip', window1);
        [~,~,keyCode] = KbCheck;
    end
    % Stop playback:
    PsychPortAudio('Stop', pahandle);
    io64(ioObj,address,0)
    PsychPortAudio('DeleteBuffer');
    % Get keypress response
    ACC = 0;
    while GetSecs - startTime < trialTimeout
        % Uncomment if statements
        %if isempty(find(keyCode, 1))
            [~,~,keyCode] = KbCheck;
        %end
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

        % Check for response keys/ assess accuracy (ACC)
        if ~isempty(pressedKeys)
            for i = 1:length(responseKeys)
                if KbName(responseKeys{i}) == pressedKeys(1)
                    resp = responseKeys{i};
                    rt = respTime - startTime;
                    ACC = strcmp(KbName(pressedKeys(1)),stimuli.correctResponse(Idx));
                end
            end
             % Blank screen
            Screen(window1, 'FillRect', backgroundColor);
            Screen('Flip', window1);
        end
        if ACC
            repSignal = correct;
        else
            repSignal = incorrect;
        end
        io64(ioObj,address,repSignal);
        % Exit loop once a response is recorded
        if rt > 0
            break;
        end
    end
    pauseCheck(pauseText,window1,textColor,ioObj,address)
    % Save results to file
    fprintf(outputfile, '%s\t %d\t %s\t %s\t %s\t %f\t %f\n',...
        num2str(subID), Idx, stimuli.prime{Idx}, stimuli.target{Idx}, resp, ACC, rt);
    % Determine whether to take a break
    if mod(Idx,breakAfterTrials) == 0
        KbReleaseWait;
        DrawFormattedText(window1,pauseText, 'center','center', textColor);
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
    PsychPortAudio('Close', pahandle);
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
