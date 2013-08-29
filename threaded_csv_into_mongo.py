#!/usr/bin/env python
from __future__ import print_function

import sys, getopt, csv, pprint
from pymongo import MongoClient
import thread
import time
print = lambda x: sys.stdout.write("%s\n" % x)

_THREAD_LIMIT = 10

global_mongo = MongoClient(max_pool_size=_THREAD_LIMIT)
global_threadCount = 0

def usage(msg):
  if msg != None:
    print('\nError: {msg}'.format(msg=msg))
  
  print('\nUsage: {arg0} [options]\n'.format(arg0=sys.argv[0]))
  print('  Options:\n')
  print('      -h ......................... Display this help message\n')
  print('      -f|--file=CSVFILE .......... The CSV file to load\n')
  print('      -m|--mongo=MONGOINSTANCE ... The mongo instance to load the file into\n')
  sys.exit(0)

def add_record_to_mongo(mongo, record):
  global global_mongo
  print('CALLED!')
    
  mongo_bits = mongo.split('.')
  if len(mongo_bits) != 2: usage('Mongo Instance format: DBNAME.COLLECTIONNAME')
  mongo_db = mongo_bits[0]
  mongo_coll = mongo_bits[1]
  print('Load a record!\n')
  pprint.pprint(record)
  
#  try:
#    mydb = global_mongo[mongo_db]
#    mycoll = mydb[mongo_coll]
    
    # Now let's insert
#    print 'DB: {db} and COLL: {coll}'.format(db=mydb,coll=mycoll)
#    mycoll.insert(record)
#  except:
#    print "Unexpected error:", sys.exc_info()[0], " ", sys.stderr
  
#  mycoll.end_request()
  global_threadCount = global_threadCount - 1

def process_csv_line(record, mongo):
  global global_threadCount
  
  # Wait until we've got a free thread
  while (global_threadCount >= _THREAD_LIMIT):
    print('Sleeping while I wait for an open thread...')
    time.sleep(1)
  
  print('Starting thread...')
  global_threadCount = global_threadCount + 1
  foo = thread.start_new_thread(add_record_to_mongo, (mongo, record, ))
  foo.run()

def run_csv_file(csvfile, mongo):
  print('Gonna load the CSV file "{csvfile}" into mongodb "{mongo}"\n'.format(csvfile=csvfile, mongo=mongo))
  with open(csvfile,'rb') as incsv:
    parsed = csv.DictReader(incsv, delimiter=',', quotechar='"')
    for record in parsed:
      process_csv_line(record, mongo)

def main(argv):
  csvfile=None
  mongo=None

  try:
    opts, args = getopt.getopt(argv, 'hf:m:',['file=','mongo='])
  except getopt.GetoptError:
    usage(None)
  
  for one, arg in opts:
    if one == '-h':
      usage(None)
    elif one in ('-f','--file'):
      csvfile = arg
    elif one in ('-m','--mongo'):
      mongo = arg
  
  if csvfile == None: usage('Missing CSV file')
  if mongo == None: usage('Missing mongo')
  
  run_csv_file(csvfile, mongo)

if __name__ == '__main__':
  main(sys.argv[1:])
