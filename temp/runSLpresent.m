function runSLpresent(subID)
%% PTB experiment template: Change blindness
%
% To run, call this function with the id code for your subject and the
% name of the folder that contains your stimuli, eg:
% runChangeBlindness('ke1','imagesB');
%
% See instructions file for more detailed instructions. 
%
% Krista Ehinger, December 2012

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up the experiment (don't modify this section)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

settingsSLpresent; % Load all the settings from the file
rand('state', sum(100*clock)); % Initialize the random number generator

% Keyboard setup
KbName('UnifyKeyNames');
KbCheckList = [KbName('space'),KbName('ESCAPE')];
for i = 1:length(responseKeys)
    KbCheckList = [KbName(responseKeys{i}),KbCheckList];
end
RestrictKeysForKbCheck(KbCheckList);

% Screen setup
clear screen
whichScreen = max(Screen('Screens'));
[window1, rect] = Screen('Openwindow',whichScreen,backgroundColor,[],[],2);
slack = Screen('GetFlipInterval', window1)/2;
W=rect(RectRight); % screen width
H=rect(RectBottom); % screen height
Screen(window1,'FillRect',backgroundColor);
Screen('Flip', window1);

file2 = 'MoDyCo'; % replace with question file later
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up stimuli lists and results file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% vids = {'consigne1','consigne 2'};
% vids = {'1C1','1C2','1C3'};
vids = {'1 C1','1 C2','1 C3','2C1','2C2','2C3'};
% vids = {'25 C1','25 C2','25 C3','26 C1'};
folder = 'C:\Users\AdminS2CH\Desktop\Experiments\modycoTasks\temp\videos\';

% Set up the output file
resultsFolder = 'results';
outputfile = fopen([resultsFolder '\resultfile_' num2str(subID) '.txt'],'a');
fprintf(outputfile, 'subID\t trial\t videoFile\t questionFile\t response\t RT\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
smR = imread(fullfile(folder,repPics{1}));
smV = imread(fullfile(folder,repPics{2}));

% Start screen
Screen('DrawText',window1,'Press the space bar to begin', (W/2-150), (H/2), textColor);
Screen('Flip',window1)

smRDisplay = Screen('MakeTexture', window1, smR);
smVDisplay = Screen('MakeTexture', window1, smV);
img3 = 127*ones([200 200 3]);
blankDisplay = Screen('MakeTexture', window1, img3);
% Wait for subject to press spacebar
while 1
    [keyIsDown,secs,keyCode] = KbCheck;
    if keyCode(KbName('space'))==1
        break
    end
end

for Idx = 1:length(vids)
    % Show fixation cross
    fixationDuration = 0.5; % Length of fixation in seconds
    drawCross(window1,W,H);
    tFixation = Screen('Flip', window1);
    
    % Blank screen
    Screen(window1, 'FillRect', backgroundColor);
    Screen('Flip', window1, tFixation + fixationDuration - slack,0);

    vid = vids{Idx};
    moviename = [folder, vid, '.mp4'];
%     if IsWin && ~IsOctave && psychusejava('jvm')
%         fprintf('Running on Matlab for Microsoft Windows, with JVM enabled!\n');
%         fprintf('This may crash. See ''help GStreamer'' for problem and workaround.\n');
%         warning('Running on Matlab for Microsoft Windows, with JVM enabled!');
%     end
    % Wait until user releases keys on keyboard:
    KbReleaseWait;
    try
        % Open movie file:
        movie = Screen('OpenMovie', window1, moviename);
        start = 0;
        dataOut = Idx + 100;

        % Start playback engine:
        Screen('PlayMovie', movie, 1);

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
            if start < 10
                io64(ioObj,address,dataOut); % send a signal
                start = start + 1;
            else
                io64(ioObj,address,0); % stop signal
            end
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
    % Calculate image position (center of the screen)
    imageSize = [200 200 3];%size(smR);
    pos1 = [((W-imageSize(2))/2 - 300) ((H-imageSize(1))/2 + 300) ((W+imageSize(2))/2 - 300) ((H+imageSize(1))/2 + 300)];
    pos2 = [((W-imageSize(2))/2 + 300) ((H-imageSize(1))/2 + 300) ((W+imageSize(2))/2 + 300) ((H+imageSize(1))/2 + 300)];

    % Screen priority
    Priority(MaxPriority(window1));
    Priority(2);
    % Show the images
    rt = 0;
    resp = 0;
    currentDisplay = 1;
    dur = imageDuration;
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
        end
        % Exit loop once a response is recorded
        if rt > 0
            break;
        end
    end
    % Save results to file
    fprintf(outputfile, '%s\t %d\t %s\t %s\t %s\t %f\n',...
        subID, Idx, vid, file2, resp, rt);
    % Determine whether to take a break
    if mod(Idx,breakAfterTrials) == 0
        Screen('DrawText',window1,'Break time. Press space bar when you''re ready to continue', (W/2-300), (H/2), textColor);
        Screen('Flip',window1)
        % Wait for subject to press spacebar
        while 1
            [keyIsDown,secs,keyCode] = KbCheck;
            if keyCode(KbName('space')) == 1
                break
            end
        end
    else
    % Pause between trials
        if timeBetweenTrials == 0
            while 1 % Wait for space
                [keyIsDown,secs,keyCode] = KbCheck;
                if keyCode(KbName('space'))==1
                    break
                end
            end
        else
            WaitSecs(timeBetweenTrials);
        end
    end
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
    barLength = 16; % in pixels
    barWidth = 2; % in pixels
    barColor = 255;%0.5; % number from 0 (black) to 1 (white) 
    Screen('FillRect', window, barColor,[ (W-barLength)/2 (H-barWidth)/2 (W+barLength)/2 (H+barWidth)/2]);
    Screen('FillRect', window, barColor ,[ (W-barWidth)/2 (H-barLength)/2 (W+barWidth)/2 (H+barLength)/2]);
end