function hunga_alignxcorrsac
% HUNGA_ALIGNXCORRSAC
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 01-Mar-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

%% Paths

hundir = getenv('HUNGA');
sacdir = fullfile(hundir, 'sac');
staticdir = fullfile(hundir, 'code', 'static');

sac = globglob(sacdir, '*.sac');
sac = rmbadsac(sac);
sac = onlyfilledsac(sac);
sac = rmgapsac(sac);

lohi = [5 10];
env_len_secs = 30;
env_type = 'peak';
xcorr_scale = 'coeff';
plotit = true;

%% Output maxcorr (for adjacency matrix) text file (...just save .mat?)

fname = fullfile(staticdir,'hunga_alignxcorrsac.txt');
fmt = '%5s    %5s    %+10.3e\n';
writeaccess('unlock', fname, false);
fid = fopen(fname, 'w');

%% Loop over all SAC and compare (correlate) all stations against one another

% % Could do this (all unique combinations); fill e.g. half of symmetric
% % matrix, and copy with `tril`, but that is more work than it is worth for me
% % to figure out at this point...
% % S = nchoosek(sac, 2);
% % for i = 1:length(S)
% %     [h1, h2, delay, maxcorr, xat1, xat2, F] = ...
% %         alignxcorrsac_local(S{i,1}, S{i,2}, lohi, env_len_secs, env_type, xcorr_scale, plotit);
% % end

len_sac = length(sac);
mc = NaN(len_sac);
for i = 1:len_sac;
    for j = 1:len_sac;
        [h1, h2, delay, maxcorr, xat1, xat2, F, F3] = ...
            alignxcorrsac_local(sac{i}, sac{j}, lohi, env_len_secs, env_type, xcorr_scale, plotit);
        mc(i, j) = maxcorr;

        if plotit
            savepdf(sprintf('%s_%s', h1.KSTNM, h2.KSTNM), F3);
            close all

        end
        %fprintf(fid, fmt, h1.KSTNM, h2.KSTNM, maxcorr);

    end
    % Save floats' serial number for M x N adjacency-matrix indexing
    % NB, loops are identical so M x N (ij) indexes are just M x M (ii),
    % hence we only need to keep track of outside loop (i) indexing
    kstnm{i} = h1.KSTNM;

end
fclose(fid)
writeaccess('lock', fname);
save(fullfile(staticdir, 'hunga_alignxcorrsac.mat'), 'mc', 'kstnm');

function [h1, h2, delay, maxcorr, xat1, xat2, F, F3] = alignxcorrsac_local(s1, s2, lohi, env_len_secs, env_type, xcorr_scale, plotit)
%
% Input:
%
% Output:
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 10-Feb-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

% Corner frequences for transfer function.
mt_freq_lo = [1/10 1/5 5 9.9];
mt_freq_hi = 2 * mt_freq_lo;

[x1, h1] = mermaidtransfer(s1, mt_freq_hi);
[x2, h2] = mermaidtransfer(s2, mt_freq_hi);

gap1 = readgap(s1);
gap2 = readgap(s2);

[xb1, xe1, xe1_mean] = filtfunc(x1, h1, gap1, lohi, env_len_secs, env_type);
[xb2, xe2, xe2_mean] = filtfunc(x2, h2, gap2, lohi, env_len_secs, env_type);

start1 = seistime(h1);
start1 = start1.B;

start2 = seistime(h2);
start2 = start2.B;


%% Flip sign of envelope, for plotting
xe2 = -xe2;

[delay, maxcorr, xat1, xat2, daxt1, daxt2, dax1, dax2, xat1_pt0, xat2_pt0, F] = ...
    alignxcorrutc(xe1, start1, h1.DELTA, xe2, start2, h2.DELTA, plotit, xcorr_scale);


%% Flip sign of correlation, because we fed the algorithm it flipped-sign envelopes
maxcorr = -maxcorr

%% Left off here..
xd_corr = xdist(xat1, -xat2, 0);

if plotit
    F(1).ax1.Title.String = sprintf('%s: %s and %s', F(1).ax1.Title.String, ...
                                    h1.KSTNM, h2.KSTNM);

    F(2).ax1.Title.String = sprintf('%s: %s and %s', F(2).ax1.Title.String, ...
                                    h1.KSTNM, h2.KSTNM);

    ax = [F(2).ax1 F(2).ax2 F(2).ax3];
    for i = 1:length(ax)
        axis(ax(i), 'tight')
        symaxes(ax(i), 'y');

    end

    %% ___________________________________________________________________________ %%
    if h1.DELTA ~= h2.DELTA
        error('expected same sampling freq')

    end

    F3 = figure;
    ax = gca;
    box(ax, 'on')
    hold(ax, 'on')
    shrink(ax, 1, 2);
    xax = xaxis(length(xat1), h1.DELTA, 0)/60;
    %% Add mean back to demeaned windows to get proper scaling
    plot(ax, xax, xat1+xe1_mean, 'r', 'LineWidth', 1);
    plot(ax, xax, xat2-xe2_mean, 'k', 'LineWidth', 1);
    xlabel(ax, 'Time (min)');
    ylabel(ax, '30-s Window Amplitude (Pa)')
    legend(ax, h1.KSTNM, h2.KSTNM, 'NorthEast')
    textpatch(ax, 'SouthEast', sprintf('xcorr: %6.2f%s\nxdist: %6.2f%s', ...
                                       maxcorr*100, '%', xd_corr*100, '%'))
    xlim(ax, [0 xax(end)])
    symaxes(ax, 'y')
    latimes
    longticks(ax, 2)
    hold(ax, 'off')

    %% ___________________________________________________________________________ %%
end


% % Overlay un/normalized bandpassed trace.
% hold(F(2).ax1, 'on')
% F(2).ax1.Legend.AutoUpdate = 'off';
% % plot(F(2).ax1, daxt1, norm2max(xb1(xat1_pt0+1:xat1_pt0+length(xat1))), 'r')
% % plot(F(2).ax1, daxt2, norm2max(xb2(xat2_pt0+1:xat2_pt0+length(xat2))), 'k')
% plot(F(2).ax1, daxt1, xb1(xat1_pt0+1:xat1_pt0+length(xat1)), 'r')
% plot(F(2).ax1, daxt2, xb2(xat2_pt0+1:xat2_pt0+length(xat2)), 'k')


function [xb, xe, xe_mean] = filtfunc(x, h, gap, lohi, env_len_secs, env_type)

x = detrend(x, 'constant');
x = detrend(x, 'linear');
x = x .* tukeywin(length(x), 0.1);
xb = bandpass(x, efes(h), lohi(1), lohi(2), 4, 1);
xb = fillgap(xb, gap, 0);
env_len_samp = env_len_secs * efes(h);
xe = envelope(xb, env_len_samp, env_type);
xe_mean = mean(xe);
xe = xe - xe_mean;
