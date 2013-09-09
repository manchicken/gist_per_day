#!/usr/bin/env python
import sys, getopt, csv, pprint
from pymongo import MongoClient
import threading
import time
import traceback
    
_THREAD_LIMIT = 10

print_lock = threading.Lock()

global_mongo = MongoClient(max_pool_size=_THREAD_LIMIT)

def usage(msg):
  if msg != None:
    print('\nError: {msg}'.format(msg=msg))
  
  print('\nUsage: {arg0} [options]\n'.format(arg0=sys.argv[0]))
  print('  Options:\n') 
  print('      -h ......................... Display this help message\n')
  print('      -f|--file=CSVFILE .......... The CSV file to load\n')
  print('      -m|--mongo=MONGOINSTANCE ... The mongo instance to load the file into\n')
  sys.exit(0)

def add_record_to_mongo(record,mongo):
  print('CALLED!')
  print('Load a record!\n')
  pprint.pprint(record)
  
  try:
    global_mongo.start_request()
    
    pprint.pprint(mongo)
    
    mydb = global_mongo[mongo['db']]
    mycoll = mydb[mongo['coll']]
    
    global_mongo.end_request()
    
    # Now let's insert  
    print 'DB: {db} and COLL: {coll}'.format(db=mydb,coll=mycoll)
    mycoll.insert(record)
  except:
    traceback.print_exc()

def run_record(incsv, mongo):
  with print_lock: print('Starting thread...')
  
  parsed = csv.DictReader(incsv, delimiter=',', quotechar='"')
  for record in parsed:
    with print_lock: add_record_to_mongo(record, mongo)

def run_csv_file(csvfile, mongo):
  tsem = threading.Semaphore(value=_THREAD_LIMIT)
  all_threads = []
  
  print('Gonna load the CSV file "{csvfile}" into mongodb "{mongo}"\n'.format(csvfile=csvfile, mongo=mongo))
  with open(csvfile,'rb') as incsv:
    with tsem:
      with print_lock: print 'Thread is available...'
      t = threading.Thread(target=run_record, args=(incsv,mongo))
      t.run()
      all_threads.append(t)
  
  # Join all threads
  for t in all_threads:
    if t.isAlive(): t.join()

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

  mongo_bits = mongo.split('.')
  if len(mongo_bits) != 2: usage('Mongo Instance format: DBNAME.COLLECTIONNAME')
  mongo_info = dict(db=mongo_bits[0], coll=mongo_bits[1])

  run_csv_file(csvfile, mongo_info)

if __name__ == '__main__':
  main(sys.argv[1:])
