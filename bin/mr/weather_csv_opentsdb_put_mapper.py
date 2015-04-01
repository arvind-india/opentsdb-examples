#!/usr/bin/python

import sys
import time
import datetime

def convert_to_f(temp):

    print >> sys.stderr, temp

    try:
       int(temp)
    except ValueError:
       return int(0)

    if len(temp) == 1:
       temp = "10"

    ''' Handle negative temps '''
    if temp.startswith("-"):
       return int((160 - (float(temp[1:-1]) * 9)) / 5)

    return int(float(temp[0:-1]) * 9/5 + 32)

def main(argv):
    metric = "weather.daily"
    tag = "city=chicago"
    try:
        for line in sys.stdin:
            line.strip()
            if not line.startswith('STATION'):

                date = line.split(',')[2]
                year = int(date[0:4])
                month = int(date[4:6])
                day = int(date[6:8])
                epoch = int(time.mktime(datetime.datetime(year, month, day, 0, 0).timetuple()) * 1000)

                min_temp = convert_to_f(line.split(',')[-1].strip())
                max_temp = convert_to_f(line.split(',')[-2].strip())

                print "%s %s %s %s type=mintemp" % (metric, epoch, min_temp, tag)
                print "%s %s %s %s type=maxtemp" % (metric, epoch, max_temp, tag)

    except "end of file":
        return None

if __name__ == '__main__':
    main(sys.argv)
