#!/bin/bash

#The folder where the MERMAID sac files are stored
MERsacdir=/home/yuy/Mermaid/MER_DATA/processed
#The event list and measured arrival time list from OMNIA
mer_list=/home/yuy/Mermaid/MER_DATA/events/reviewed/identified/txt/identified.txt
#mer_list=/home/yuy/Downloads/test.txt
cp_t_list=/home/yuy/Mermaid/MER_DATA/events/reviewed/identified/txt/firstarrivals.txt
#The event catlogue from get_Mer_ev.py
mer_cat=/home/yuy/Mermaid/mycode/Sacfile/MER_catlogue.txt
#The output folder
outdir=/home/yuy/Mermaid/mycode/Sacfile/Mer_sac

#The time period 
Startdate="2019-08-01T00:00:00"
Enddate="2023-01-01T00:00:00"
# Wave Phase p-t1 P-t2 PKP-t3 Pdiff-t4 PKiKP-t5 S-t6 SKS-t7
Phase="p P PKP Pdiff PKiKP S SKS"
#############################################################

Startsec=`date +%s -d"$Startdate"`
Endsec=`date +%s -d"$Enddate"`

if [ ! -e $outdir ];then
    mkdir $outdir
fi

num=`cat $mer_list | wc -l | awk '{print $1}'`
i=0
while [ $i -lt $num ];do 
    ((i=$i+1))
    ev_data=`sed "$i"p -n $mer_list`
    id=`echo $ev_data | awk '{print $NF}'`
    ev_info=`grep $id $mer_cat`
    evlat=`echo $ev_info | awk '{print $3}'`
    evlon=`echo $ev_info | awk '{print $4}'`
    evdep=`echo $ev_info | awk '{print $5}'`
    evmag=`echo $ev_info | awk '{print $6}'`
    evtime=`echo $ev_info | awk '{print $1}'`
    sac_sec=`date -d"$evtime" -u +%s`
    if [ $sac_sec -lt $Startsec -o $sac_sec -gt $Endsec ];then
        continue
    fi 
    sac_time1=`date -d"$evtime" -u +"%Y %j %H %M %S"`
    sac_time2=`date -d"$evtime" -u +"%N" | awk '{print $1/1e6}'`
    sac_time="$sac_time1 $sac_time2"
    echo $sac_time
    sac_fnm=`echo $ev_data | awk '{print $1}'`
    stnm=`echo $sac_fnm | awk '{print substr($1,17,4)}'`
    stdir=$MERsacdir"/452.020-P-"$stnm
    t_data=`cat $cp_t_list | grep $sac_fnm`
    phase=`echo $t_data | awk '{print $2}'`
    dt=`echo $t_data | awk '{print $3}'`
    if [ $dt == "NaN" ];then
        dt=0
    fi
    sac_f=`ls $stdir/*/$sac_fnm`
    evdate=`echo $ev_data | awk '{print $2}'| awk -F- '{print $1$2$3}'`
    evtime=`echo $ev_data | awk '{print $3}'| awk -F: '{print $1$2$3}'`
    ev_dir=$evdate"T"$evtime
    if [ ! -e $outdir/$ev_dir ];then
        mkdir $outdir/$ev_dir
    fi
    cp $sac_f $outdir/$ev_dir
    sac_file=$outdir/$ev_dir/$sac_fnm
    stlat=`saclst stla f $sac_file | awk '{print $2}'`
    stlon=`saclst stlo f $sac_file | awk '{print $2}'`
    stdep=`saclst stdp f $sac_file | awk '{print $2/1000}'`
    #echo $stlat $stlon $stdep
    ii=0
    for ph in `echo $Phase`;do
        ((ii=$ii+1))
        ph_t=`taup_time -h $evdep -evt $evlat $evlon -sta $stlat $stlon --stadepth $stdep -ph $ph \
        | grep " $ph  " | head -n1 | awk '{print $4}'`
        if [ -n "$ph_t" ];then
            echo "ch kt$ii $ph" >> micro.m
            echo "ch t$ii $ph_t" >> micro.m
        fi
        if [ $ph == $phase ];then
            picked_ph_t=`echo $ph_t  $dt | awk '{print $1+$2}'`
            echo "ch kt9 picked_$ph" >> micro.m
            echo "ch t9 $picked_ph_t" >> micro.m
        fi
    done
sac<< EOF
r $sac_file
rgl;rtr;rmean
ch o gmt $sac_time
ch allt (0 - &1,o&) iztype IO
ch evla $evlat evlo $evlon evdp $evdep
ch mag $evmag
m micro.m
wh
q
EOF
    rm micro.m
    echo $sac_fnm $ev_dir
done
