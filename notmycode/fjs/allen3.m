function allen3
% Wavelet analysis of the two seismograms studied in ALLEN1
%
% Last modified by fjsimons-at-alum.mit.edu, 11/30/2006

% Identify two earthquakes close of differing magnitude in some cluster
[names,lon,lat,mag]=locident;
% Identify all the stations in another cluster 
[statio,lon,lat]=statident([241.7 33.9],20);
% Identify two events of differing magnitude
[mima,j]=min(mag);
[mama,k]=max(mag);

% Set defaults
defval('ddir','/home/fjsimons/EALARMS')
defval('seis1',names(j,:))
defval('seis2',names(k,:))
disp(names(j,:))
disp(names(k,:))

% Load data
[x1,h1,t1,p1,ts1]=readsac(fullfile(ddir,seis1,'BHZdata',...
				   'GSC.BHZ.sac.t0'),0);
[x2,h2,t2,p2,ts2]=readsac(fullfile(ddir,seis2,'BHZdata',...
				       'gsc.BHZ.sac.t0.sync'),0);

% Resample data
rrate=2;
x1f=resample(x1,1,rrate); 
ts1f=linspace(ts1(1),ts1(end),length(x1f));
x2f=resample(x2,1,rrate); 
ts2f=linspace(ts2(1),ts2(end),length(x2f));

% Thresholding level
tlev=999;

% Make scalogram of the first 100 seconds of the resampled data 
% That is, between 0 and 100!
cuto=120;
sel1=ts1f<cuto&ts1f>0;
sel2=ts2f<cuto&ts2f>0;
% Rename! We didn't do this in ALLEN2
x1f=x1f(sel1);
x2f=x2f(sel2);
ts1f=ts1f(sel1);
ts2f=ts2f(sel2);

% Now perform the wavelet analysis as in WTEVENTS
% Make this the centerpiece figure, where we show the actual wavelet
% coefficients
% Make plot
clf
[ah,ha]=krijetem(subnum(3,2));
colormap(flipud(gray(25)))

cols=[grey(5) ; 0 0 0];
howm=2^(nextpow2(length(x1f))-1);
s1=detrend(scale(x1f(1:howm)),'constant');
% Make the wavelet transform
[a,d,an,dn]=wt(s1,'CDF',[2 4],5,4);
[dt,dnz]=threshold(d,dn,'soft',tlev);
[x,xrec1]=iwt(a,d,an,dn,'CDF',[2 4],4);
% Check invertibility
difer(s1-xrec1)

axes(ah(1))
% Onset timing is not a trivial task here... so just forget about it
[pdy,stp1,rgp1]=dyadplot(s1,a,dt,an,dn,1,...
	    [0 0+(howm-1)*h1.DELTA*rrate]);
xlim([0 100])
hold on
pt(1)=plot([h1.T0 h1.T0],ylim,'k-');
ps(1)=plot([h1.T1 h1.T1],ylim,'k-');
%xl(1)=xlabel('time (s)');
yl(1)=ylabel('scale (s)');

howm=2^(nextpow2(length(x2f))-1);
s2=detrend(scale(x2f(1:howm)),'constant');
% Just to get the coefficients right...
[a,d,an,dn]=wt(s2,'CDF',[2 4],5,4);
[dt,dnz]=threshold(d,dn,'soft',tlev);
[x,xrec2]=iwt(a,d,an,dn,'CDF',[2 4],4);
% Check invertibility
difer(s2-xrec2)

axes(ah(3))
[pdy,stp2,rgp2]=dyadplot(s2,a,dt,an,dn,1,...
	    [0 0+(howm-1)*h2.DELTA*rrate]);
xlim([0 100])
hold on
pt(2)=plot([h2.T0 h2.T0],ylim,'k-');
ps(2)=plot([h2.T1 h2.T1],ylim,'k-');
xl(2)=xlabel('time (s)');
yl(2)=ylabel('scale (s)');
hold off

set(ah,'clim',[0 1.5])

cb=colorbarf('hor',10,'Helvetica',[0.1292  0.31  0.3367  0.0207]);
set(get(cb,'xlabel'),'string','wavelet coefficient magnitude')
longticks(cb,2)

% Cosmetics
fig2print(gcf,'portrait')
delete(ha(3:end))
ha=ha(1:2);
ah=ah([1 3]);
longticks(ah)
[a,b]=label(ah,'lr',12);
nolabels(ah(1),1)
serre(ha(1:2),1/3,'down')

figdisp

disp('Watch for data aspect ratio, correct by simply putting in keyboard')


