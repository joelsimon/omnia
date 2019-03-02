Installation notes:

1) Create the required (path) environmental variables in your
preferred shell configuration file (eg., bashrc, or wherever you keep
environmnetal variables).  For me (in zsh) the command is "export",
for c-shell types, "setenv":

export OMNIA=/home/jdsimon/github/omnia 
export IFILES=$OMNIA/notmycode/fjs/IFILES

2) I have a startup.m file which is automatically executed when MATLAB
is launched.  It lives in omnia/omnealiud.  If you already have a
startup.m file somewhere else, append the relevant lines from my file
to yours.  Otherwise you can leave it there

If you already have a startup.m file, e.g. in your MATLAB "userpath", for me:

'/home/jdsimon/Documents/MATLAB'

append my startup.m lines to yours.

3) Source your updated shell configuration file and launch MATLAB from
the terminal, such that the environmental variables you just created
may be known to MATLAB, for me:

/usr/local/MATLAB/R2017b/bin/matlab


