function pdfout = savepdf(fname, figs, diro, transdpi)
% pdfout = SAVEPDF(fname, figs, diro, transdpi)
%
% Save(s) figure(s) as PDF(s).
%
% SAVEPDF requires:
%     [1] $PDF exists (as a path) and is known to MATLAB
%     [2] epstopdf exists on the system
%
% SAVEPDF appends a number to end the end of 'fname' for each figure
% if multiple figures are input
% 
% Input:
% fname          Name of PDF to be saved (def: 'test')
% figs           Array of figure handles (def: gcf)
% diro           Output directory to save file (def: $PDF)
% transdpi       DPI of output if transparency requested (def: [])*
%
% Output:
% pdfout         Output .pdf name
%
% * By default, the figure is assumed not to include transparent
% features. If it does, the user must supply a double, e.g. 300, to
% specify the dpi of the output. 
% 
% Ex1: (common usage -- just supply output filename)
%    figure
%    x = linspace(0, 2*pi, 1e3);
%    plot(x, sin(x));
%    pdfout = SAVEPDF('sin_wave')
%
% Ex2: (figure includes transparency, save in ~/savepdf_test/)
%    fig = figure; ax = gca;
%    x = normrnd(0, 1, 1e3, 1);
%    h1 = histogram(ax, x, 'BinWidth', 0.4);
%    hold(ax, 'on');
%    x = normrnd(1, 2, 1e3, 1);
%    h2 = histogram(ax, x, 40, 'BinWidth', 0.4);
%    pdfout = SAVEPDF('histograms', fig, '~/savepdf_test', 400)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 25-Feb-2019, Version 2017b

% Defaults
defval('fname', 'test')
defval('figs', gcf)
defval('transdpi', [])
defval('diro', getenv('PDF'))

% Sanity.
fname = strtrim(fname);
if any(isspace(fname))
    error('Invalid filename: ''%s'' contains a space.', fname)

end

% mkdir.m recognizes if a directory already exists.
[~, ~] = mkdir(diro)

for i = 1:length(figs)
    % Generate the output name and add counter index if multiple figures
    % input.
    outname = strippath(fname);
    if endsWith(outname, '.pdf', 'IgnoreCase', true)
        outname = outname(1:end-4);

    end
    
    if length(figs) > 1
        outname = [outname num2str(i)];    

    end

    % First save an eps to be converted to a pdf.
    epsout = fullfile(fullfile(diro), [outname '.eps']);

    % Use painters for higher quality if no transparency.
    if isempty(transdpi)
        print(figs(i), '-depsc', epsout, '-painters');        
        
    else
        print(figs(i), '-depsc', epsout, '-opengl', sprintf('-r%i', transdpi));        

    end

    % Use epstopdf (system command) to convert it to .pdf.
    stat = system(sprintf('epstopdf %s', epsout));
    if stat ~= 0
        error('Unable to convert ''%s.eps'' to a .pdf with epstopdf.', fname)

    end 

    % Return output .pdf file name.
    pdfout{i} = strrep(epsout, 'eps', 'pdf');

    % And then remove the .eps file.
    stat = system(sprintf('/bin/rm %s', epsout));
    if stat ~= 0
        error('Unable to rm ''%s.eps'' with /bin/rm.', fname)

    end
end


