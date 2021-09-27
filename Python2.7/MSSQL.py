#!/usr/bin/env python
# -*- coding: utf-8 -*-

##Info Script
"""Class Object Definition to get data from SQL Server Database
   
   Instructions after start using this script:
   1. Must install pyodbc library using pip
     pip install pyodbc
   2. Download SQL Server Driver. Caution: Set ubuntu correct version
     curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
     curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
     sudo apt-get update
     sudo ACCEPT_EULA=Y apt-get install -y msodbcsql17
     sudo ACCEPT_EULA=Y apt-get install -y mssql-tools
     echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
     source ~/.bashrc
     sudo apt-get install -y unixodbc-dev
   3. Import doQuery library or DataBase Class
     import doQuery /// from doQuery import (DataBase)
   4. Enjoy!

   Example of use:
     import pyodbc
     from MSSQL import (DataBase)
     dbCon = DataBase('servername.domain.com','database_name')
     dbCon.connectDB()
     row = (dbCon.cursor.execute("SELECT GETDATE() DateToday").fetchone())[0]
     print(row)
"""

__author__     = "Óscar Núñez Hernández"
__copyright__  = "Copyright 2021, MSSQL Reader Project"
#__credits__    = ["Person1", "Person2",
#                    "Person3"]
__license__    = "GPL"
__version__    = "1.0.1"
__maintainer__ = "Óscar Núñez Hernández"
__email__      = "net.oscar.nunez@outlook.com"
__status__     = "Production"

##Start Script

#3rd party libraries
import pyodbc

#Class Definition
class DataBase:
  def __init__(self, dbsrv, dbname):
    self.dbsrv  = dbsrv
    self.dbname = dbname

  def connectDB(self):
    dburl = 'tcp:'+self.dbsrv
    dbname = self.dbname
    user = 'YourUserName'
    passwd = 'YourPassword'
    self.connection = pyodbc.connect(
     'DRIVER={ODBC Driver 17 for SQL Server};SERVER=' + dburl + ';DATABASE=' + dbname + ';UID=' + user + ';PWD=' + passwd
    )
    self.cursor = self.connection.cursor()
