% function ShuffleBILCHINStim(subID,modality)
stim = readtable('stim\rawStimBILCHINtest.txt','Delimiter','\t');

stimuli = stim;

if mod(subID,2) == 0
    reps = {'f','j'};
else
    reps = {'j','f'};
end

stimuli.correctResponse = num2str(stimuli.correctResponse);

for i = 1:height(stimuli)
    if stimuli.correctResponse(i) == '0'
        stimuli.correctResponse(i) = responses{1};
    else
        stimuli.correctResponse(i) = responses{2};
    end
end
save(['stim\\shuffledStim_',num2str(subID),'_',modality,'.mat'],'stimuli')
% end