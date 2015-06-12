#! /usr/bin/env python
import sys
import screed

unaligned = sys.argv[1]
qc =set () 
un = set ()

rule = {}


for record in screed.open(unaligned): 
    n = record.name
    n = n + '\n'
    un.add(n)

supX = 0
supXY =0
confidence = 0
for line in open ('qc.low'): 
       name = line
       supX +=1  #support of low quality reads
       if name in un: 
   	     supXY +=1 #support of low quality reads implies => unalignment  

confidence = float (supXY) / float (supX) 
print 'low quality => unalignment', confidence, supXY, supX

supX = 0
supXY =0 
confidence = 0

for line in open ('repeats'):
       name = line
       supX +=1  #support of repeats reads
       if name in un:
             supXY +=1 #support of repeats reads implies => unalignment

confidence = float (supXY) / float (supX)
print 'repeats => unalignment', confidence, supXY, supX


supX = 0
supXY =0
confidence = 0     
for line in open ('abundance.low'):
       name = line
       supX +=1  #support of low abundance reads
       if name in un:
             supXY +=1 #support of low abundance reads implies => unalignment

confidence = float (supXY) / float (supX)
print 'low abundance => unalignment', confidence, supXY, supX 

supX = 0
supXY =0
confidence = 0
for line in open ('coverage.low'):
       name = line.split('-')
       name = name[0]
       supX +=1  #support of low coverage reads
       if name in un:
             supXY +=1 #support of low abundance reads implies => unalignment

confidence = float (supXY) / float (supX)
print 'low coverage => unalignment', confidence, supXY, supX 
