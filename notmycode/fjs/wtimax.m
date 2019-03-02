function [tsamp,tskol,tsel]=wtimax(a,d,an,lx,BE)
% [tsamp,tskol,tsel]=WTIMAX(a,d,an,lx,BE)
%
% Makes a wavelet time axis for POLYPHASE and LIFTING implementations 
%
% INPUT:
%
% a        Cell array with scaling coefficients
% d        Cell array with wavelet coefficients
% an       Vector with the lengths of the cells of scaling coefficients
% lx       Length of the data
% BE       Beginning and end time of the actual data
%
% OUTPUT:
%
% tsamp    Time axis in samples
% tskol    Time axis scaled to the right beginning and end
% tsel     Selection indices in case you need to take the selected
%          samples from the array to be plotted
%
% See also WAVELETS1, WAVELETS2
%
% Last modified by fjsimons-at-alum.mit.edu, April 28th, 2003

defval('BE',[])

for index=1:length(d)
  % Same time axis as dyadplot
  j=index;
  % In samples
  tsamp{index}=1+sum(2.^([1:j]-2))+...
	cumsum([0 repmat(2^j,1,length(d{index})-1)]);
  % If not with lifting then time axis gets stretched!
  if 2*an(1)>lx
    tsamp{index}=linspace(1,2^j*length(d{index}),length(d{index}));
    tsel{index}=tsamp{index}<lx;
    tsel{index}=tsamp{index}<Inf;
  else
    tsel{index}=1:length(tsamp{index});
  end    
  % Scale time axis to right length
  if ~isempty(BE)
    tskol{index}=scale([1 tsamp{index}(tsel{index}) lx],BE);
    tskol{index}=tskol{index}(2:end-1);
  else
    tskol=tsamp{index};
  end
end

