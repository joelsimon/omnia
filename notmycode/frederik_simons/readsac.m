function [SeisData, HdrData] = readsac(filename, endianness, HdrOnly)
% [SeisData, HdrData] = READSAC(filename, endianness, HdrOnly)
%
% Reads binary (alphanumeric not allowed) SAC-formatted data.
%
% Does not perform conversion of "enumerated" types from int to char,
% e.g., READSAC does not convert IZTYPE=9 to "BEGIN TIME",
% or IFTYPE=1 to "TIME SERIES FILE", etc.
%
% Input:
% filename        SAC file name
% endianness      'l': little-endian (default)
%                 'b': big-endian
% HdrOnly          true to only read header data
%                      (`SeisData` set to []; def: false)
%
% Output:
% SeisData        The number vector
% HdrData         The header structure array
%
% See also: writesac.m
%
% Originally written and last modified by fjsimons-at-alum.mit.edu, 10/16/2011
% Modified using v9.3.0.948333 (R2017b) Update 9 by jdsimon@princeton.edu, 23-Jan-2024

%%  Edits made here must be mirrored in writesac.m and makehdr.m

% Default endianness for Linux.
defval('endianness', 'l')
defval('HdrOnly', false)

% Read the binary file.
fid = fopen(filename, 'r', lower(endianness));
if fid == -1
  error([ 'File ', filename, ' does not exist in current path ', pwd])

end
HdrF = fread(fid, 70, 'float32');
HdrN = fread(fid, 15, 'int32');
HdrI = fread(fid, 20, 'int32');
HdrL = fread(fid, 5, 'int32');
HdrK = fread(fid, [8 24], 'char');
HdrK = char(HdrK');
if HdrOnly
    SeisData = [];

else
    SeisData = fread(fid, HdrN(10), 'float32');

end
fclose(fid);

%% NB; SAC word indexing starts at 0; these assignments shifted w.r.t to
%% http://www.adc1.iris.edu/files/sac-manual/manual/file_format.html by 1.

%%______________________________________________________________________________________%%
% Words 0-69, in SAC parlance --> "F type" (floating)
% According to iris.edu link above, as of Jan-2024 (and possibly earlier) SAC
% word 3 (HdrF index 4) is "UNUSED."  Previously it was "SCALE," which no longer
% exists anywhere in header.  Leaving for legacy codes...
%%______________________________________________________________________________________%%
HdrData.DELTA = HdrF(1);
HdrData.DEPMIN = HdrF(2);
HdrData.DEPMAX = HdrF(3);
HdrData.SCALE = HdrF(4); % "UNUSED" as of Jan-2024 (see note above)
HdrData.ODELTA = HdrF(5);

HdrData.B = HdrF(6);
HdrData.E = HdrF(7);
HdrData.O = HdrF(8);
HdrData.A = HdrF(9);
% Skip: HdrF(10) (internal)

HdrData.T0 = HdrF(11);
HdrData.T1 = HdrF(12);
HdrData.T2 = HdrF(13);
HdrData.T3 = HdrF(14);
HdrData.T4 = HdrF(15);

HdrData.T5 = HdrF(16);
HdrData.T6 = HdrF(17);
HdrData.T7 = HdrF(18);
HdrData.T8 = HdrF(19);
HdrData.T9 = HdrF(20);

HdrData.F = HdrF(21);
HdrData.RESP0 = HdrF(22);
HdrData.RESP1 = HdrF(23);
HdrData.RESP2 = HdrF(24);
HdrData.RESP3 = HdrF(25);

HdrData.RESP4 = HdrF(26);
HdrData.RESP5 = HdrF(27);
HdrData.RESP6 = HdrF(28);
HdrData.RESP7 = HdrF(29);
HdrData.RESP8 = HdrF(30);

HdrData.RESP9 = HdrF(31);
HdrData.STLA = HdrF(32);
HdrData.STLO = HdrF(33);
HdrData.STEL = HdrF(34);
HdrData.STDP = HdrF(35);

HdrData.EVLA = HdrF(36);
HdrData.EVLO = HdrF(37);
HdrData.EVEL = HdrF(38);
HdrData.EVDP = HdrF(39);
HdrData.MAG = HdrF(40);

HdrData.USER0 = HdrF(41);
HdrData.USER1 = HdrF(42);
HdrData.USER2 = HdrF(43);
HdrData.USER3 = HdrF(44);
HdrData.USER4 = HdrF(45);

HdrData.USER5 = HdrF(46);
HdrData.USER6 = HdrF(47);
HdrData.USER7 = HdrF(48);
HdrData.USER8 = HdrF(49);
HdrData.USER9 = HdrF(50);

HdrData.DIST = HdrF(51);
HdrData.AZ = HdrF(52);
HdrData.BAZ = HdrF(53);
HdrData.GCARC = HdrF(54);
% Skip: HdrF(55) (internal)

% Skip: HdrF(56) (interal)
HdrData.DEPMEN = HdrF(57);
HdrData.CMPAZ = HdrF(58);
HdrData.CMPINC = HdrF(59);
HdrData.XMINIMUM = HdrF(60);

HdrData.XMAXIMUM = HdrF(61);
HdrData.YMINIMUM = HdrF(62);
HdrData.YMAXIMUM = HdrF(63);
% Skip: HdrF(64:70) (unused)

%%______________________________________________________________________________________%%
% Words 70-84, in SAC parlance --> "I type" (int32(-12345))
% (this is confusing because they are listed as "I type whose name begins
% with an N..."; either way, their default is int32(-12345))
%%______________________________________________________________________________________%%
HdrData.NZYEAR = HdrN(1);
HdrData.NZJDAY = HdrN(2);
HdrData.NZHOUR = HdrN(3);
HdrData.NZMIN = HdrN(4);
HdrData.NZSEC = HdrN(5);

HdrData.NZMSEC = HdrN(6);
HdrData.NVHDR = HdrN(7);
HdrData.NORID = HdrN(8);
HdrData.NEVID = HdrN(9);
HdrData.NPTS = HdrN(10);

% Skip HdrN(11) (internal)
HdrData.NWFID = HdrN(12);
HdrData.NXSIZE = HdrN(13);
HdrData.NYSIZE = HdrN(14);
% Skip HdrN(15) (unused)

%%______________________________________________________________________________________%%
% Words 85-104, in SAC parlance --> "I type" (int32(-12345))
%%______________________________________________________________________________________%%
HdrData.IFTYPE = HdrI(1); % Required!
HdrData.IDEP = HdrI(2);
HdrData.IZTYPE = HdrI(3);
% Skip: HdrI(4) (unused)
HdrData.IINST = HdrI(5);

HdrData.ISTREG = HdrI(6);
HdrData.IEVREG = HdrI(7);
HdrData.IEVTYP = HdrI(8);
HdrData.IQUAL = HdrI(9);
HdrData.ISYNTH = HdrI(10);

HdrData.IMAGTYP = HdrI(11);
HdrData.IMAGSRC = HdrI(12);
HdrData.IBODY = HdrI(13);
% Skip HdrI(14:20) (unused)

%%______________________________________________________________________________________%%
% Words 105-109, in SAC parlance --> "L type" (logical)
%%______________________________________________________________________________________%%
HdrData.LEVEN = HdrL(1);
HdrData.LPSPOL = HdrL(2);
HdrData.LOVROK = HdrL(3);
HdrData.LCALDA = HdrL(4);
% Skip HdrL(5) (unused)

%%______________________________________________________________________________________%%
% Words 110-157, in SAC parlance --> "K type" (char)
%
% Recall: each SAC "word" is 32-bits (4 char). Each "K" field is 2 words
% (8 char, 64 bit), except for KEVNM, which is 4 words (16 char, 128 bit).
%%______________________________________________________________________________________%%

% Convert to cell of 24 words, combine words 2 and 3, delete word 3.
HdrK = cellstr(HdrK);
HdrK{2} = [HdrK{2} HdrK{3}];
HdrK(3) = [];

HdrData.KSTNM =  HdrK{1};
HdrData.KEVNM = HdrK{2};
HdrData.KHOLE =  HdrK{3};
HdrData.KO =  HdrK{4};
HdrData.KA =  HdrK{5};
HdrData.KT0 =  HdrK{6};
HdrData.KT1 =  HdrK{7};
HdrData.KT2 =  HdrK{8};
HdrData.KT3 =  HdrK{9};
HdrData.KT4 =  HdrK{10};
HdrData.KT5 =  HdrK{11};
HdrData.KT6 =  HdrK{12};
HdrData.KT7 =  HdrK{13};
HdrData.KT8 =  HdrK{14};
HdrData.KT9 =  HdrK{15};
HdrData.KF =  HdrK{16};
HdrData.KUSER0 =  HdrK{17};
HdrData.KUSER1 =  HdrK{18};
HdrData.KUSER2 =  HdrK{19};
HdrData.KCMPNM =  HdrK{20};
HdrData.KNETWK =  HdrK{21};
HdrData.KDATRD =  HdrK{22};
HdrData.KINST =  HdrK{23};
