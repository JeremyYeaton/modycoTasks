%% Settings for change blindness experiment
% Change these to suit your experiment!

% % Path to text file input (optional; for no text input set to 'none')
% % textFile = 'textfile.txt';
% textFile = 'none';

% Response keys (optional; for no subject response use empty list)
responseKeys = {'f','j','p'};
%responseKeys = {};

% Number of trials to show before a break (for no breaks, choose a number
% greater than the number of trials in your experiment)
breakAfterTrials = 4;

% Background color: choose a number from 0 (black) to 255 (white)
backgroundColor = 0;

% Text color: choose a number from 0 (black) to 255 (white)
textColor = 230;

% % Image format of the image files in this experiment (eg, jpg, gif, png, bmp)
% imageFormat = 'jpg';
% 
% % How long (in seconds) the image should appear on screen during flicker
% imageDuration = 1.000;

% % Duration (in seconds) of the blanks between the images during flicker
% blankDuration = 0.250;

% How long to wait (in seconds) for subject response before the trial times out
trialTimeout = 10;

% How long to pause in between trials (if 0, the experiment will wait for
% the subject to press a key before every trial)
timeBetweenTrials = 1;

fixationDuration = 1; % Length of fixation in seconds

% Response pictures
smR = imread(fullfile('C:\Users\AdminS2CH\Desktop\Experiments\modycoTasks\temp\media\smileyRouge.jpg'));
smV = imread(fullfile('C:\Users\AdminS2CH\Desktop\Experiments\modycoTasks\temp\media\smileyVert.jpg'));

% Parallel / Trigger information
ioObj = io64;
status = io64(ioObj)
address = hex2dec('4FD8'); 
io64(ioObj,address,0); % set signal to 0