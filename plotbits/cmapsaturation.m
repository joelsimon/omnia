function cmap = cmapsaturation(cmap, sat)
% cmap = CMAPSATURATION(cmap, sat)
%
% Reduce RGB colormap saturation.
%
% Input:
% cmap    RGB colormap (2D) or image (3D)
% sat     Ratio of saturation decrease (0.5 is 50% lighter)
%
% Output:
% cmap    RGB colormap with adjusted saturation
%
% Ex:
%    ax(1) = subplot(2, 1, 1); imagesc(peaks); cmap1 = colormap('turbo');
%    ax(2) = subplot(2, 1, 2); imagesc(peaks); cmap2 = colormap('turbo');
%    cmap2 = CMAPSATURATION(cmap2, 0.5);
%    colormap(ax(2), cmap2);
%    title(ax(1), 'original colormap')
%    title(ax(2), 'adjusted colormap')
%
% ! NB: an actual image (true color RGB MxNx3 matrix) does not use a colormap, so
% ! adjusting it after it's plotted with imagesc(im) has no effect; in that case
% ! you must manipulate the actual RGB values before imagesc.
%
% Ex2:
%    im = imread('peppers.png');
%    im_sat = CMAPSATURATION(im, 0.5);
%    ax(1) = subplot(2, 1, 1); imagesc(im);
%    ax(2) = subplot(2, 1, 2); imagesc(im_sat);
%    title(ax(1), 'original colormap')
%    title(ax(2), 'adjusted colormap')
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 30-Jun-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

% Convert RGB to HSV, adjust saturation, convert back to RGB (thanks ChatGPT!)
hsv_map = rgb2hsv(cmap);
dim = ndims(cmap);
if dim == 2
   hsv_map(:, 2) = hsv_map(:, 2) * sat;

elseif dim == 3
    hsv_map(:, :, 2) = hsv_map(:, :, 2) * sat;

else
    error('Expected Mx3 (RGB colormap) or MxNx3 (RGB image)')

end
cmap = hsv2rgb(hsv_map);
