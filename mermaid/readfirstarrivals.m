function readfirstarrivals(filename)

defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'firstarrivals.txt'))
% Data format.
fmt = ['%44s    ' , ...
       '%5s    '  , ...
       '%6.2f    ', ...
       '%6.2f    ', ...
       '%5.2f    ', ...
       '%9.1f    ' , ...
       '%d\n'];

fid = fopen(filename, 'r');
lynes = textscan(fid, fmt);
fclose(fid);

s = lynes{1};
ph = lynes{2};
tres = lynes{3};
delay = lynes{4};
twosd = lynes{5};
SNR = lynes{6};
maxc_y = lynes{7};

idx = find(~isnan(tres));


keyboard
scatter(dist(idx), mag(idx), tres(idx));
keyboard


tres(abs(tres(idx)) <= 6)