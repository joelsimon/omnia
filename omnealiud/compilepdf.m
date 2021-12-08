function compilepdf(ifile, ofile, idir, odir, rmifile)
% COMPILEPDF(ifile, ofile, idir, odir, rmifile)
%
% Compiles multiple .pdfs into a single .pdf, and possibly removes the
% individual files included in the compilation.  Input filenames are specified
% using wildcards.  Requires system commands 'gs' and 'rm'.
%
% Input:
% ifile      Input .pdf filenames using Linux wildcards
%                (e.g., 'm??_residuals.pdf', or 'm12*residuals.pdf')
% ofile      Output filename
% idir       Directory where input files are kept (def: $PDF)
% odir       Directory where output files are sent (def: $PDF)
% rmifile    true to remove the individual input files (def: false)
%
% Ex: (ensure $PDF, a path to a directory, exists)
%    close all
%    for i = 1:10
%        plot(randi(100, 1, 100));
%        savepdf(sprintf('randi_%02i.pdf', i));
%        close
%    end
%    COMPILEPDF('randi_??.pdf', 'ex_compilepdf.pdf')
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 08-Dec-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
defval('idir', getenv('PDF'))
defval('odir', getenv('PDF'))
defval('rmifile', false)

% Append .pdf to filenames, if necessary.
if ~strcmp(suf(ifile), 'pdf')
    ifile = [ifile '.pdf'];

end
if ~strcmp(suf(ofile), 'pdf')
    ofile = [ofile '.pdf'];

end

% Append fullpath to filenames.
ifile = fullfile(idir, ifile);
ofile = fullfile(odir, ofile);

% Get a list of input files now, for possible deletion later, before writing the
% output file which may have the same wildcarded name and would thus be deleted.
ifile_dir = dir(ifile);
if isempty(ifile_dir)
    error('Not files matching pattern: %s', ifile)

end

% Write the compiled .pdf.
command = sprintf('gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=%s %s', ...
                  ofile, ifile);
status = system(command);
if status ~= 0
    error('Error: %s', command)

end

% Remove the individuals files, if requested.
if rmifile
    for i = 1:length(ifile_dir)
        % Do not use: `system(sprintf('rm %s', ifile))`
        % (would delete output if wildcards match)
        delete(fullfile(ifile_dir(i).folder, ifile_dir(i).name))

    end
end
