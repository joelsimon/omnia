function makewc(tipe)
% MAKEWC(tipe)
%
% Makes and saves data base with wavelet coefficients
%
% INPUT:
% 
% tipe     1 for the Daubechies case
%          2 for the Cohen-Daubechies-Feauveau case
%          3 for the Cohen-Daubechies-Feauveau case with integer scaling 
%
% For Daubechies' ORTHOGONAL set only store H0
% as F0 will be its flipped version. (See WC).
%
% For Cohen-Daubechies BIORTHOGONAL set will store
% both H0 and F0. (See PRODCO).
%
% Last modified by fjsimons-at-alum.mit.edu, 11/03/2010

defval('tipe',0)

switch tipe
  case 1
   for index=1:45
     [H0,H1,F0,F1]=wfilters(sprintf('db%i',index));
     eval(['Daubechies.p',sprintf('%i',index),'=H0;']);
     % Put in some choice lifters also
   end
   save(fullfile(getenv('IFILES'),'WAVELETS','Daubechies'),'Daubechies')
 case 2
    CDFnames=[{'bior1.1'} {'bior1.3' } {'bior1.5'} ...
	      {'bior2.2'} {'bior2.4' } {'bior2.6'} {'bior2.8'} ...
	      {'bior3.1'} {'bior3.3' } {'bior3.5'} {'bior3.7'} {'bior3.9'} ...
	      {'bior4.4'} { 'bior5.5'} { 'bior6.8'}];
    for index=1:length(CDFnames)
      % Watch out: they insert zeros
      % There are no zero-coefficient filters!
      [H0,H1,F0,F1]=wfilters(sprintf(CDFnames{index}));
      H0=H0(~~H0);
      F0=F0(~~F0);
      N=pref(suf(CDFnames{index},'r'),'.');
      M=suf(suf(CDFnames{index},'r'),'.');
      eval(['CDF.H0{',N,',',M,'}=H0;']);
      eval(['CDF.F0{',N,',',M,'}=F0;']);
    end
    % Put in the cubic B-spline as well
    CDF.H0{4,2}=[3 -12 5 40 5 -12 3]/32;
    CDF.F0{4,2}=[1 4 6 4 1]/8;
    % Here's what I have: (1,1) (1,3) (2,2) (2,4) (4,2)
    % Put in the whole lot of lifting operators
    % One vanishing moment of primal wavelet       
    CDF.P {1}=1;
    CDF.Kp{1}=2/sqrt(2);
    %-------------------------------------------
    CDF.U {1,1}=[1/2];
    CDF.Ku{1,1}=1/sqrt(2);
    CDF.U {1,3}=[1 8 -1]/16;
    CDF.Ku{1,3}=1/sqrt(2);
    
    % Two vanishing moments of primal wavelet
    CDF.P {2}=[1 1]/2;
    CDF.Kp{2}=2/sqrt(2);
    %-------------------------------------------
    CDF.U {2,2}=[1 1]/4;
    CDF.Ku{2,2}=1/sqrt(2);
    CDF.U {2,4}=[-3 19 19 -3]/64;
    CDF.Ku{2,4}=1/sqrt(2);
    
    % Four vanishing moments of primal wavelet
    % Need two lifting steps
    CDF.P {4}=[{[0 0]} {[1 1]}];
    CDF.Kp{4}=2;
    %-------------------------------------------
    CDF.U {4,2}=[{[-1 -1]/4} {[3 3]/16}];
    CDF.Ku{4,2}=-1/2;
    
    save(fullfile(getenv('IFILES'),'WAVELETS','CDF'),'CDF')
 case 3
    % This is the case where the scaling factors have been broken into
    % lifting steps in case you want to do an integer-to-integer
    % transform, see Daubechies and Sweldens, 1998, Delft Book page 145.
    CDFI.P{2}=[{[1 1]/2} {-1} {1/sqrt(2)}];
    CDFI.Kp{2}=1;
    %-------------------------------------------
    CDFI.U{2,4}=[{[-3 19 19 -3]/64} {sqrt(2)-1} {sqrt(2)-2}];
    CDFI.Ku{2,4}=1;
    
    save(fullfile(getenv('IFILES'),'WAVELETS','CDFI'),'CDFI')
end



