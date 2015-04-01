#!/usr/bin/python

import sys
import time
import datetime

def main(argv):
   metric = "crimes.per.day"
   tag = "city=chicago"

   try:
      cur_key = None
      count = 0
      for line in sys.stdin:
         line.strip()
         key = line.split('\t')[0]
         val = line.split('\t')[1]

         if cur_key == key:
            count += 1

         if cur_key is None:
            cur_key = key
            count = 1

         if key != cur_key:
            print "%s %s %s %s" % (metric, cur_key, count, tag)
            count = 1
            cur_key = key

      print "%s %s %s %s" % (metric, cur_key, count, tag)

   except "end of file":
      return None

if __name__ == '__main__':
   main(sys.argv)
