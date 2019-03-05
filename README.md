Installation notes:

Before running any code in omnia, the following environmental variables (all
paths) must be added to your shell's configuruation file. For me:

1) 

export GITHUB=$HOME/github<br/>
export OMNIA=$GITHUB/omnia<br/>
export IFILES=$OMNIA/notmycode/fjs/IFILES<br/>
export IRISFETCH=$GITHUB/irisFetch-matlab<br/>

2)    

addpath(genpath(getenv('OMNIA')))  
javaaddpath(fullfile(getenv('OMNIA'), 'notmycode', 'MatTaup', 'lib', ...
                     'matTaup.jar'))  
addpath(genpath(getenv('IRISFETCH')))  
javaaddpath(fullfile(getenv('IRISFETCH'), 'IRIS-WS-2.0.18.jar'))  


2)

ln -s $OMNIA/omnealiud/startup.m $HOME/MATLAB/startup.m


3)


matTaup
taupPath([],550,'P,sS','deg',45.6)

irisFetch
tr = irisFetch.Traces('IU','ANMO','10','BHZ','2010-02-27 06:30:00', ...
   '2010-02-27 10:30:00')

       

