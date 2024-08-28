__Omnia__, to analyze complex and noisy time series with particular emphasis
given to seismoacoustic MERMAID signals.

Developed by Joel D. Simon, a  postdoc at Princeton University (jdsimon@princeton.edu).

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.5637492.svg)](https://doi.org/10.5281/zenodo.5637492)

__NB: irisFetch requires MATLAB 2022b or earlier__

## Installation:
\
[0]. OMNIA relies on various environmental variables being known to MATLAB, which requires
they be set and MATLAB be launched from an updated shell.  The examples below assume zsh.
\
[1]. The following environmental variables must be set in the shell that launches MATLAB --

    export OMNIA=[path_to_cloned]/omnia
    export IFILES=$OMNIA/notmycode/fjs/IFILES
    export IRISFETCH=[path_to_cloned]/irisFetch-matlab
The last is required for many functions in $OMNIA and may be cloned at:

    https://github.com/joelsimon/irisFetch-matlab
\
[2]. The $PATH of the shell that launches MATLAB must be updated (for system() scripts) --

    export PATH = $OMNIA/mermaid:$OMNIA/earthquakes:$PATH
\
[3]. My startup.m must be added to your MATLAB path, or added to an existing
    startup.m file.  If you have not yet created one, type 'userpath' in the MATLAB
    command window to find where it should be placed.  I softlinked mine to my
    userpath to maintain git version control --

    ln -s $OMNIA/omnealiud/startup.m ~/Documents/MATLAB/startup.m
\
[4]. Exit and reload terminal (or source your new config files) and launch MATLAB.

## Citation:

Joel D. Simon. (2021). joelsimon/omnia:
(v1.1.0). Zenodo. https://doi.org/10.5281/zenodo.5637492