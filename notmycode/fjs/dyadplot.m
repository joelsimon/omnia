function [p,stdp,rngp]=dyadplot(x0,a,d,an,dn,meth,BE,col,sat)
% [p,stdp,rngp]=DYADPLOT(x0,a,d,an,dn,meth,BE,col,sat)
%
% Plots a scalogram (not really: we plot the ABSOLUTE values of the
% wavelet transform, not their squared absolute values), on a scale ideal
% for LIFTING implementation of the fast wavelet transform.
%
% INPUT:
%
% x0          Data whose wavelet transform is being plotted
% a           Scaling (approximation) coefficients at the last level
% d           Wavelet (detail) coefficients in a cell array
% an          The number of scaling coefficients at different levels 
% dn          The number of wavelet coefficients at different levels 
% meth        1 Scaled Image Plot (detail coefficients)
%             2 Linear Line Plot  (approximation and detail)
% BE          Begin and End time of the actual data
% col         'bw' indexes the colormap DIRECTLY
% sat         Saturation level for the color scale in units of the
%             standard deviation of the coefficients being plotted
%
% OUTPUT:
%
% p           Handle(s) to the plot (best to catch with a cell array)
% stdp        Standard deviation of the coefficients plotted
% rngp        Range of all the coefficients plotted
%
% See also WTIMAX, WAVELETS1, WAVELETS2
% 
% Last modified by fjsimons-at-alum.mit.edu, 05/24/2010

defval('BE',0)
defval('meth',1)
defval('col','co')
defval('sat',[])

% The proper time axis?
% This is not trivial... to find out the exact onset timing is tough
% and remember this is not translation invariant, even tougher.
% See how this is "fixed" in allen3. Scalogram should really be the
% square of the absolute value. Says Rioul+91.

if meth==1 % IMAGE PLOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % In samples
  timax=wtimax(a,d,an,length(x0));

  % Initialize array
  topl=nan(length(d),length(x0));
  
  for index=1:length(d)
    if length(d{index})>1
      topl(index,:)=...
	  interp1(timax{index},d{index},1:length(x0),'nearest');
    else
      topl(index,:)=repmat(d{index},1,length(x0));
    end
    % If lifting will get NaN's where boundaries are... but this is
    % wrong, you'll want to just repeat the first and the last value
    topl(index,find(isnan(topl(index,1:floor(length(x0)/2)))))=...
	 d{index}(1);
    topl(index,floor(length(x0)/2)+...
	 find(isnan(topl(index,floor(length(x0)/2)+1:end))))=... 
	 d{index}(end);
    % Take the absolute value of the coefficients NOT SQUARED
    topl(index,:)=abs(topl(index,:));
    % Should perhaps redo this whole thing using repmat...
    % Today this looks clumsy to me but it'll do for now
  end

  if max(abs(BE))~=0 % i.e. if there is a time axis defined
    if strcmp(col,'bw')
      disp(sprintf('Mean of all coefficients is %4.2f',mean(topl(:))));
      disp(sprintf('Stdv of all coefficients is %4.2f', std(topl(:))));
      stdp=std(topl(:));
      if ~isempty(sat)
	topl(topl>=sat*stdp)=sat*stdp;
	disp(sprintf('Coefficients saturated to %i times the stdev',sat))
      end
      % Scale ALL the coefficients together... technically, this is not
      % compatible with the scale-dependent thresholding... fix later,
      % see THRESHOLD2, obviously
      topsc=scale(topl,[0 1]);
      % Sometimes this image is simply too big to be processed correctly
      % into PostScript; let's cycle over shorter patches
      picstr=15000;
      if length(topsc)>picstr
	disp('Resorting to clever Postscript picstring fixing')
	% niter=round(length(topsc)/picstr);
	% Suddenly it wouldn't work - should this be ceil?
	% In other words, niter should never be simply 1 - or if it is,
        % need to put in the end points as well
	niter=ceil(length(topsc)/picstr);
	% Or else I might have changed something below here that I need
        % to change back. Let it go.
	% Note that these chopped stretches aren't all equally long 
	BE=pauli(linspace(BE(1),BE(end),niter+1),2);
	IM=round(pauli(linspace(1,length(topsc),niter+1),2));
	% Make sure that these stretches aren't overlapping
	IM(:,1)=IM(:,1)+[0 ; ones(niter-1,1)];
	BE(:,1)=BE(:,1)+[0 ; diff(BE(2:end,:),1,2)./diff(IM(2:end,:),1,2)];
	for imdex=1:niter
	  p{imdex}=image(BE(imdex,:),[1 length(d)],...
		       repmat(1-topsc(:,IM(imdex,1):IM(imdex,2)),[1 1 3]));
	  hold on
	end
	% Now note that p is a cell array ! Got the be ready on the
        % receiving end
	else
	  p=image(BE,[1 length(d)],repmat(1-topsc,[1 1 3]));
      end
      disp('Coefficients scaled and using image to index bw directly')
    else  
      p=imagesc(BE,[1 length(d)],topl);
      stdp=std(topl(:));
    end
  else
    p=imagesc(topl);
  end
  set(gca,'Ytick',[1:length(d)])
  rngp=range(topl(:));
elseif meth==2 % LINE PLOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  topl{1}=x0;
  topl{2}=a;
  for index=1:length(d)
    topl{index+2}=d{length(dn)-index+1};
    % Perhaps, perhaps not
    topl{index+2}=abs(topl{index+2});  
  end
 
  offs=0;
  [tsamp,tskol,tsel]=wtimax(a,d,an,length(x0),BE);
  for index=1:length(topl)
    % The level of splitting 
    if index==1;            j=0;     end
    if index==2;            j=length(topl)-index;   end
    if index>2;             j=length(topl)-index+1; end
    % In samples
    if j==0
      timax=[1:1:length(x0)];
      timaxSel=1:length(timax);
      tskeel=scale(timax(timaxSel),BE);
    elseif j>0
      timax=tsamp{j};
      timaxSel=tsel{j};
      tskeel=tskol{j};
    end
    if BE~=0
      p(index)=plot(tskeel,topl{index}(timaxSel)+offs);
    else
      p(index)=plot(timax,topl{index}(timaxSel)+offs);
    end
    beg(index)=topl{index}(1)+offs;
    offs=offs-range(topl{1});
    hold on
  end  
  set(p(1),'Color','k')
  set(p(2),'Color','r')
  set(gca,'YTick',sort(beg(3:end)),'YTickl',[1:length(topl)-2])
  stdp=[];
  rngp=[];
end

