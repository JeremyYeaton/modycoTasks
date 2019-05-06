stim = readtable('stim\stimLSFsyntax.txt','Delimiter','\t');

nBlocks = 8;
iPerBlock = 22;
shufIdx = Shuffle(1:height(stim));
shufStim = stim(shufIdx,:);
emptyTable = stim(1,:); emptyTable(1,:) = [];
holding = emptyTable;
newStim = emptyTable;

questions = {'C1X','C2X','C3X'};
qTable = emptyTable;

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
%%

for block = 1:nBlocks
    newBlock = emptyTable;
    for C = 1:3
        n = 6;
        for q = 1:height(questions)
            if strcmp(questions{q},['C',num2str(C),'X']) == 1
                newBlock(height(newBlock+1),:) = questions(q,:);
                break
            end
        end
        for q = 1:height(holding)
            if strcmp(questions{q},['C',num2str(C)]) == 1
                newBlock(height(newBlock+1),:) = holding(q,:);
                break
            end
        end
    end
end

%%
npq = stim;
height(npq)
npq(1,:) = [];
height(npq)