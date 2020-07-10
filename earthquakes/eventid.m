function [contrib_eventid, contrib_author, iris_eventid] = eventid(EQ)
% [contrib_eventid, contrib_author, iris_eventid] = eventid(EQ)
%
% Returns IRIS and contributor event IDs given an EQ structure from
% irisFetch.Events.m
%
% *(needs header and in-code examples concerning its handling of multiple
% contributors)*
%
% See also: irisFetch.Events, sac2evt
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 10-Jul-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% IRIS public ID in first level of structure.
iris_eventid = fx(strsplit(EQ.PublicId, '='),  2);

% Look at the Preferred Origin for its author and event ID.
contrib_author = EQ.PreferredOrigin.Contributor;
contrib_eventid = commasepstr2cell(EQ.PreferredOrigin.ContributorEventId);

if length(contrib_eventid) > 1

    % *(see Example 1)
    [~, contrib_eventid]  = cellstrfind(contrib_eventid, contrib_author);

    if length(contrib_eventid) > 1

        % *(see Example 2)
        [~, contrib_eventid]  = cellstrfind(contrib_eventid, EQ.PreferredOrigin.ContributorOriginId);

    end
end
contrib_eventid = contrib_eventid{:};

% Check for empties.
if any(cellfun(@isempty, {contrib_eventid, contrib_author, iris_eventid}))
    warning('Empty fields...pausing for inspection')
    keyboard

end

%%______________________________________________________________________________________%%

%% Example 1 (in $SIMON2020 branch of $MERMAID/events)
%
% EQ.Filename = '20180812T150956.09_5B77394A.MER.DET.WLT5.sac'

% EQ =
%                    Filename: '20180812T150956.09_5B77394A.MER.DET.WLT5.sac'
%      FlinnEngdahlRegionCode: '676'
%      FlinnEngdahlRegionName: 'NORTHERN ALASKA'
%                  Magnitudes: [1×5 struct]
%                  MbMlAuthor: ''
%          MbMlMagnitudeValue: 6.3000
%                    MbMlType: 'Ml'
%                     Origins: [1×1 struct]
%                      Params: NaN
%            PhasesConsidered: 'p, P, pP, PP, Pn, Pg, s, S, Sn, Sg, PcP, Pdiff, PKP, PKiKP, PKIKP'
%                       Picks: []
%              PreferredDepth: 2.2000
%           PreferredLatitude: 69.5619
%          PreferredLongitude: -145.2998
%          PreferredMagnitude: [1×1 struct]
%      PreferredMagnitudeType: 'ml'
%     PreferredMagnitudeValue: 6.3000
%             PreferredOrigin: [1×1 struct]
%               PreferredTime: '2018-08-12 14:58:54.286'
%                    PublicId: 'smi:service.iris.edu/fdsnws/event/1/query?eventid=10934109'
%                   QueryTime: '2020-02-26 01:47:11.078'
%                   TaupTimes: [1×3 struct]
%                        Type: 'earthquake'

% EQ.PreferredOrigin =
%                    Time: '2018-08-12 14:58:54.286'
%                Latitude: 69.5619
%               Longitude: -145.2998
%                   Depth: 2.2000
%                  Author: 'at,ak,us'
%                 Catalog: 'NEIC PDE'
%             Contributor: 'ak'
%     ContributorOriginId: 'at00pdcsa7'
%      ContributorEventId: 'at00pdcsa7,ak20076877,us1000g77a'
%                PublicId: 'smi:service.iris.edu/fdsnws/event/1/query?originid=33957186'
%                Arrivals: []

% http://ds.iris.edu/ds/nodes/dmc/tools/event/10934109
% https://earthquake.usgs.gov/earthquakes/eventpage/ak018aap2cqu/
% http://earthquake.alaska.edu/event/20076877
