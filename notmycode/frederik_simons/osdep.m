function of=osdep
% of=OSDEP
%
% Returns the value of the read option to be used
% on the LOCAL operating system for files created
% on the LOCAL operating system.
%
% Last modified by fjsimons-at-alum.mit.edu, 23.11.2004
% Last modified by jdsimon-at-princeton.edu 11.15.2014 to make mac
% compatabile

if strcmp(getenv('OSTYPE'),'linux') || isunix==1;
  of= 'l';
  end
if strcmp(getenv('OSTYPE'),'solaris')
  of= 'b';  
end

