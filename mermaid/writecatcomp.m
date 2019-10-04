function ev = writecatcomp
% Writes text files useful for determining MERMAID catalog completeness.

stime = '2018-10-01T00:00:00.000';
etime = '2019-10-01T00:00:00.000';

minmag = 8;
maxmag = 9;

mags = [minmag : maxmag];

for i = 1:length(mags)
    ev = [];
    try
        ev = irisFetch.Events('minmag', mags(i), 'maxmag', mags(i) + 0.9, ...
                              'start', stime, 'end', etime);
    end

    id = {};
    if ~isempty(ev)
        for j = 1:length(ev)
            id{j} = fx(strsplit(ev(j).PublicId, '='),  2);
            
        end

    else
        id{1} = 'NaN';

    end
end
    end
