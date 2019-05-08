d = fullfile(getenv('MERMAID'), 'processed', '452.020-P-20');

s = dir(fullfile(d, '**/*sac'));

for i = 1:length(s)
    [x, h] = readsac(fullfile(s(i).folder, s(i).name));
    plot(x)
    pause

end
    
    

