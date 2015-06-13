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

supY = len(un)
print supY
supX = 0
supXY =0
confidence = 0

for line in open ('qc.low'): 
       name = line
       supX +=1  #support of low quality reads
       if name in un: 
   	     supXY +=1 #support of low quality reads implies => unalignment  
lift = float (supXY) / ( float(supX) * float (supY) )
confidence = float (supXY) / float (supX) 
conviction = float (1 - supXY) / float (1- confidence)
print 'Rule', 'Confidence', 'Lift','Conviction',  'SupXY', 'SupX', 'SupY'
print 'low quality => unalignment', confidence, lift, conviction,  supXY, supX, supY

supX = 0
supXY =0 
confidence = 0

for line in open ('repeats'):
       name = line
       supX +=1  #support of repeats reads
       if name in un:
             supXY +=1 #support of repeats reads implies => unalignment

confidence = float (supXY) / float (supX)
lift = float (supXY) / ( float (supX) * float (supY) ) 
conviction = float (1 - supXY) / float (1- confidence)
print 'repeats => unalignment', confidence, lift, conviction, supXY, supX, supY


supX = 0
supXY =0
confidence = 0     
for line in open ('abundance.low'):
       name = line
       supX +=1  #support of low abundance reads
       if name in un:
             supXY +=1 #support of low abundance reads implies => unalignment

lift = float (supXY) / ( float (supX) * float (supY) )
confidence = float (supXY) / float (supX)
conviction = float (1 - supXY) / float (1- confidence)
print 'low abundance => unalignment', confidence, lift, conviction, supXY, supX, supY 

supX = 0
supXY =0
confidence = 0
for line in open ('coverage.low'):
       name = line.split('-')
       name = name[0]
       supX +=1  #support of low coverage reads
       if name in un:
             supXY +=1 #support of low abundance reads implies => unalignment

lift = float (supXY) / ( float (supX) * float (supY) )
confidence = float (supXY) / float (supX)
conviction = float (1 - supXY) / float (1- confidence)
print 'low coverage => unalignment', confidence, lift, conviction, supXY, supX, supY
