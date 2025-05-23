function [region, code] = feregion(lat, lon, baseurl)
% [region, code] = FEREGION(lat, lon, baseurl)
%
% FEREGION returns the Flinn-Engdahl region name and code given an
% input latitude and longitude.
%
% FEREGION requires an internet connection and queries the IRIS web
% services by default.
% 
% Input:
% lat, lon   Latitude, longitude 
% baseurl    URL to send web query 
%               (def: 'http://service.iris.edu/irisws/flinnengdahl/2/query?')
%
% Output:
% region      Flinn-Engdahl region name
% code        Flinn-Engdahl region code
%
% Ex: 
%    [x, h] = readsac('centcal.1.BHZ.SAC');
%    [region, code] = FEREGION(h.EVLA, h.EVLO)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 18-Feb-2019, Version 2017b

% Default.
defval('baseurl', 'http://service.iris.edu/irisws/flinnengdahl/2/query?')

% Fetch it. Do not try to escape \& in sprintf statement; it must be
% substituted as string.
querystr = sprintf('lat=%.4f%slon=%.4f%soutput=both', lat, '&', lon, '&'); 
output = webread([baseurl querystr]);

% Parse it.
output = strsplit(output, '|');
code = strtrim(output{1});
region = strtrim(output{2});