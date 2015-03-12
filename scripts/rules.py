#! /usr/bin/env python
import sys
import screed

unaligned = sys.argv[1]
reads = sys.argv[2]


qc_cutoff  = 5000 #cutoff for a low quality 
supX = 0
supXY = 0


un = set ()
for record in screed.open(unaligned): 
    n = record.name 
    un.add(n)   


for record in screed.open(reads):
     n = record.name
     s = record.sequence
     q = record.accuracy
     qc = 0
     for ch in q:
          qc += ord(ch) # A simple score for the read -- will be changed later
     if qc < qc_cutoff  :
         supX+= 1  #support of low quality reads  
         if n in un: 
             supXY+=1  #support of low quality reads implies ==> unalignment  
             print '> %s \n %s \n %s \n %s' % (record.name,  record.sequence, record.accuracy,  qc)

confidence = float (supXY/supX)

if confidence  > 0.5 :  #confidence of low quality reads implies ==> unalignment 
    print confidence, supXY, supX,  'low quality implies unalignment '
