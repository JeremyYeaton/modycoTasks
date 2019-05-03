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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up stimuli lists and results file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vids = {'consigne1','consigne 2'};
folder = 'C:\Users\AdminS2CH\Desktop\Experiments\modycoTasks\temp\videos\';

% Set up the output file
resultsFolder = 'results';
outputfile = fopen([resultsFolder '\resultfile_' num2str(subID) '.txt'],'a');
fprintf(outputfile, 'subID\t imageCondition\t trial\t textItem\t imageFile1\t imageFile2\t response\t RT\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Start screen
Screen('DrawText',window1,'Press the space bar to begin', (W/2-150), (H/2), textColor);
Screen('Flip',window1)
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
    vid = vids{Idx};
    moviename = [folder, vid, '.mp4'];
    if IsWin && ~IsOctave && psychusejava('jvm')
        fprintf('Running on Matlab for Microsoft Windows, with JVM enabled!\n');
        fprintf('This may crash. See ''help GStreamer'' for problem and workaround.\n');
        warning('Running on Matlab for Microsoft Windows, with JVM enabled!');
    end
    % Wait until user releases keys on keyboard:
    KbReleaseWait;
    try
        % Open movie file:
        movie = Screen('OpenMovie', window1, moviename);

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
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End the experiment (don't change anything in this section)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RestrictKeysForKbCheck([]);
fclose(outputfile);
Screen(window1,'Close');
close all
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
    barColor = 0.5; % number from 0 (black) to 1 (white) 
    Screen('FillRect', window, barColor,[ (W-barLength)/2 (H-barWidth)/2 (W+barLength)/2 (H+barWidth)/2]);
    Screen('FillRect', window, barColor ,[ (W-barWidth)/2 (H-barLength)/2 (W+barWidth)/2 (H+barLength)/2]);
end