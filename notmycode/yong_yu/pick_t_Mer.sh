#!/bin/bash

workdir="/Users/YuYong/Project/MERMAID"
sacdir="$workdir/Mer_sac"
pdfdir="/Users/YuYong/Project/MERMAID/pdf"

cd $sacdir
for evdir in `ls -d 2019*`;do
#for evdir in `ls -d 20*`;do
	cd $sacdir/$evdir
	for merf in `ls *.MER.*.sac`;do
		echo $evdir
		echo $merf
		id=`echo $merf | awk -F. '{print $1"."$2"."$3"."$4"."$5}'`
		mpdf=$pdfdir/$id".windowed.raw.pdf"
		echo $mpdf
		#t1=`saclst t1 f $merf | awk '{print $2}'`
		usr9=`saclst user9 f $merf | awk '{print $2}'`
		mag=`saclst mag f $merf | awk '{print $2}'`
		gcarc=`saclst gcarc f $merf | awk '{print $2}'`
		if [ $usr9 == '-12345' ];then
			open $mpdf

echo "The frequency band number:"
echo "1: 5-10Hz;     2: 2.5-5Hz    3: 1.25-2.5Hz; "
echo "4: 0.6-1.25Hz; 5: 0.3-0.6Hz"
echo "6: 2.5-10Hz;   7: 1-5Hz;     8: 0.3-2.5Hz;"
echo "0: quit"
echo "Please enter the frequency band (DIST=$gcarc,Mag=$mag):"
			bp_id=7

			while [ $bp_id != "0" ];do

case $bp_id in 
1)
	f1=5
	f2=10
	;;
2)
	f1=2.5
	f2=5
	;;
3)
	f1=1.25
	f2=2.5
	;;
4)
	f1=0.6
	f2=1.25
	;;
5)
	f1=0.3
	f2=0.6
	;;
6)
	f1=2.5
	f2=10
	;;
7)
	f1=1
	f2=5
	;;
8)
	f1=0.3
	f2=2.5
	;;
esac
	
				
echo $f1 $f2
echo "Mark with T1 on the seismograph!"	
sac<<EOF
r $merf
rtr;rmean;taper
bp co $f1 $f2 n 2 p 1
qdp off
ppk
ch user9 1
wh
q
EOF

echo "The frequency band number:"
echo "1: 5-10Hz;     2: 2.5-5Hz    3: 1.25-2.5Hz; "
echo "4: 0.6-1.25Hz; 5: 0.3-0.6Hz"
echo "6: 2.5-10Hz;   7: 1-5Hz;     8: 0.3-2.5Hz;"
echo "0: quit"
echo "Please enter the frequency band:"
read bp_id

			done #
		fi
	done
done



