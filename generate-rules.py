#! /usr/bin/env python
import sys
import screed

rules = {} 
sup_qc = 0
sup_abun = 0

sup_qc_abun =0

for line in open ('qc.low'): 
       name = line.split('-')
       name = name[0]
       sup_qc += 1
       if name in rules: 
             items = rules[name]
             items.join('quality')
             rules[name] = items
       else:
            items = 'quality' 
            rules[name] = items    

for line in open ('abundance.low'): 
      name = line.split('-') 
      name = name[0]
      sup_abun += 1
      if name in rules:
           rules[name] = 'quality and abundance'
           sup_qc_abun += 1 
             #item = rules[name]
            #item .join('abundance')
            #rules[name] = item

      else: 
            item = 'abundance'
	    rules[name] = item 

print 'Support of low quality reads is', sup_qc ,'\nSupport of low abundance reads is ', sup_abun, '\nSupport of low quality and low abundance reads is ',  sup_qc_abun
         

