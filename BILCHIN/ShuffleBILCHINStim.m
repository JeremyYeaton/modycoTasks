% Shuffle BILCHIN stimuli (relies on python script)
% (c) Jeremy D. Yeaton
% Created April 2019

function ShuffleBILCHINStim(subID,modality,reps)
% stimuli = readtable('stim\rawStimBILCHINtest.txt','Delimiter','\t');
system(['python stimShuffleBILCHIN.py ',num2str(subID)]);
stimuli = readtable(['stim\TrialOrderSub',num2str(subID),'.txt'],'Delimiter','\t');
stimuli.correctResponse = num2str(stimuli.correctResponse);

% if mod(subID,2) == 0
%     reps = {'f','j'};
% else
%     reps = {'j','f'};
% end
for i = 1:height(stimuli)
    if stimuli.correctResponse(i) == '0'
        stimuli.correctResponse(i) = reps{1};
    else
        stimuli.correctResponse(i) = reps{2};
    end
end

if mod(subID,4) < 2
    stimuli.prime = stimuli.colA;
    stimuli.target = stimuli.colB;
else
    stimuli.prime = stimuli.colB;
    stimuli.target = stimuli.colA;
end

save(['stim\\shuffledStim_',num2str(subID),'_',modality,'.mat'],'stimuli')

% Input correct responses for practice trials
stimuli = readtable('stim\practice.txt','Delimiter','\t');
stimuli.correctResponse = num2str(stimuli.correctResponse);
shufIdx = shuffle(1:height(stimuli));
stimuli = stimuli(shufIdx,:);

for i = 1:height(stimuli)
    if stimuli.correctResponse(i) == '0'
        stimuli.correctResponse(i) = reps{1};
    else
        stimuli.correctResponse(i) = reps{2};
    end
end
save('stim\\practice.mat','stimuli')
end
