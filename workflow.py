#!/usr/bin/python

#######################################################################################################################################################################
#The MIT License (MIT)
#Copyright (c) Copyright 2016, f0xd3v1lsw1ld@gmail.com
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
#to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
#and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#######################################################################################################################################################################

import os
import os.path
import hashlib
import sys
import sqlite3
import argparse
import shutil

#methode to calculate md5sum of a given file
#return te md5sum as string or 0
def getMd5Sum(_file):
    # init hashlib to calculate md5
    md5_returned = hashlib.md5()
    blocksize = 2 ** 20
    try:
        # Open,close, read file and calculate MD5 on its contents
        with open(_file, "rb") as file_to_check:
            while True:
                # read contents of the file
                data = file_to_check.read(blocksize)
                if not data:
                    break
                # pipe contents of the file through
                md5_returned.update(data)
            # return calculated md5
            return str(md5_returned.hexdigest())
    except IOError:
        print ("Error opening " + file_name)
        return 0

#methode to check if a given md5sum is already in the database
#if not, it will be insert
#return True if it's in the database, False otherwise
def inDatabase(_db_filename, _md5):
    try:
        with sqlite3.connect(_db_filename) as conn:
            data = conn.execute("SELECT * FROM tblmd5sum WHERE md5sum == '%s'" % _md5)
            result = data.fetchone()
            if result is not None:
                return True
            else:
                conn.execute("INSERT OR IGNORE INTO tblmd5sum (md5sum) VALUES(?)", (_md5,))
                conn.commit()
                return False
    except Exception as e:
        print(e)
        return False

#methode to copy given file in the given directory
#return True if successful, False if not
def copyFileInWrkDir(_file, _dir):
    try:
        shutil.copy2(_file, _dir)
        return True
    except Exception as e:
        print(e)
        return False

#main methode
#handles input parameter for file extension and temporary Working directory
#creates database, if it not exists
#main loop:
#         - loop over all files with given extension
#         - calc their md5sum and check if these are already in the database
#         - if not, copy this files in the temporary Working directory and print the filename
def main():
    parser = argparse.ArgumentParser(description='Photo import workflow')
    parser.add_argument('-t', action="store", dest='type', default="JPG", help='Select image type, i.e. JPG, CR2..')
    parser.add_argument('-d', action="store", dest="dir", default=".", help='Path to temporary Working directory')

    results = parser.parse_args()
    pathname = os.path.dirname(sys.argv[0])
    home_dir = os.path.expanduser('~') + "/.photoworkflow/"

    db_filename = home_dir + 'pictures.db'
    schema_filename = pathname + '/schema.sql'

    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(-1)

    if not os.path.exists(home_dir):
        try:
            print("create dir %s" % home_dir)
            os.makedirs(home_dir)
        except Exception as e:
            print(e)
            return

    db_is_new = os.path.exists(db_filename)

    if db_is_new == False:
        try:
            with sqlite3.connect(db_filename) as conn:
                # print ('Creating schema')
                with open(schema_filename, 'rt') as f:
                    schema = f.read()
                conn.executescript(schema)
        except Exception as e:
            print(e)
            return

    # get all files of type results.type of directory results.dir
    files = [f for f in os.listdir(results.dir) if f.endswith("." + results.type) and os.path.isfile(os.path.join(results.dir, f))]
    # get number of found files
    file_counter = len(files)
    print("Step 1: calculate checksum and lookup in database")
    #print("proceed %i files" % file_counter)

    # setup progress bar from https://stackoverflow.com/questions/3160699/python-progress-bar
    #sys.stdout.write("[%s]" % (" " * file_counter))
    #sys.stdout.flush()
    # after '[' return to start of line
    #sys.stdout.write("\b" * (file_counter + 1))

    # proceed all found files
    cnt_file = 1
    for file in files:
        md5 = getMd5Sum(results.dir + '/' + file)
        entry = inDatabase(db_filename, md5)
        #sys.stdout.write("-")
        #sys.stdout.flush()
        # 2016.07.16 https://stackoverflow.com/questions/517127/how-do-i-write-output-in-same-place-on-the-console
        sys.stdout.write("progress [%d / %d]   \r" % (cnt_file, file_counter) )
        sys.stdout.flush()
        cnt_file = cnt_file + 1
        if entry == False:
            copyFileInWrkDir(results.dir + '/' + file, home_dir)
            if not os.path.isfile(home_dir + '/' + "newfile"):
                open(home_dir + '/' + "newfile", 'a').close()

    sys.stdout.write("\n")


if __name__ == '__main__':
    main()
