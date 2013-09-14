#!/usr/bin/env python

import sys
import pprint

available_bits = []

def find_next_bit(in_num):
  global available_bits

  for i in range(len(available_bits)):
    if (in_num & available_bits[-1-i]):
      return available_bits[-1-i]
  
  return 0

def do_proof(innum):
  present_bits = []
  left = innum
  while left > 0:
    result = find_next_bit(left)
    left -= result
    present_bits.append(result)
    pprint.pprint(present_bits)
  
  pprint.pprint(present_bits)
  return present_bits

def main(argv):
  if len(available_bits) == 0:
    for i in range(8):
      available_bits.append(1 << i)
  
  pprint.pprint(available_bits)

  num = int(argv[0])
  bits = do_proof(num)

  print 'Considering number {num}'.format(num=num)
  
  if len(bits) == 0:
    print 'No bits matching?!'
    return
  
  print 'Contains bits: '
  for bit in bits:
    print bit

if __name__ == '__main__':
  if len(sys.argv) <= 1:
    print 'Usage: {prog} INTEGER'.format(prog=sys.argv[0])
    sys.exit(0)
  
  main(sys.argv[1:])