% function ShuffleBILCHINStim(subID)
stim = readtable('stim\rawStimBILCHIN.txt','Delimiter','\t');

stimuli = stim;

save(['stim\\shuffledStim_',num2str(subID),'.mat'],'stimuli')

% end