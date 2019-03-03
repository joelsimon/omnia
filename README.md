Installation notes:

Before running any code in omnia, the following environmental variables (all
paths) must be added to your shell's configuruation file. For me:

1) 

export GITHUB=$HOME/github
export OMNIA=$GITHUB/omnia
export IFILES=$OMNIA/notmycode/fjs/IFILES
export IRISFETCH=$GITHUB/irisFetch-matlab

2)

ln -s $OMNIA/omnealiud/startup.m $HOME/MATLAB/startup.m


3)


matTaup
taupPath([],550,'P,sS','deg',45.6)

irisFetch
tr = irisFetch.Traces('IU','ANMO','10','BHZ','2010-02-27 06:30:00', ...
   '2010-02-27 10:30:00')

       

