## Installation:  

1. Before running any code in omnia, the following environmental variables (all
paths) must be added to your shell's configuration file.  

 For me:  
    - export OMNIA=[path_to]/omnia  
    - export IFILES=$OMNIA/notmycode/fjs/IFILES  
    - export IRISFETCH=[path_to]/irisFetch-matlab  

2. Some folders must be added to your shell's path.  

 For me:  

   - export PATH = .../$OMNIA/mermaid:$OMNIA/mermaid/geoazur:$OMNIA/notmycode/fjs:$OMNIA/earthquakes:$PATH  

3. My startup.m must be added to your MATLAB path, or added to an existing
startup.m file.  If you have not yet created one, type 'userpath' in the MATALB
command window to find where it should be placed.  I softlinked mine to my
userpath to maintain git version control.  

 For me:  
    - ln -s $OMNIA/omnealiud/startup.m ~/Documents/MATLAB/startup.m  
