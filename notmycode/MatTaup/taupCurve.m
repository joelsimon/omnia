function tt=taupCurve(model,depth,phase)

% TAUPCURVE calculate travel time curve using TauP toolkit
%
% taupTime(model,depth,phase)
%
% Input arguments:
%   Model:      Global velocity model. Default is "iasp91".
%   Depth:      Event depth in km
%   Phase:      Phase list separated by comma
% 
% Output argumet:
%   tt is a structure array with fields:
%   tt(index).phaseName
%            .sourceDepth
%            .distance (in degree)
%            .time
%   If no output argument specified, travel timve curves will be plotted.
%
% Example:
%   taupCurve([],50,'P,sS')
%   taupCurve('prem',0,'P,PKP,PKIKP,PKiKP')
%
% This program calls TauP toolkit for calculation, which is 
% developed by:
%   H. Philip Crotwell, Thomas J. Owens, Jeroen Ritsema
%   Department of Geological Sciences
%   University of South Carolina
%   http://www.seis.sc.edu
%   crotwell@seis.sc.edu
%
% Written by:
%   Qin Li 
%   Unverisity of Washington
%   qinli@u.washington.edu
%   Nov, 2002
%
% Last modified by jdsimon@princeton.edu, 23-Nov-2021 in Ver. 2017b

% JDS changelog
% *Return sorted by travel time (using longest time for each phase as reference)
% *Change tt.distance from [0 0] to [0 360] for "*kmps" phases
% *Edit to return tt structure as opposed to empty

import edu.sc.seis.TauP.*;
import java.io.*;
import java.lang.*;
import java.util.*;
import java.util.zip.*;

if nargin~=3
    error('3 input arguments required');
end;

if isempty(model)
    model='iasp91';
end;

inArgs{1}='-mod';
inArgs{2}=model;
inArgs{3}='-h';
inArgs{4}=num2str(depth);
inArgs{5}='-ph';
inArgs{6}=phase;

try
    matCurve=MatTauP_Curve.run_curve(inArgs);
catch
    fprintf('Java exception occurred! Please check input arguments. \n\n');
    return;
end;

tt_curve = [];
for ii=1:matCurve.length
    tt(ii).phaseName=char(matCurve(ii).phaseName);
    tt(ii).sourceDepth=matCurve(ii).sourceDepth;
    tt(ii).time=matCurve(ii).time;
    tt(ii).distance=matCurve(ii).dist;
    tt(ii).rayParam=matCurve(ii).rayParam;
end;

c={'b','r','g','m','c','y', ...
   'b--','r--','g--','m--','c--','y--', ... 
   'b-.','r-.','g-.','m-.','c-.','y-.', ...
   'b:','r:','g:','m:','c:','y:'};
p={};
if nargout==0
    clf;hold on;box on
    n=0;
    for ii=1:length(tt)
        if length(tt(ii).distance)>1
            n=n+1;
            k=find(diff(tt(ii).rayParam)==0);
            temp_dist=tt(ii).distance;
            temp_time=tt(ii).time;
            if ~isempty(k) % shadow zone
                temp_dist(k)=nan;
                temp_time(k)=nan;
            end;
            plot(temp_dist,temp_time,c{ii});
            p{n}=tt(ii).phaseName;
        end;
    end;
    % jdsimon@princeton.edu edit -- invalid legend option in 2017b
    %legend(p,2);
    legend(p)
    xlabel('Distance (deg)');
    ylabel('Travel Time (s)');
    return;
end;

% jdsimon@princeton.edu edit to compute linear (assuming 0 km deep event)
% distance for "surface" (kmps) waves.
for i = 1:length(tt)
    if contains(tt(i).phaseName, 'kmps')
        tt(i).distance = [0 ; 360]
        %% Verify [0 360] with the following calculation
        % for j = 1:length(tt(i).distance)
        %     vel = strsplit(tt(1).phaseName, 'kmps');
        %     vel = str2double(vel{1});
        %     dist_km = vel * tt(i).time(j);
        %     tt(i).distance(j) = km2deg(dist_km); % degrees

        % end
    end
end

% jdsimon@princeton.edu edit -- sort the rows in ascending order
% (first arriving phases first). 
for i = 1:length(tt)
    dt(i) = tt(i).time(end);

end
[~, idx] = sort(dt, 'ascend');
tt = tt(idx);

