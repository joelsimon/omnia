function compilepdf(ifile, ofile, idir, odir, rmifile)
% COMPILEPDF(ifile, ofile, idir, odir, rmifile)
%
% Compiles multiple .pdfs into a single .pdf, and possibly removes the
% individual files included in the compilation.  Input filenames are
% specified using wildcards.  Assumes user has Linux commands 'gs' and
% 'rm'.
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
%    COMPILEPDF('randi_??.pdf', 'ex_compilepdf.pdf') % Check $PDF.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 30-Jul-2019, Version 2017b

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

% Write the compiled .pdf.
status = system(sprintf(['gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite ' ...
                    '-sOutputFile=%s %s'], ofile, ifile));
if status ~= 0
    error('Error compiling .pdf: check paths and wildcards')

end

% Remove the individuals files, if requested.
if rmifile
    system(sprintf('rm %s', ifile));

end
