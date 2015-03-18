#! /usr/bin/env python
import sys
import screed

sup_qc = 0
sup_abun = 0
sup_repeats = 0
sup_cov = 0

qc = set ()
abundance = set() 
repeats = set()
coverage = set()
qc_abun = set() 
qc_cov = set()
qc_repeats = set()
abun_cov = set()
abun_repeats = set()
cov_repeats = set()

qc_abun_repeat = set()
qc_abun_cov = set ()
abun_cov_repeat = set ()
qc_cov_repeat = set ()


for line in open ('qc.low'): 
       name = line.split('-')
       name = name[0]
       qc.add(name) 

for line in open ('abundance.low'): 
      name = line.split('-') 
      name = name[0]
      abundance.add(name)

for line in open ('coverage.low'):
      coverage.add(line)
 
for line in open ('repeats.low'): 
      repeats.add(line)

qc_abun = qc.intersection(abundance) 
qc_cov = qc.intersection(coverage) 
qc_repeats = qc.intersection(repeats) 
abun_cov = abundance.intersection (coverage) 
abun_repeats = abundance.intersection(repeats)
cov_repeats = coverage.intersection(repeats)

qc_abun_repeat = qc_abun.intersection(repeats) 
qc_abun_cov = qc_abun.intersection(coverage) 
abun_cov_repeat = abun_cov.intersection(repeats) 
qc_cov_repeat = qc_cov.intersection(repeats) 


print 'Support of low quality and abundance is', len(qc_abun) 
print 'Support of low quality and coverage is', len(qc_cov)
print 'Support of low quality and repeats is', len(qc_repeats) 
print 'Support of low abundance and coverage is ', len(abun_cov) 
print 'Support of low abundance and repeats is', len(abun_repeats) 
print 'Support of low coverage and repeats is', len(cov_repeats)

print 'Support of low quality, abundance, and repeats is ', len(qc_abun_repeat) 
print 'Support of low quality, abundance, and coverage is ', len(qc_abun_cov) 
print 'Support of low abundance, coverage, and repeats is', len(abun_cov_repeat) 
print 'Support of low quality, coverage, and repeats is',  len(qc_cov_repeat) 
