#! /usr/bin/env python
import sys
import screed
from Bio import SeqIO


reads = sys.argv[1]
read =set ()
qc_cutoff = 0
threshold = 5000

for record in SeqIO.parse(sys.argv[1],"fastq"):
      read =record.format("qual")
      for i in read: 
          if i >30: 
             qc_cutoff +=1 
      if qc_cutoff > threshold:
  	  print record.id

