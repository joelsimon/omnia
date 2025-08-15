function compare_slopes()

close all

hundir = getenv('HUNGA');
sacdir = fullfile(hundir, 'sac');
imsdir = fullfile(sacdir, 'ims');
imssac = globglob(imsdir, '*sac.pa');
staticdir = fullfile(hundir, 'code', 'static');

sac = globglob(sacdir, '*.sac');
imssac = ordersac_geo(imssac, 'gcarc');

sac = [sac ; imssac];

sac = rmbadsac(sac);
sac = rmgapsac(sac);

gc = hunga_read_great_circle_gebco;

axes
xlim([0 600])
hold on
for i = 1:length(sac)
    [~, h] = readsac(sac{i});
    s{i} = h.KSTNM
    g{i} = gc.(s{i}).gebco_elev;
    d{i} = gc.(s{i}).cum_distkm;
    plot(d{i}, g{i})
    pause
    
end


legend(s)