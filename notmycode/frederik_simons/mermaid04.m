function mermaid04
% MERMAID04
%
% Simons, Nolet et al., JGR, 2009, FIGURE 4.
%
% Plots the results of some curious signals NOT collected by MERMAID.
%
% See also: DETECTS, SIGNALS
% 
% Last modified by fjsimons-at-alum.mit.edu, 01/16/2009

% dir='/Users/jdsimon/Dropbox/Mermaid_copy/Mermaid/Data';
% files={'05.mat','06.mat','07.mat',...
%        '08.mat','09.mat','10.mat'};

d = 20;  %this is the hydrophone HOUR (5:29); r below is the hydrophone NUMBER (5:7)
  load(sprintf('/Users/jdsimon/Dropbox/Mermaid_copy/Mermaid/Data/%2.2i.mat',d))
    

%r = the hydrophone number (the data includes 1-7, but only 5-7 are hydrophones)
for r=5:5  %5-7 because those are the actual hydrophones
    x = v(r,:);  %This is the data
    files = 'test';
end


filts={'lowpass','lowpass','lowpass','lowpass','lowpass','lowpass'};
fops={{10,2,2},{10,2,2},{10,2,2},{10,2,2},{10,2,2},{10,2,2}};

% Some arbitrary y-axis scalings
scax=[100 10 1e-3 10 10 10];
% Spectrogram parameters
wsec=5; % This is different from MERMAID03
wolap=0.875;
% Scalogram parameters
tipo='CDF';
nvm=[2 4];
nd=7;
pph=4;
intel=0;
thresh=1;
div=2.5;
% This is for PLOTTING ONLY
Fmax=50;
Fmin=0.1;

clf
pns=6;
[ah,ha]=krijetem(subnum(6,4));

for inx=1:pns
  % Time-domain plots of the identified events %%%%%%%%%%%%%%%%%%%%
  axes(ha(inx))
  % Do not filter
  decs=0;
  [x,h,Fs,p(inx),xl(inx),yl(inx),tl(inx),pt01(inx,:),xf]=...
      timdomplot(fullfile(dir,sprintf('%s.sac',files{inx})),decs,...
		 filts{inx},fops{inx});
  
  % Adjust axes to be pretty
  set(p(inx),'ydata',get(p(inx),'ydata')/scax(inx))
  axis tight 
  % Quick fix at the last minute
  if inx==2
    set(ha(inx),'ytick',[-3:3:6])
  end

  % Spectrogram of the identified events %%%%%%%%%%%%%%%%%%%%
  axes(ha(inx+pns))
  % The desired window length, in samples
  wlen=floor(wsec*Fs);
  % The number of frequencies, ideally the length of the window
  nfft=max(2^nextpow2(wlen),1024);
  nfft=1024; % Actually, keep it the same
  % Keep the frequencies!! 
  [p2(inx),xl2(inx),yl2(inx),bm{inx},Bl10,F{inx},T]=...
      timspecplot(x,h,nfft,Fs,wlen,wolap,h.B);
  % Just know that you want to quit looking at 50
  ylim([0 Fmax])
  set(ha(inx+pns),'ytick',[0:25:Fmax])

  % Scalogram of the identified events %%%%%%%%%%%%%%%%%%%%
  axes(ha(inx+2*pns))
  % Work maybe on the filtered event to save picstr length?
%   x2=decimate(x,2);
%   x2=decimate(x2,2);
%   x2=decimate(x2,2);
%   h2=h;
%   h2.DELTA=h.DELTA*6;
%  disp('Data severely resampled for rendering!')
  [p3{inx},xl3(inx),yl3(inx),ptt,rgb(inx)]=...
      scalogramplot(x,h,tipo,nvm,nd,pph,intel,thresh,div);
  set(ha(inx+2*pns),'ytick',1:2:nd)

  % Spectral density of the 1000 s data stream %%%%%%%%%%%%%%%%%%%%
  axes(ha(inx+3*pns))
  lwin=floor(h.NPTS/2);
  % No! Keep this always the same for this particular plot
  lwin=floor(250/h.DELTA); % Make this shorter, get smaller lowest frequency
  olap=70;
  % The number of frequencies, ideally the length of the window
  % This divides the Nyquist frequency in so many bins...
  nfft2=1024; % Keep it the same! But also return the F's in the next line
  [p4(inx,:),xl4(inx),yl4(inx),F{inx}]=specdensplot(x,nfft2,Fs,lwin,olap,1);
  % Make it all relative to zero as in decibels
  wats=get(p4(inx,:),'Ydata'); wats=max(max(cat(1,wats{1:3})));
  % DO NOT DO THIS ANYMORE as per the REVIEWER'S COMMENT
  wats=0;
  for onx=1:4
    set(p4(inx,onx),'Ydata',get(p4(inx,onx),'Ydata')-wats);
  end
  axis tight
  ylo=ylim;  xlax=xlim;
  % Round off frequency to 50 and redo labels
  set(gca,'xlim',[min(F{inx}(2),Fmin) Fmax])
  % Even though the axis labels are "nice", it really depends on what
  % F(2) and F(end) is to set the axis labels!... sometimes Fmin is not F(2)
  mima=[Fmin Fmax];
  poslab=10.^[-3:3];
  poslab=poslab(poslab>=mima(1) & poslab<=mima(2));
  set(gca,'xtick',poslab,'xtickl',poslab);
  leg6=sprintf('%i s / %i%s',round(lwin/Fs),olap,'%');
  leg6=sprintf('%i s ',round(lwin/Fs));
  tx6(inx)=text(F{inx}(2)+(F{inx}(3)-F{inx}(2))/4,ylo(2)-range(ylo)/10,leg6,...
		'horizontala','left','FontS',8);
  % Don't do drawnow, it messes the plot up
  hold on
  % This is a bit ad hoc - don't want a grid line on a box edge
  pg{inx}=plot(repmat(poslab(2:end),2,1),ylo,'k:');
  % Force the hand by putting a fake data point on here!!
  % The issue is sometimes 0.1 Hz is .. just missed
  % plot(0.1,0.1,'w.')
  hold off
end

% Cosmetic adjustments
set(yl,'string','sound pressure (scaled hydrophone counts)')
set(p,'Color','k','LineW',0.25)
for inx=1:4
  serre(ha([1:pns]+(inx-1)*pns),1/3,'down')
end
% Move everything up to make room for the colorbars
movev(ha,.05)
moveh(ha(pns+1:2*pns),.005)
moveh(ha(3*pns+1:end),.015)

% But readjust due to the different x-scale
movev(ah(1:(pns*4)/2),.03)

% Extra axis with top labels
% Don't worry about labeling 50 - sometimes it isn't reached
[axx,xl5,yl5]=xtraxis(ha(3*pns+1),[0.1 1 10],[0.1 1 10],'period (s)');
% Extra axis without top labels
for inx=2:pns
  axx(0+inx)=xtraxis(ha(3*pns+inx),[0.1 1 10],[]);
end
set(axx,'Xdir','rev','xlim',[1/Fmax 1/min(F{inx}(2),Fmin)])
longticks([ah axx])

% For a common scale, just put on two tickmarks of a 100s interval around
% the middel
for index=[1 2 3 7 8 9 13 14 15]
  nsec=600;
  xls=get(ha(index),'xlim');
  fex=[-nsec -nsec/2 0 nsec/2 nsec];
  if range(xls)<2*nsec
    set(ha(index),'xlim',xls(1)+range(xls)/2+[-nsec nsec])
  end
  % Fake it just a tiny bit
  xls=get(ha(index),'xlim');
  xmks(1)=xls(1);
  xmks(end)=xls(end);
  xmks=xls(1)+range(xls)/2+fex;
  set(ha(index),'xtick',xmks,'xtickl',fex)
end
for index=[4 5 6 10 11 12 16 17 18]
  nsec=250;
  xls=get(ha(index),'xlim');
  fex=[-nsec -nsec/2 0 nsec/2 nsec];
  set(ha(index),'xlim',xls(1)+range(xls)/2+[-nsec nsec]+[+wsec/2 -wsec/2])
  xmks=xls(1)+range(xls)/2+fex;
  % Fake it just a tiny bit
  xls=get(ha(index),'xlim');
  xmks(1)=xls(1);
  xmks(end)=xls(end);
  set(ha(index),'xtick',xmks,'xtickl',fex)
end
for inx=1:4
  nolabels(ha([1:pns/2-1]+(inx-1)*pns),1) % This must be before label
  nolabels(ha([pns/2+1:pns-1]+(inx-1)*pns),1) % This must be before label
end
set([xl(end) xl2(end) xl3(end)],'string','time (s)')
set(yl2,'string','frequency (Hz)')
set(yl3,'string','scale')
set(xl4(end),'string','frequency (Hz)')
set(yl4,'string','log power spectral density')

colormap jet 
axes(ha(2*pns))
cb(1)=colorbarf('hor',8,'Helvetica',...
	[getpos(ha(2*pns),[1 2 3]) 0.015]+[0 -0.07 0 0]);
% Very important adjustment to the color axis for the spectrogram
for inx=1:pns
  cdt=get(p2(inx),'CData');
  k=mean(cdt(:));
  l=std(cdt(:));
  levs=3;
  set(ha(pns+inx),'Clim',[k-levs*l k+levs*l])
end
xcb1=get(cb(1),'xlim');
axes(cb(1))
xcb(1)=xlabel('log spectral density (stdev from mean)','FontS',8);
set(cb(1),'xtick',linspace(xcb1(1),xcb1(2),2*levs+1),...
	  'xtickl',[-levs:1:levs])

set(p4(:,1),'LineW',0.5,'Color','r');
set(p4(:,[2 3]),'LineW',0.5,'Color',grey);
set(p4(:,4),'MarkerS',2,'Marker','o','MarkerF','r','MarkerE','r');

axes(ha(3*pns))
cb(2)=colorbarf('hor',8,'Helvetica',...
	[getpos(ha(3*pns),[1 2 3]) 0.015]+[0 -0.07 0 0]);

% Very important adjustment to the color axis assuming indeed this goes
% to the hardwired three times the standard deviation!!
axes(cb(2))
set(gcf,'NextPlot','add')
image(repmat([10:-0.5:0]/10,[1 1 3]))
xcb2=get(cb(2),'xlim');
set(cb(2),'xtick',linspace(xcb2(1),xcb2(2),4),...
	  'xtickl',[0 1 2 3],'ytick',[])
xcb(2)=xlabel('wavelet coeff magnitude (stdev)','FontS',8);
longticks(cb,2)

set([ha xl yl xl2 yl2 xl3 yl3 xl4 yl4 xl5 axx],...
    'FontS',8)
delete([tl xl(1:pns-1) xl2(1:pns-1) xl3(1:pns-1) xl4(1:pns-1)])

[bh,th]=label(ha(1:pns),'ll',10,[],[],[],[],0.75);

delete(tx6)

% Leave to last - may have to do this explcitly
for inx=length(axx)
  top(axx(inx))
end

% Last-minute arrangements - save till the very end
delete(yl([1 3 4 6]))
delete(yl4([1 3 4 6]))
fig2print(gcf,'landscape')
figdisp([],[],[],0)

