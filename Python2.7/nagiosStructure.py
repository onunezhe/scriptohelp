#!/usr/bin/env python
# -*- coding: utf-8 -*-

##Info Script
"""Script based on SQL Server and Python to monitor BI Compilation
   OK   return:
     print("OK - %s alarm text.") %(value)
     sys.exit(OK)
   WARN return:
     print("WARNING - %s alarm text.") %(value)
     sys.exit(WARNING)
   CRIT return:
     print("CRITICAL - %s alarm text.") %(value)
     sys.exit(CRITICAL)
   UNKN return:
     print("UNKNOWN - %s alarm text.") %(value)
     sys.exit(UNKNOWN)
"""

__author__     = "Óscar Núñez Hernández"
__copyright__  = "Copyright 2021, exampleProject"
__license__    = "GPL"
__version__    = "1.0.1"
__maintainer__ = "Óscar Núñez Hernández"
__email__      = "net.oscar.nunez@outlook.com"
__status__     = "Production"

##Start Script

#Standar libraries
import os
import sys
from datetime import (datetime)

#3rd party libraries

#Local source

#Nagios return codes
UNKNOWN  = -1
OK       = 0
WARNING  = 1
CRITICAL = 2

#Nagios Function Alarm
def get_alarm(errCode,errText):
  if errCode == OK:
    print(errText)
    sys.exit(OK)
  elif errCode == WARNING:
    sys.exit(WARNING)
  elif errCode == CRITICAL:
    print(errText)
    sys.exit(CRITICAL)
  else:
    print(errText)
    sys.exit(UNKNOWN)


if __name__ == "__main__":
  res = 1000
  hour = datetime.now().hour
  
  # Dissable check within 00.00 to 05.00
  if res == None and (hour >= 0 and hour < 5):
    get_alarm(UNKNOWN,"UNKNOWN - Between 0:00 and 05:00 can't be monitored")
  elif res == None and hour >= 5:
    get_alarm(CRITICAL,"CRITICAL - Compilation failed")
  else:
    get_alarm(OK,"OK - MESTRESv2 Compilated. %d Activas" %(res))
