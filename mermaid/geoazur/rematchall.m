close all
clear all

redo = false;

s = mermaid_sacf('id');

eidx = [];
midx = [];

diro = fullfile(getenv('MERMAID'), 'events', 'geoazur');

%Issue: i = 299; 'm31.20140629T173408.sac'
idx = [];
for i = 1:length(s);
    i
    try
        EQ = rematch(s{i}, diro, redo);

    catch
        idx = [idx i];
        continue

    end
    close all
    
end
