#!/home/yuy/anaconda3/envs/seism27/bin/python
# -*- coding: UTF-8 -*-
import obspy
from obspy.clients.fdsn import Client
import write_cat

client = Client("IRIS")

MER_ev_fnm = '/home/yuy/Mermaid/automaid/events/reviewed/identified/txt/identified.txt'
#MER_ev_fnm = '/home/yuy/Downloads/test.txt'
cat = obspy.core.event.catalog.Catalog()

evid = []
MER_ev_f = open(MER_ev_fnm,'r')
for line in MER_ev_f.readlines():
    evid_new = ' '.join(line.split()).split()[-1]  #remove the repeated space
    if not evid_new.isdigit():  # some id is *111111
        evid_new=evid_new[len(evid_new)-8:]
    if evid_new in evid:
        continue
    else:
        print evid_new
        evid.append(evid_new)
        try:
            cat.append(client.get_events(eventid=evid_new,catalog="NEIC PDE").events[0])
        except:
            continue
MER_ev_f.close()
write_cat.write_cat(cat,'MER_catlogue.txt')
cat.write("MER_ev.xml",format="QUAKEML")
