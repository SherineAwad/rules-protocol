#! /usr/bin/env python
import sys
import screed

reads = sys.argv[1]


qc_cutoff  = 5000 #cutoff for a low quality 


for record in screed.open(reads):
     n = record.name
     s = record.sequence
     q = record.quality
     qc = 0
     for ch in q:
          qc += ord(ch) # A simple score for the read -- will be changed later
     if qc < qc_cutoff  :
             #print '> %s \n %s \n %s \n %s' % (record.name,  record.sequence, record.quality,  qc)
              print '%s - %s' % (record.name,  record.sequence)
