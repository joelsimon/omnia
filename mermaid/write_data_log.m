function write_data_log(procdir)
% WRITE_DATA_LOG(procdir)
%
% Write <KSTNM>_data_log.txt, a two-column text file of start and end times
% for all SAC files present in each subdirectory of `procdir`.
%
% Input:
% procdir      Processed directory containing individual float sub-directories,
%                  as output by automaid (def: $MERMAID/processed)
%
% Output:      E.g., $MERMAID/processed/452.020-P-06/P0006_data_log.txt
%                    $MERMAID/processed/452.020-P-07/P0007_data_log.txt
%                    ...
%                    etc.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 24-Jan-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('procdir', fullfile(getenv('MERMAID'), 'processed'))
fmt = '%23sZ    %23sZ\n';

floatdir = fullfiledir(skipdotdir(dir(procdir)));
for i = 1:length(floatdir)
    sac = globglob(floatdir{i}, '**/*sac');
    if isempty(sac)
        continue

    end
    h = sachdr(sac{i});
    kstnm = h.KSTNM;
    fname = sprintf('%s_data_log.txt', kstnm);
    fid = fopen(fullfile(floatdir{i}, fname), 'w+');
    fprintf(fid, sprintf('%s:        start_time                    end_time\n', kstnm));
    for j = 1:length(sac)
        sd = sactime(sac{j});
        bstr = fdsndate2str(sd.B);
        estr = fdsndate2str(sd.E);
        fprintf(fid, fmt, bstr, estr);

    end
    fclose(fid);
    fprintf('Wrote: %s\n', fname)

end
