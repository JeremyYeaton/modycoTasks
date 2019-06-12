% function ShuffleBILCHINStim(subID)
stim = readtable('stim\stimLSFsyntax.txt','Delimiter','\t');

nBlocks = 3;
iPerBlock = 60;
shufIdx = Shuffle(1:height(stim));
shufStim = stim(shufIdx,:);
emptyTable = stim(1,:); emptyTable(1,:) = [];
holding = emptyTable;
stimuli = emptyTable;
maxCond = 3;
qVar = 1; condVar = maxCond + 1;

qTable = emptyTable;
% Pull out questions and even numbers of items across the 3 conditions
for i = 1:nBlocks
    for C = 1:3
        for iter = 1:6
            toPop = [];
            for j = 1:height(shufStim)
                if strcmp(char(shufStim.condID(j)),['C',num2str(C)]) == 1
                    holding(height(holding) + 1,:) = shufStim(j,:);
                    toPop(end + 1) = j;
                    break
                end
            end
            toPop = sort(toPop,'descend');
            for k = toPop
                shufStim(k,:) = [];
            end
        end
        toPop = [];
        for j = 1:height(shufStim)
            if strcmp(char(shufStim.condID(j)),['C',num2str(C),'X']) == 1
                qTable(height(qTable) + 1,:) = shufStim(j,:);
                toPop(end + 1) = j;
            end
        end
        toPop = sort(toPop,'descend');
        for k = toPop
            shufStim(k,:) = [];
        end
    end
end

for block = 1:nBlocks
    newBlock = emptyTable;
    fams = [];
    for C = 1:3
        toPop = [];
        for qIdx = 1:height(qTable)
            if strcmp(['C',num2str(C),'X'],char(qTable.condID(qIdx))) == 1
                if ismember(qTable.family(qIdx),fams) == 0;
                    newBlock(height(newBlock)+1,:) = qTable(qIdx,:);
                    toPop(end + 1) = qIdx;
                    fams(end + 1) = qTable.family(qIdx);
                    break
                end
            end
        end
        toPop = sort(toPop,'descend');
        for k = toPop
            qTable(k,:) = [];
        end
        toPop = [];
        for n = 1:6
            for q = 1:height(holding)
                if strcmp(holding.condID(q),['C',num2str(C)]) == 1
                    if ismember(holding.family(q),fams) == 0;
                        newBlock(height(newBlock)+1,:) = holding(q,:);
                        toPop(end + 1) = q;
                        fams(end + 1) = holding.family(q);
                        holding(q,:) = [];
                        break
                    end
                end
            end
        end
    end
    newBlock(height(newBlock)+1,:) = shufStim(1,:);
    shufStim(1,:) = [];
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
save(['stim\\shuffledStim_',num2str(subID),'.mat'],'stimuli')
% end