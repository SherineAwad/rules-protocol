#! /usr/bin/env python
import sys
import screed

sup_qc = 0
sup_abun = 0
sup_repeats = 0
sup_cov = 0

qc = set ()
abundance = set () 
repeats = set ()
coverage = set ()

sup_qc_abun = 0
sup_qc_cov = 0
sup_qc_repeats = 0
sup_abun_cov = 0
sup_cov_repeats = 0
sup_abun_repeats = 0


for line in open ('qc.low'): 
       name = line.split('-')
       name = name[0]
       sup_qc += 1
       qc.add(name[0]) 

for line in open ('abundance.low'): 
      name = line.split('-') 
      name = name[0]
      sup_abun += 1
      abundance.add(name[0])
      if name[0] in qc: 
           sup_qc_abun +=1 
       

for line in open ('coverage.low'):
      sup_cov += 1
      coverage.add(line)
      if line in qc: 
          sup_qc_cov +=1 
      if line in abundance :
         sup_abun_cov += 1
 
for line in open ('repeats.low'): 
      sup_repeats += 1     
      repeats.add(line)
      if line in qc: 
          sup_qc_repeats +=1
      if line in abundance: 
         sup_abun_repeats +=1 
      if line in coverage :
         sup_cov_repeats += 1      

print 'Support of low quality reads is', sup_qc ,'\nSupport of low abundance reads is ', sup_abun, '\n'

print 'Support of low quality and low abundance reads is ',  sup_qc_abun
        
print 'Support of low quality and low coverage reads is ',  sup_qc_cov 

print 'Support of low abundnce and low coverage  is ',  sup_abun_cov

print 'Support of low abundance reads and repeats is ',  sup_abun_repeats

print 'Support of low coverage and repeats is ',  sup_cov_repeats
