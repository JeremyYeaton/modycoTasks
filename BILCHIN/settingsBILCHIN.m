%% Settings for change blindness experiment
% Change these to suit your experiment!

% Navigate to appropriate directory
expDir = 'C:\Users\AdminS2CH\Desktop\Experiments\modycoTasks\BILCHIN';
cd(expDir);

% Response keys (optional; for no subject response use empty list)
responseKeys = {'f','j','p'};

% Number of trials to show before a break (for no breaks, choose a number
% greater than the number of trials in your experiment)
breakAfterTrials = 60;

% Background color: choose a number from 0 (black) to 255 (white)
backgroundColor = 255;%[139 139 131];

% Text color: choose a number from 0 (black) to 255 (white)
textColor = 0;

% How long to wait (in seconds) for subject response before the trial times out
trialTimeout = 5;

% How long to pause in between trials (if 0, the experiment will wait for
% the subject to press a key before every trial)
timeBetweenTrials = .2;

stimDurationAud = 1;
stimDurationVis = 0.5;

repetitions = 1;

% Parallel / Trigger information
ioObj = io64;
status = io64(ioObj)
address = hex2dec('4FD8'); 
io64(ioObj,address,0); % set signal to 0

pauseText = 'Pause. Appuyez sur ESPACE pour continuer.';