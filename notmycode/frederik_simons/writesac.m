function writesac(SeisData, HdrData, filename, endianness)
% WRITESAC(SeisData, HdrData, filename, endianness)
%
% Writes binary (not alphanumeric) SAC file.
%
% Does not perform conversion of "enumerated" types from int to char,
% e.g., READSAC does not convert IZTYPE="BEGIN TIME" to 9,
% or IFTYPE"TIME SERIES FILE" to 1, etc.
%
% Input:
% SeisData      Dependent data (e.g., time series or spectral data)
% HdrData       Header structure formatted to SAC standard
% filename      Output SAC file name
% endianness    'l': little-endian (default)
%               'b': big-endian
%
% See also: readsac.m
%
% Originally written and last modified by fjsimons-at-alum.mit.edu, 10/16/2011
% Modified using v9.3.0.948333 (R2017b) Update 9 by jdsimon@princeton.edu, 23-Jan-2024

%%  Edits made here must be mirrored in readsac.m and makehdr.m

% Default byte ordering.
defval('endianness', 'l')

% Check for consistency; tolerance needs to be fairly high.
tolex = min(1e-5, HdrData.DELTA);
difer(HdrData.NPTS - length(SeisData), [], 1, NaN);
difer(HdrData.B + (HdrData.DELTA*(HdrData.NPTS-1)) - HdrData.E, tolex, 1, NaN)

% Initialize header with SAC binary default values: 158, 32-bit words.
sacdef_F = single(-12345.0);
sacdef_N = int32(-12345);
sacdef_I = sacdef_N;
sacdef_L = false;
sacdef_K = pad({'-12345'}, 8);

HdrF = repmat(sacdef_F, 70, 1);
HdrN = repmat(sacdef_N, 15, 1);
HdrI = repmat(sacdef_I, 20, 1);
HdrL = repmat(sacdef_L, 5, 1);

% "K" fields are length 8 char alphanumeric, except the second field "KEVNM"
% (SAC "words" 112:115), which is a length 16 char
HdrK = repmat(sacdef_K, 23, 1);
HdrK{2} = pad(HdrK{2}, 16);

% Assign variables to the header.  If you change any of this, change it in
% READSAC as well (and potentially makehdr.m).

%% NB; SAC word indexing starts at 0; these assignments shifted w.r.t to
%% http://www.adc1.iris.edu/files/sac-manual/manual/file_format.html by 1.

%%______________________________________________________________________________________%%
% Words 0-69, in SAC parlance --> "F type" (floating)
% According to iris.edu link above, as of Jan-2024 (and possibly earlier) SAC
% word 3 (HdrF index 4) is "UNUSED."  Previously it was "SCALE," which no longer
% exists anywhere in header.  Leaving for legacy codes...
%%______________________________________________________________________________________%%
HdrF(1) = HdrData.DELTA;
HdrF(2) = HdrData.DEPMIN;
HdrF(3) = HdrData.DEPMAX;
HdrF(4) = HdrData.SCALE; % "UNUSED" as of Jan-2024 (see note above)
HdrF(5) = HdrData.ODELTA;

HdrF(6) = HdrData.B;
HdrF(7) = HdrData.E;
HdrF(8) = HdrData.O;
HdrF(9) = HdrData.A;
% Skip: HdrF(10) (internal)

HdrF(11) = HdrData.T0;
HdrF(12) = HdrData.T1;
HdrF(13) = HdrData.T2;
HdrF(14) = HdrData.T3;
HdrF(15) = HdrData.T4;

HdrF(16) = HdrData.T5;
HdrF(17) = HdrData.T6;
HdrF(18) = HdrData.T7;
HdrF(19) = HdrData.T8;
HdrF(20) = HdrData.T9;

HdrF(21) = HdrData.F;
HdrF(22) = HdrData.RESP0;
HdrF(23) = HdrData.RESP1;
HdrF(24) = HdrData.RESP2;
HdrF(25) = HdrData.RESP3;

HdrF(26) = HdrData.RESP4;
HdrF(27) = HdrData.RESP5;
HdrF(28) = HdrData.RESP6;
HdrF(29) = HdrData.RESP7;
HdrF(30) = HdrData.RESP8;

HdrF(31) = HdrData.RESP9;
HdrF(32) = HdrData.STLA;
HdrF(33) = HdrData.STLO;
HdrF(34) = HdrData.STEL;
HdrF(35) = HdrData.STDP;

HdrF(36) = HdrData.EVLA;
HdrF(37) = HdrData.EVLO;
HdrF(38) = HdrData.EVEL;
HdrF(39) = HdrData.EVDP;
HdrF(40) = HdrData.MAG;

HdrF(41) = HdrData.USER0;
HdrF(42) = HdrData.USER1;
HdrF(43) = HdrData.USER2;
HdrF(44) = HdrData.USER3;
HdrF(45) = HdrData.USER4;

HdrF(46) = HdrData.USER5;
HdrF(47) = HdrData.USER6;
HdrF(48) = HdrData.USER7;
HdrF(49) = HdrData.USER8;
HdrF(50) = HdrData.USER9;

HdrF(51) = HdrData.DIST;
HdrF(52) = HdrData.AZ;
HdrF(53) = HdrData.BAZ;
HdrF(54) = HdrData.GCARC;
% Skip: HdrF(55) (internal)

% Skip: HdrF(56) (internal)
HdrF(57) = HdrData.DEPMEN;
HdrF(58) = HdrData.CMPAZ;
HdrF(59) = HdrData.CMPINC;
HdrF(60) = HdrData.XMINIMUM;

HdrF(61) = HdrData.XMAXIMUM;
HdrF(62) = HdrData.YMINIMUM;
HdrF(63) = HdrData.YMAXIMUM;
% Skip: HdrF(64:70) (unused)

%%______________________________________________________________________________________%%
% Words 70-84, in SAC parlance --> "I type" (int32(-12345))
% (this is confusing because they are listed as "I type whose name begins
% with an N..."; either way, their default is int32(-12345))
%%______________________________________________________________________________________%%
HdrN(1) = HdrData.NZYEAR;
HdrN(2) = HdrData.NZJDAY;
HdrN(3) = HdrData.NZHOUR;
HdrN(4) = HdrData.NZMIN;
HdrN(5) = HdrData.NZSEC;

HdrN(6) = HdrData.NZMSEC;
HdrN(7) = HdrData.NVHDR;
HdrN(8) = HdrData.NORID;
HdrN(9) = HdrData.NEVID;
HdrN(10) = HdrData.NPTS;

% Skip HdrN(11) (internal)
HdrN(12) = HdrData.NWFID;
HdrN(13) = HdrData.NXSIZE;
HdrN(14) = HdrData.NYSIZE;
% Skip HdrN(15) (internal)

%%______________________________________________________________________________________%%
% Words 85-104, in SAC parlance --> "I type" (int32(-12345))
%%______________________________________________________________________________________%%
HdrI(1) = HdrData.IFTYPE; % Required!
HdrI(2) = HdrData.IDEP;
HdrI(3) = HdrData.IZTYPE;
% Skip: HdrI(4) (unused)
HdrI(5) = HdrData.IINST;

HdrI(6) = HdrData.ISTREG;
HdrI(7) = HdrData.IEVREG;
HdrI(8) = HdrData.IEVTYP;
HdrI(9) = HdrData.IQUAL;
HdrI(10) = HdrData.ISYNTH;

HdrI(11) = HdrData.IMAGTYP;
HdrI(12) = HdrData.IMAGSRC;
HdrI(13) = HdrData.IBODY;
% Skip HdrI(14:20) (unused)

%%______________________________________________________________________________________%%
% Words 105-109, in SAC parlance --> "L type" (logical)
%%______________________________________________________________________________________%%
HdrL(1) = HdrData.LEVEN;
HdrL(2) = HdrData.LPSPOL;
HdrL(3) = HdrData.LOVROK;
HdrL(4) = HdrData.LCALDA;
% Skip HdrL(5) (unused)

%%______________________________________________________________________________________%%
% Words 110-157, in SAC parlance --> "K type" (char)
%
% Recall: each SAC "word" is 32-bits (4 char). Each "K" field is 2 words
% (8 char, 64 bit), except for KEVNM, which is 4 words (16 char, 128 bit).
%%______________________________________________________________________________________%%
HdrK{1} = pad(HdrData.KSTNM, 8);
HdrK{2} = pad(HdrData.KEVNM, 16);
HdrK{3} = pad(HdrData.KHOLE, 8);
HdrK{4} = pad(HdrData.KO, 8);
HdrK{5} = pad(HdrData.KA, 8);
HdrK{6} = pad(HdrData.KT0, 8);
HdrK{7} = pad(HdrData.KT1, 8);
HdrK{8} = pad(HdrData.KT2, 8);
HdrK{9} = pad(HdrData.KT3, 8);
HdrK{10} = pad(HdrData.KT4, 8);
HdrK{11} = pad(HdrData.KT5, 8);
HdrK{12} = pad(HdrData.KT6, 8);
HdrK{13} = pad(HdrData.KT7, 8);
HdrK{14} = pad(HdrData.KT8, 8);
HdrK{15} = pad(HdrData.KT9, 8);
HdrK{16} = pad(HdrData.KF, 8);
HdrK{17} = pad(HdrData.KUSER0, 8);
HdrK{18} = pad(HdrData.KUSER1, 8);
HdrK{19} = pad(HdrData.KUSER2, 8);
HdrK{20} = pad(HdrData.KCMPNM, 8);
HdrK{21} = pad(HdrData.KNETWK, 8);
HdrK{22} = pad(HdrData.KDATRD, 8);
HdrK{23} = pad(HdrData.KINST, 8);

% Concatenate all HdrK fields into 192x1 array of chars.
HdrK = [HdrK{:}]';

% Finally, proceed to writing this.
fid = fopen(filename, 'w', endianness);
fwrite(fid, HdrF, 'float32');
fwrite(fid, HdrN, 'int32');
fwrite(fid, HdrI, 'int32');
fwrite(fid, HdrL, 'int32');
fwrite(fid, HdrK, 'char');
fwrite(fid, SeisData, 'float32');
fclose(fid);
