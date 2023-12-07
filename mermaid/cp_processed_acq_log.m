function cp_processed_acq_log(proc_dir, cp_dir)
% CP_PROCESSED_ACQ_LOG(proc_dir, cp_dir)
%
% Copies <proc_dir>/452.020-P-06/acq_log.txt to <cp_dir>/452.020-P-06_acq_log.txt
%
% Ex:
%    CP_PROCESSED_ACQ_LOG('~/mermaid/processed/452*', '~/mermaid/everyone/acq_log/')`
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 06-Dec-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

d = fullfiledir(dir(proc_dir));
for i = 1:length(d)
    acq_file = fullfile(d{i}, 'acq_log.txt');
    cp_file = fullfile(cp_dir, sprintf('%s_acq_log.txt', strippath(d{i})));
    system(sprintf('cp %s %s', acq_file, cp_file));

end
