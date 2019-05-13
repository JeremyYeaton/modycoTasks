function ShufflePhonSemStim(subID)
stim = readtable('stim\stimLSFphonsem.txt','Delimiter','\t');

% Set parameters and variables
nBlocks = 5;
iPerBlock = 24;
minQ = 6;
maxCond = 3;
qVar = 1; condVar = maxCond + 1;
nCond = 5;

% Initialize holding tables for questions and items
emptyTable = stim(1,:); emptyTable(1,:) = [];
holding = emptyTable;
stimuli = emptyTable;
qTable = emptyTable;

% Create initial randomized list of stimuli
shufIdx = Shuffle(1:height(stim));
shufStim = stim(shufIdx,:);

% Pull out questions and even numbers of items across the 3 conditions
toPop = [];
for j = 1:height(shufStim)
    if strcmp(shufStim.question{j},'X')
        qTable(height(qTable) + 1,:) = shufStim(j,:);
        toPop(end + 1) = j;
    end
end
toPop = sort(toPop,'descend');
for k = toPop
    shufStim(k,:) = [];
end

for i = 1:nBlocks
    C = 1;
    for iter = 1:3
        toPop = [];
        for j = 1:height(shufStim)
            if shufStim.condition(j) == C
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
    for C = 2:nCond
        for iter = 1:6
            toPop = [];
            for j = 1:height(shufStim)
                if shufStim.condition(j) == C
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
    end
end
%%%%
for block = 1:nBlocks
    newBlock = emptyTable;
    fams = [];
    % Add questions to block
    for iter = 1:3
        toPop = [];
        for qIdx = 1:height(qTable)
            if ismember(qTable.family(qIdx),fams) == 0;
                newBlock(height(newBlock)+1,:) = qTable(qIdx,:);
                toPop(end + 1) = qIdx;
                fams(end + 1) = qTable.family(qIdx);
                break
            end
        end
        toPop = sort(toPop,'descend');
        for k = toPop
            qTable(k,:) = [];
        end
    end
    % Add 2 more items from condition 1
    C = 1;
    for iter = 1:2
        toPop = [];
        for q = 1:height(holding)
            if holding.condition(q) == C
                if ismember(holding.family(q),fams) == 0;
                    newBlock(height(newBlock)+1,:) = holding(q,:);
                    toPop(end + 1) = q;
                    fams(end + 1) = holding.family(q);
                    break
                end
            end
        end
        toPop = sort(toPop,'descend');
        for k = toPop
            holding(k,:) = [];
        end
    end
    % Add 5 items from conditions 2-5
    for C = 2:nCond
        for iter = 1:5
            toPop = [];
            for q = 1:height(holding)
                if holding.condition(q) == C
                    if ismember(holding.family(q),fams) == 0;
                        newBlock(height(newBlock)+1,:) = holding(q,:);
                        toPop(end + 1) = q;
                        fams(end + 1) = holding.family(q);
                        break
                    end
                end
            end
            toPop = sort(toPop,'descend');
            for k = toPop
                holding(k,:) = [];
            end
        end
    end
    % Run checks to make sure questions are not too close together and not
    % too many of the same condition appear in a row
    
    disp(['Shuffling block ', num2str(block)])
    while qVar < minQ  || condVar > maxCond
        blocShuf = Shuffle(1:height(newBlock));
        newBlockShuf = newBlock(blocShuf,:);
        if block == 1
            for iter = 1:2
                if strcmp(newBlockShuf.question{iter},'X')
                    break
                end
            end
        end        
        if block > 1 && newBlockShuf.condition(1) == stimuli.condition(end)
            condVar = carryOver + 1;
        else
            condVar = 1;
        end
        for i = 1:height(newBlock)
            if i == 1 && ~strcmp(newBlockShuf.question{i},'X')
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
            if strcmp(newBlockShuf.question{i},'X')
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
end
save(['stim\\shuffledStim_',num2str(subID),'.mat'],'stimuli')
end