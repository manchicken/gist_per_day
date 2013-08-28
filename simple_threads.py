#!/usr/bin/env python

import sys
import threading

def process_number(func,input_list):
  print 'foo!'
  x = 0
  n = 0
  for one in input_list:
    n = n + 1
    x = func(x, n, one)
  
  print "Done, result: {answer}".format(answer=x)


def main(argv):
  numlist = [5,6,4,5,2,5,6,7,4,5]
  print 'Doin\' it!'
  avgthread = threading.Thread(target=process_number, args=(lambda p,n,x: float(((p*(n-1))+x)/n), numlist))
  sumthread = threading.Thread(target=process_number, args=(lambda p,n,x: (p+x), numlist))
  
  avgthread.start()
  sumthread.start()
  avgthread.join()
  sumthread.join()
  print 'Did it!'

if __name__ == '__main__':
  main(sys.argv[1:])
