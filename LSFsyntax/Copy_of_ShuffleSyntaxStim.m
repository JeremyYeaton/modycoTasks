% (c) Jeremy D. Yeaton
% Created April 2019

% function ShuffleSyntaxStim(subID)
stim = readtable('stim\stimLSFsyntax.txt','Delimiter','\t');

nBlocks = 8;
shufIdx = Shuffle(1:height(stim));
shufStim = stim(shufIdx,:);
emptyTable = stim(1,:); emptyTable(1,:) = [];
% holding = stim;
stimuli = emptyTable;
minQ = 6;
maxCond = 3;
qVar = 1; condVar = maxCond + 1;

for block = 1:nBlocks
    if block < nBlocks
        newBlock = emptyTable;
        fams = [];
        for C = 1:3
            toPop = [];
            for qIdx = 1:height(shufStim)
                if strcmp(['C',num2str(C),'X'],char(shufStim.condID(qIdx))) == 1
                    if ismember(shufStim.family(qIdx),fams) == 0;
                        newBlock(height(newBlock)+1,:) = shufStim(qIdx,:);
                        toPop(end + 1) = qIdx;
                        fams(end + 1) = shufStim.family(qIdx);
                        break
                    end
                end
            end
            toPop = sort(toPop,'descend');
            for j = toPop
                shufStim(j,:) = [];
            end
            for iter = 1:6
                toPop = [];
                for q = 1:height(shufStim)
                    if strcmp(shufStim.condID(q),['C',num2str(C)]) && ~ismember(shufStim.family(q),fams)
                        newBlock(height(newBlock)+1,:) = shufStim(q,:);
                        toPop(end + 1) = q;
                        fams(end + 1) = shufStim.family(q);
                        break
                    end
                end
                toPop = sort(toPop,'descend');
                for j = toPop
                    shufStim(j,:) = [];
                end
            end
        end
        for q = 1:height(shufStim)
            if length(shufStim.condID(q)) < 3
                newBlock(height(newBlock)+1,:) = shufStim(q,:);
                shufStim(q,:) = [];
                break
            end
        end
    else
        newBlock = shufStim;
    end
    % Run checks to make sure questions qre not too close together and not
    % too many of the same condition appear in a row
    
    disp(['Shuffling block ', num2str(block)])
    while qVar < minQ  || condVar > maxCond
        blocShuf = Shuffle(1:height(newBlock));
        newBlockShuf = newBlock(blocShuf,:);
        if block > 1 && newBlockShuf.condition(1) == stimuli.condition(end)
            condVar = carryOver + 1;
        else
            condVar = 1;
        end
        for i = 1:height(newBlock)
            if i == 1 && length(newBlockShuf.condID{1}) == 3
                qVar = 0;
                break
            end
            if i > 1 && newBlockShuf.condition(i) == newBlockShuf.condition(i-1)
                condVar = condVar + 1;
                if condVar > maxCond
                    break
                end
            else
                condVar = 1;
            end
            if length(newBlockShuf.condID{i}) == 3
                if qVar < minQ && qVar > 0
                    qVar = 1;
                    break
                end
                qVar = 1;
            else
                qVar = qVar + 1;
            end
        end
    end
    stimuli = [stimuli; newBlockShuf];
    carryOver = condVar;
    carryQ = qVar;
    qVar = 1; condVar = maxCond + 1;    
end
% save(['stim\\shuffledStim_',num2str(subID),'.mat'],'stimuli')
% end
