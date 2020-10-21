function HdrData = makehdr
% HdrData = MAKEHDR
%
% Fills a complete binary (not alphanumeric) SAC header (158, 32-bit "words")
% with default values.
%
% Originally written and last modified by fjsimons-at-alum.mit.edu, 09/12/2007
% Last modified in Ver. 2017b by jdsimon@princeton.edu, 20-Oct-2020

% SAC default values.
sacdef_F = single(-12345.0);
sacdef_N = int32(-12345);
sacdef_I = sacdef_N;
sacdef_L = false;
sacdef_K = pad('-12345', 8);

%%______________________________________________________________________________________%%
% Words 0-69, in SAC parlance --> "F type" (floating)
%%______________________________________________________________________________________%%
HdrData.DELTA = sacdef_F;
HdrData.DEPMIN = sacdef_F;
HdrData.DEPMAX = sacdef_F;
HdrData.SCALE = sacdef_F;
HdrData.ODELTA = sacdef_F;

HdrData.B = sacdef_F;
HdrData.E = sacdef_F;
HdrData.O = sacdef_F;
HdrData.A = sacdef_F;

HdrData.T0 = sacdef_F;
HdrData.T1 = sacdef_F;
HdrData.T2 = sacdef_F;
HdrData.T3 = sacdef_F;
HdrData.T4 = sacdef_F;

HdrData.T5 = sacdef_F;
HdrData.T6 = sacdef_F;
HdrData.T7 = sacdef_F;
HdrData.T8 = sacdef_F;
HdrData.T9 = sacdef_F;

HdrData.F = sacdef_F;
HdrData.RESP0 = sacdef_F;
HdrData.RESP1 = sacdef_F;
HdrData.RESP2 = sacdef_F;
HdrData.RESP3 = sacdef_F;

HdrData.RESP4 = sacdef_F;
HdrData.RESP5 = sacdef_F;
HdrData.RESP6 = sacdef_F;
HdrData.RESP7 = sacdef_F;
HdrData.RESP8 = sacdef_F;

HdrData.RESP9 = sacdef_F;
HdrData.STLA = sacdef_F;
HdrData.STLO = sacdef_F;
HdrData.STEL = sacdef_F;
HdrData.STDP = sacdef_F;

HdrData.EVLA = sacdef_F;
HdrData.EVLO = sacdef_F;
HdrData.EVEL = sacdef_F;
HdrData.EVDP = sacdef_F;
HdrData.MAG = sacdef_F;

HdrData.USER0 = sacdef_F;
HdrData.USER1 = sacdef_F;
HdrData.USER2 = sacdef_F;
HdrData.USER3 = sacdef_F;
HdrData.USER4 = sacdef_F;

HdrData.USER5 = sacdef_F;
HdrData.USER6 = sacdef_F;
HdrData.USER7 = sacdef_F;
HdrData.USER8 = sacdef_F;
HdrData.USER9 = sacdef_F;

HdrData.DIST = sacdef_F;
HdrData.AZ = sacdef_F;
HdrData.BAZ = sacdef_F;
HdrData.GCARC = sacdef_F;

HdrData.DEPMEN = sacdef_F;
HdrData.CMPAZ = sacdef_F;
HdrData.CMPINC = sacdef_F;
HdrData.XMINIMUM = sacdef_F;

HdrData.XMAXIMUM = sacdef_F;
HdrData.YMINIMUM = sacdef_F;
HdrData.YMAXIMUM = sacdef_F;

%%______________________________________________________________________________________%%
% Words 70-84, in SAC parlance --> "I type" (int32(-12345))
% (this is confusing because they are listed as "I type whose name begins
% with an N..."; either way, their default is int32(-12345))
%%______________________________________________________________________________________%%
HdrData.NZYEAR = sacdef_N;
HdrData.NZJDAY = sacdef_N;
HdrData.NZHOUR = sacdef_N;
HdrData.NZMIN = sacdef_N;
HdrData.NZSEC = sacdef_N;

HdrData.NZMSEC = sacdef_N;
HdrData.NVHDR = sacdef_N;
HdrData.NORID = sacdef_N;
HdrData.NEVID = sacdef_N;
HdrData.NPTS = sacdef_N;

HdrData.NWFID = sacdef_N;
HdrData.NXSIZE = sacdef_N;
HdrData.NYSIZE = sacdef_N;

%%______________________________________________________________________________________%%
% Words 85-104, in SAC parlance --> "I type" (int32(-12345))
%%______________________________________________________________________________________%%
HdrData.IFTYPE = sacdef_I; % Required!
HdrData.IDEP = sacdef_I;
HdrData.IZTYPE = sacdef_I;
HdrData.IINST = sacdef_I;

HdrData.ISTREG = sacdef_I;
HdrData.IEVREG = sacdef_I;
HdrData.IEVTYP = sacdef_I;
HdrData.IQUAL = sacdef_I;
HdrData.ISYNTH = sacdef_I;

HdrData.IMAGTYP = sacdef_I;
HdrData.IMAGSRC = sacdef_I;

%%______________________________________________________________________________________%%
% Words 105-109, in SAC parlance --> "L type" (logical)
%%______________________________________________________________________________________%%
HdrData.LEVEN = sacdef_L;
HdrData.LPSPOL = sacdef_L;
HdrData.LOVROK = sacdef_L;
HdrData.LCALDA = sacdef_L;

%%______________________________________________________________________________________%%
% Words 110-157, in SAC parlance --> "K type" (char)
%
% Recall: each SAC "word" is 32-bits (4 char). Each "K" field is 2 words
% (8 char, 64 bit), except for KEVNM, which is 4 words (16 char, 128 bit).
%%______________________________________________________________________________________%%
HdrData.KSTNM = sacdef_K;
HdrData.KEVNM = [sacdef_K sacdef_K];
HdrData.KHOLE = sacdef_K;
HdrData.KO = sacdef_K;
HdrData.KA = sacdef_K;
HdrData.KT0 = sacdef_K;
HdrData.KT1 = sacdef_K;
HdrData.KT2 = sacdef_K;
HdrData.KT3 = sacdef_K;
HdrData.KT4 = sacdef_K;
HdrData.KT5 = sacdef_K;
HdrData.KT6 = sacdef_K;
HdrData.KT7 = sacdef_K;
HdrData.KT8 = sacdef_K;
HdrData.KT9 = sacdef_K;
HdrData.KF = sacdef_K;
HdrData.KUSER0 = sacdef_K;
HdrData.KUSER1 = sacdef_K;
HdrData.KUSER2 = sacdef_K;
HdrData.KCMPNM = sacdef_K;
HdrData.KNETWK = sacdef_K;
HdrData.KDATRD = sacdef_K;
HdrData.KINST = sacdef_K;
