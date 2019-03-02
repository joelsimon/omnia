function HdrData=makehdr
% HdrData=MAKEHDR
%
% Makes a sensible empty header for WRITESAC.
%
% Last modified by fjsimons-at-alum.mit.edu, 09/12/2007
%
% Last modified by jdsimon-at-princeton.edu, Mar. 26, 2015 to make
% even more general

badval=-12345;

HdrData=[];

HdrData.B=0;
HdrData.E=1;
HdrData.DELTA=1;
HdrData.SKALE=1;
HdrData.INTERNAL=2;
HdrData.T0=badval;
HdrData.T1=badval;
HdrData.AZ=badval;
HdrData.BAZ=badval;
HdrData.DIST=badval;
HdrData.GCARC=badval;
HdrData.CMPAZ=badval;
HdrData.CMPINC=badval;
HdrData.NZYEAR=indeks(datevec(datenum(clock)),1);
%HdrData.NZJDAY=floor(dayofyear);
HdrData.NZJDAY=1;
HdrData.NZHOUR=indeks(datevec(datenum(clock)),4);
HdrData.NZMIN=indeks(datevec(datenum(clock)),5);
HdrData.NZSEC=ceil(indeks(datevec(datenum(clock)),6));
HdrData.NZMSEC=0;
HdrData.SCALE=badval;
HdrData.NVHDR=6;
HdrData.KINST='Matlab';
HdrData.KSTNM='Linux ';
HdrData.KUSER0='jdsimon';
HdrData.KCMPNM='single';
HdrData.LEVEN=1;
HdrData.LPSPOL=0;
HdrData.LCALDA=0;
HdrData.IFTYPE=1;
HdrData.LOVROK=badval;
HdrData.IDEP=badval;
HdrData.IZTYPE=69;
HdrData.IINST=badval;
HdrData.ISTREG=badval;
HdrData.IEVREG=badval;
HdrData.IEVTYP=badval;
HdrData.IQUAL=badval;
HdrData.ISYNTH=badval;
HdrData.IMAGTYP=badval;
HdrData.IMAGSRC=badval;
HdrData.STLA=badval;
HdrData.STLO=badval;
HdrData.STEL=badval;
HdrData.STDP=badval;
HdrData.EVLA=badval;
HdrData.EVLO=badval;
HdrData.EVEL=badval;
HdrData.EVDP=badval;
HdrData.MAG=badval;

