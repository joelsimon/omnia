function f = plotjointly(joint,ly,p1,p2,nglog)
% f = PLOTJOINTLY(joint,ly,p1,p2,nglog)
%
% Makes a really ugly plot of lhs, rhs, and joint log-likelihood
% changepoint estimation from jointly.m
%
% Input:
% ly           Structure of lhs/rhs likelihoods at every index
% p1,2         Cell of {mu sigma} for lhs/rhs distributions
% nglog        true to plot negative log-likelihood curves (def: false)
%
% Output:
% f            Struct with relevant figure handles
%
% See also: jointly.m, jointlyaic.m
%
% Ex: 
%    p1 = {0 1}; p2 = {0 sqrt(2)};
%    x = cpgen(1000,500,'norm',p1,'norm',p2);
%    [joint,MLE,ly] = jointly(x,p1,p2,false); % compare with km...
%    PLOTJOINTLY(joint,ly,p1,p2,false);
%    sprintf('True bp is 500; estimated bp is %i',MLE)
% 
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 16-Aug-2017, Version 2017b

% Default.
defval('nglog',false)
defs = stdplt;

f.f = figure;
f.ha = gca;
if nglog
    neg = -1;
else
    neg = 1;
end

% The ly (likelihood) structure has a lhs, rhs, value calculated at
% every sample.
hold(f.ha,'on')
f.plhs = plot(neg*ly.lhs,'b','LineStyle','--');
f.plhs.LineWidth = defs.lineWidth;
f.prhs = plot(neg*ly.rhs,'r','LineStyle',':');
f.prhs.LineWidth = defs.lineWidth;
f.pjoint = plot(neg*joint,'Color',[1 0 1]);
f.pjoint.LineWidth = defs.lineWidth;
f.lg = legend([f.plhs f.prhs f.pjoint],'lhs','rhs','joint');
