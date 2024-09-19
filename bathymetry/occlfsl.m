function ct = occlfsl(z, tz, crat, mess)
% ct = OCCLFSL(z, tz, crat, mess)
%
% Tally occlusion based on the concept of free-space loss by incrementing the
% output count at each Fresnel radii along the path (from source to receiver)
% where the the contiguous clearance is less than 0.6 the width of the first
% Fresnel zone. NaNs in elevation matrix are ignored (clearance computed
% considering only finite elements in each row).
%
% Occlusion is defined as elevation being greater than test elevation (i.e.,
% path blocked by seamount).
%
%% ATM: does not correct/adjust for in/out of seamount; raw count. Doesn't,
%% e.g., only increment when going from water to rock (counts each radius
%% within rock).
%
% Input:
% z        Elevation (depth is negative) matrix with Fresnel "tracks"
%              as columns and Fresnel radii as rows [m]
% tz       Test elevation array [m]
% crat     Clearance ratio
% mess     Print occlusion message at each radii, useful for understanding
%              and debugging (def: false)
%
% Output:
% ct        Tally (raw count) of number of Fresnel radii occluded
%
% Notes about examples: points analyzed lie at vertices of surface plot; colors
% a bit wonky due to how colormap smears vertices to squares.
%
% Ex1: (shows how NaNs are treated; test depth is plane at -120 m)
%    z = [ NaN    NaN  -150   NaN   NaN
%          NaN   -150  -125  -150   NaN
%         -150   -125  -100  -125  -150
%          NaN   -150  -125  -150   NaN
%          NaN    NaN  -150   NaN   NaN];
%    tz = -120;
%    crat = 0.6;
%    surf(z); set(gca, 'YDir', 'reverse'); xlabel('Radii width'); xticks([1:5])
%    ylabel('Radii number'); zlabel('Elevation [m]'); yticks([1:6]); hold on
%    surf(repmat(tz, size(z))); colormap(winter); hold off
%    ct = OCCLFSL(z, tz, crat, true)
%
% Ex2: (shows how contiguity matters; test depth is plane at -120 m)
%    z = [-150   -150  -150  -150  -150  -150  -150
%         -125   -125  -125  -100  -125  -125  -150
%         -100   -150  -150  -125  -150  -150  -150
%         -100   -100  -125  -150  -125  -100  -100
%         -125   -125  -150  -150  -125  -100  -100
%         -150   -150  -150  -150  -125  -125  -125];
%    tz = -120;
%    crat = 0.6;
%    surf(z); set(gca, 'YDir', 'reverse'); xlabel('Radii width'); xticks([1:7])
%    ylabel('Radii number'); zlabel('Elevation [m]'); yticks([1:6]); hold on
%    surf(repmat(tz, size(z))); colormap(winter); hold off
%    ct = OCCLFSL(z, tz, crat, true)
%
% Explanation1: The first row is clear because it only has a single point within
% the Fresnel radius (NaNs are ignored), and it is below (deeper than) the test
% depth.  Only the third row is occluded because it has the peak of the seamount
% at -100 m in the middle of the radius, meaning that the contiguous clearance
% gap of that row is of width two on either side of the seamount. So while in
% total four of five points along the radius are clear, they are not
% contiguously clear, and thus that slice is defined as occluded.
%
% Explanation2: Again the lone middle seamount, now in row (Fresnel radii) two
% is the an occluder due to splitting contiguity.  The following third row is
% unoccluded despite having more points occluded (two of seven) because the
% remaining five points are unoccluded (deeper than test depth) and contiguous,
% for a clearance factor of 0.71 the full Fresnel width. Next the fourth row is
% occluded, despite the middle contiguous clearance, because four of seven
% points are occluded (at right/left edges of Fresnel radii).
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 23-Apr-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

%% ___________________________________________________________________________ %%
%% RECURSIVE.
% Loop over function for multiple test depths.
if length(tz) > 1
    for i = 1:length(tz)
        ct(i) = occlfsl(z, tz(i));

    end

    % Reshape output to same size as input and exit.
    ct = reshape(ct, size(tz));
    return

end
%% RECURSIVE.
%% ___________________________________________________________________________ %%

defval('crat', 0.6)
defval('mess', false)

% Number of Fresnel radii same as number of points along great-circle path
% (running from source to receiver).
num_fr_rad = size(z, 1);

% Initialize output count.
ct = 0;

% Loop over the rows (going down matrix, along Fresnel "tracks," inspecting each
% Fresnel radii).
for i = 1:size(z, 1)
    if mess; fprintf('Radii number %i: ', i); end

    % The Fresnel radii are the rows of the elevation matrix.
    fr_rad = z(i, :);

    % Skip calculation if all NaNs; e.g., a radii before the slope, removed as in
    % `zero_min=true`.
    if all(isnan(fr_rad))
        if mess; fprintf('all NaN (skipped)\n'); end
        continue

    end

    % Chop off any NaNs in this row (e.g., at source/receiver there may only be a
    % single finite elevation; all points are finite only near midpoint of
    % great-circle path, where Fresnel radius is maximized).
    fr_rad = fr_rad(~isnan(fr_rad));

    % Width of the first Fresnel zone at this point along the path.
    fz_width = length(fr_rad);

    % Yes/no vector of "occluded or not" where occlusion is defined as
    % elevation being greater than test depth (i.e., you ran into a seamount
    % as opposed to transiting free-space [clear-path through water]).
    occluded = fr_rad > tz;

    % This loops over each Fresnel radii -- so running along the diameter of
    % the Fresnel zone -- and counts contiguous clearance.  If the width of
    % some chunk of contiguous clearance exceeds 0.6 this radii (slice of the
    % path) is deemed unoccluded and the next radii is inspected.
    clearance_width = 0;
    for j = 1:fz_width
        % Increment or reset clearance-contiguity counter.
        if occluded(j)
            clearance_width = 0;

        else
            clearance_width = clearance_width + 1;

        end

        % Exit loop early if contiguous clearance is greater than clearance ratio (move
        % to next Fresnel radius).  Do NOT return the contiguous-clearance ratio
        % computed here because it is simply the first point at which the radio
        % exceeds the threshold -- this loop short circuits at the first chance
        % that condition is met. That means it may not compute the full
        % contiguous-clearance factor along the full width.
        if clearance_width / fz_width >= crat
            if mess; fprintf('unoccluded\n'); end
            break

        end

        % This radius is occluded if after sweeping entire width (diameter) of Fresnel
        % zone no contiguous gap of at least 60% of full diameter was found.
        if j == fz_width
            if mess; fprintf('  occluded\n'); end
            ct = ct + 1;

        end
    end
end
