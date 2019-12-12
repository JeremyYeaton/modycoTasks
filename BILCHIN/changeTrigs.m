evt = EEG.event;
evtBackup = evt;
trigs = [];
trial = 0;
repCorr = [200 201 202 222 232];

targVals = [15 25 35 45];

res = readtable('resTRans/1027.txt');

order = 'AV';
modVals = [2 1];
% if strcmp(order,'VA')
%     modVals = [2 1];
% elseif strcmp(order,'AV')
%     modVals = [1 2];
% end

% modLim = 550; % 1013
% modLim = 554;% 1004,1005
% modLim = 555;% 1012
modLim = 0; % 1006, 1002
% modLim = 745;% 1003
% modLim = 712;% 1011
% modLim = 724;% 1009
% modLim = 725; % 1010
% modLim = 710;% 1007
%% First modality

for Idx = modLim:-1:2
    if evt(Idx-1).type/5 == evt(Idx).type/10 && trial < 180
        cond = evt(Idx-1).type/5;
        trial = trial + 1;
        % Target
        evt(Idx).type = 100*modVals(1) + 10*cond + 5;
        % Prime
        evt(Idx -1).type = 100*modVals(1) + 10*cond;
    end
end

for Idx = 1:modLim
    if evt(Idx).type == 1 || evt(Idx).type == 11
        evt(Idx).type = 10;
    elseif ismember(evt(Idx).type,repCorr)
        evt(Idx).type = 55;
    end

end

% for Idx = 1:modLim
%     if ~ismember(evt(Idx).type,trigs)
%         trigs(end+1) = evt(Idx).type;
%         Idx
%     end
% end
trial = 0;
targTrigs = targVals+(100*modVals(1));
for Idx = 1:modLim
    if ismember(evt(Idx).type,targTrigs)
        trial = trial + 1;
        if ~((evt(Idx+1).type == 55 && res.res01(trial) == 1) || (evt(Idx+1).type == 10 && res.res01(trial) == 0))
            disp(['Panic! ' num2str(trial) ' ' num2str(Idx)])
        end
    end
end
% trigs
evt2 = evt;

%% Second modality
for Idx = length(evt)-1:-1:modLim+2
    if (evt(Idx).type == 1 || evt(Idx).type >= 200) && (evt(Idx+1).type == 1 || evt(Idx+1).type >= 200)
        evt(Idx) = [];
    end
end
%
trial = 0;
targ = 1;
for Idx = length(evt):-1:modLim+1
    if trial < 180 && ~(evt(Idx).type == 1 || evt(Idx).type >= 200)
        cond = res.conditionNb(180+(180-trial));
        repCorr = res.res01(180+(180-trial));
        if targ > 0 % target
            evt(Idx).type = 100*modVals(2) + 10*cond + 5;
%             evt(Idx+2:end+1) = evt(Idx+1:end);
            if repCorr == 1
                evt(Idx+1).type = 55;
            else
                evt(Idx+1).type = 10;
            end
        elseif targ < 0 % prime
            evt(Idx).type = 100*modVals(2) + 10*cond;
            trial = trial + 1;
        end
        targ = -targ;
    end
end
%%
EEG.event = evt;
%% Second modality (if AV, do first)
% evt = evtBackup;
home
trial = 180;
for Idx = length(evt):-1:modLim+2
    if evt(Idx-1).type/5 == evt(Idx).type/10 && trial < 360
        cond = evt(Idx-1).type/5;
        trial = trial + 1;
        % Target
        evt(Idx).type = 100*modVals(1) + 10*cond + 5;
        % Prime
        evt(Idx -1).type = 100*modVals(1) + 10*cond;
    end
end

for Idx = modLim+1:length(evt)
    if evt(Idx).type == 1 || evt(Idx).type == 11
        evt(Idx).type = 10;
    elseif ismember(evt(Idx).type,repCorr)
        evt(Idx).type = 55;
    end
end

trial = 180;
targTrigs = targVals+(100*modVals(1));
% evt(1231).type = 55; 1011
% evt(914).type = 55;% 1010
% evt(1109).type = 55;% 1010
evt(1127).type = 10;% 1007
for Idx = modLim+1:length(evt)
    if ismember(evt(Idx).type,targTrigs)
        trial = trial + 1;
        if ~((evt(Idx+1).type == 55 && res.res01(trial) == 1) || (evt(Idx+1).type == 10 && res.res01(trial) == 0))
            disp(['Panic! ' num2str(trial) ' ' num2str(Idx)])
        end
    end
end

% First modality (if AV do second)
for Idx = modLim:-1:2
    if (evt(Idx).type == 1 || evt(Idx).type >= 200) && (evt(Idx+1).type == 1 || evt(Idx+1).type >= 200)
        evt(Idx) = [];
    end
end
% modLim = 554;% 1011
% modLim = 555;% 1007
% modLim = 556;% 1010
% modLim = 557;% 1009
trial = 0;
targ = 1;
for Idx = modLim:-1:1
    if trial < 180 && ~(evt(Idx).type == 1 || evt(Idx).type >= 200)
        cond = res.conditionNb(180-trial);
        repCorr = res.res01(180-trial);
        if targ > 0 % target
            evt(Idx).type = 100*modVals(2) + 10*cond + 5;
%             evt(Idx+2:end+1) = evt(Idx+1:end);
            if repCorr == 1
                evt(Idx+1).type = 55;
            else
                evt(Idx+1).type = 10;
            end
        elseif targ < 0 % prime
            evt(Idx).type = 100*modVals(2) + 10*cond;
            trial = trial + 1;
        end
        targ = -targ;
    end
end


%%
EEG.event = evt;
%% When combining datasets
EEG.urevent = EEG.event;

%% for 1003 (VA)
%% Second modality (if AV, do first)
home
trial = 180;
for Idx = length(evt):-1:modLim+2
    if evt(Idx-1).type/5 == evt(Idx).type/10 && trial < 360
        cond = evt(Idx-1).type/5;
        trial = trial + 1;
        % Target
        evt(Idx).type = 100*modVals(1) + 10*cond + 5;
        % Prime
        evt(Idx -1).type = 100*modVals(1) + 10*cond;
    end
end

for Idx = modLim+1:length(evt)
    if evt(Idx).type == 1 || evt(Idx).type == 11
        evt(Idx).type = 10;
    elseif ismember(evt(Idx).type,repCorr)
        evt(Idx).type = 55;
    end
end

trial = 180;
targTrigs = targVals+(100*modVals(1));
% evt(1231).type = 55; 1011
% evt(914).type = 55;% 1010
% evt(1109).type = 55;% 1010
evt(1127).type = 10;% 1007
for Idx = modLim+1:length(evt)
    if ismember(evt(Idx).type,targTrigs)
        trial = trial + 1;
        if ~((evt(Idx+1).type == 55 && res.res01(trial) == 1) || (evt(Idx+1).type == 10 && res.res01(trial) == 0))
            disp(['Panic! ' num2str(trial) ' ' num2str(Idx)])
        end
    end
end

% First modality (if AV do second)
for Idx = modLim:-1:2
    if (evt(Idx).type == 1 || evt(Idx).type >= 200) && (evt(Idx+1).type == 1 || evt(Idx+1).type >= 200)
        evt(Idx) = [];
    end
end
% modLim = 554;% 1011
modLim = 555;% 1007
% modLim = 556;% 1010
% modLim = 557;% 1009
trial = 0;
targ = 1;
for Idx = modLim:-1:1
    if trial < 180 && ~(evt(Idx).type == 1 || evt(Idx).type >= 200)
        cond = res.conditionNb(180-trial);
        repCorr = res.res01(180-trial);
        if targ > 0 % target
            evt(Idx).type = 100*modVals(2) + 10*cond + 5;
%             evt(Idx+2:end+1) = evt(Idx+1:end);
            if repCorr == 1
                evt(Idx+1).type = 55;
            else
                evt(Idx+1).type = 10;
            end
        elseif targ < 0 % prime
            evt(Idx).type = 100*modVals(2) + 10*cond;
            trial = trial + 1;
        end
        targ = -targ;
    end
end

%%
ts = [];
for Idx = 2:length(EEG.event)
    ts(Idx) = EEG.event(Idx).latency - EEG.event(Idx-1).latency;
    ts(Idx) = ts(Idx)/512;
    if ts(Idx) < 6
        ts(Idx) = 0;
    end
end
a = find(ts)
b = ts(a)
%%
for Idx = modLim+1:length(evt)
    if evt(Idx).type == 1 || evt(Idx).type == 11
        evt(Idx).type = 10;
    elseif ismember(evt(Idx).type,repCorr)
        evt(Idx).type = 55;
    end
end

for Idx = modLim+1:length(evt)
    if ~ismember(evt(Idx).type,trigs)
        trigs(end+1) = evt(Idx).type;
        Idx
    end
end
trial = 180;
targTrigs = targVals+(100*modVals(2));
for Idx = 1:modLim
    if ismember(evt(Idx).type,targTrigs)
        trial = trial + 1;
        if ~((evt(Idx+1).type == 55 && res.Acc(trial) == 1) || (evt(Idx+1).type == 10 && res.Acc(trial) == 0))
            disp('Panic!')
            trial
        end
    end
end
trigs


%%
EEG.event = evt;