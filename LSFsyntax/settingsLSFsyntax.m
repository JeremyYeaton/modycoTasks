%% Settings for LSF Syntax task
% (c) Jeremy D. Yeaton
% Created April 2019

% Change these to suit your experiment!

% Navigate to appropriate directory
expDir = 'C:\Users\AdminS2CH\Desktop\Experiments\modycoTasks\LSFsyntax';
cd(expDir);

% Response keys (optional; for no subject response use empty list)
responseKeys = {'f','j','p'};
%responseKeys = {};

% Number of trials to show before a break (for no breaks, choose a number
% greater than the number of trials in your experiment)
breakAfterTrials = 22;

% Background color: choose a number from 0 (black) to 255 (white)
backgroundColor = [139 139 131];

% Text color: choose a number from 0 (black) to 255 (white)
textColor = 0;

% How long to wait (in seconds) for subject response before the trial times out
trialTimeout = 10;

% How long to pause in between trials (if 0, the experiment will wait for
% the subject to press a key before every trial)
timeBetweenTrials = 1;

fixationDuration = 1; % Length of fixation in seconds

% Response pictures
smR = imread(fullfile([expDir,'\media\smileyRouge.jpg']));
smV = imread(fullfile([expDir,'\media\smileyVert.jpg']));

% Parallel / Trigger information
ioObj = io64;
status = io64(ioObj)
address = hex2dec('4FD8'); 
io64(ioObj,address,0); % set signal to 0

% Video settings
framePerSec = 25;
trigLen = 12; % in frames
trigLenS = trigLen * (1 / framePerSec); % in seconds

pauseText = 'Pause. Appuyez sur le bouton vert pour continuer.';
