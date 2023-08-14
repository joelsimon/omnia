function varargout=twoplot(XY,varargin)
% handle=TWOPLOT(XY,'property','value')
%
% Plots a Mx2 matrix as (x,y) coordinates in the plane
%
% Last modified by fjsimons-at-alum.mit.edu, 12/02/2009

p=plot(XY(:,1),XY(:,2),varargin{1:nargin-1});

% Output
varns={p};
varargout=varns(1:nargout);
