#!/usr/bin/python

import sys
import time
import datetime

def main(argv):
    try:
        for line in sys.stdin:
            line.strip()
            if not line.startswith('ID'):

                date = line.split(',')[2].split()[0]
                year = int(date.split('/')[-1])
                day = int(date.split('/')[-2])
                month = int(date.split('/')[-3])

                epoch = int(time.mktime(datetime.datetime(year, month, day, 0, 0).timetuple()) * 1000)

                print "%s\t%s" % (epoch, 1)
    except "end of file":
        return None

if __name__ == '__main__':
    main(sys.argv)
