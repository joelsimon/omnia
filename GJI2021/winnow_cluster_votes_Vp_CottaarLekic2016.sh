#! /bin/sh
#
# Winnows cluster_votes_Vp_CottaarLekic2016.txt from Cottaar+2016, doi:
# 10.1093/gji/ggw324 to text files of longitude, latitude, and the number of
# slow Vp votes at 2700 km depth in box defined between:
#
# Longitude: 176, 251
# Latitude:  -33,   4
#
# i.e., the 'nearbystations' bounding-box.
#
# Creates five separate files which only include the: [lon lat #_slow_Vp votes]
# for the interior of the map and all four edges because the edges.  They are
# plotted with fig4c.m; see there for details.
#
# Author: Joel D. Simon
# Contact: jdsimon@alumni.princeton.edu Last modified: 16-Jun-2020

# Interior of map
awk '{if (($1>176) && ($1<251) && ($2>-33) && ($2<4) && ($3==2700)) print $1 , $2, $4}'  \
    ./data/cluster_votes_Vp_CottaarLekic2016.txt  > ./data/winnowed_cluster_votes_Vp_CottaarLekic2016_interior.txt

# Left edge of map
awk '{if (($1==176)  && ($2>=-33) && ($2<=4) && ($3==2700)) print $1 , $2, $4}'  \
    ./data/cluster_votes_Vp_CottaarLekic2016.txt  > ./data/winnowed_cluster_votes_Vp_CottaarLekic2016_left.txt

# Right edge of map
awk '{if (($1==251)  && ($2>=-33) && ($2<=4) && ($3==2700)) print $1 , $2, $4}'  \
    ./data/cluster_votes_Vp_CottaarLekic2016.txt  > ./data/winnowed_cluster_votes_Vp_CottaarLekic2016_right.txt

# Bottom edge of map
awk '{if (($1>=176) && ($1<=251) && ($2==-33) && ($3==2700)) print $1 , $2, $4}'  \
    ./data/cluster_votes_Vp_CottaarLekic2016.txt  > ./data/winnowed_cluster_votes_Vp_CottaarLekic2016_bottom.txt

# Top edge of map
awk '{if (($1>=176) && ($1<=251) && ($2==4) && ($3==2700)) print $1 , $2, $4}'  \
    ./data/cluster_votes_Vp_CottaarLekic2016.txt  > ./data/winnowed_cluster_votes_Vp_CottaarLekic2016_top.txt
