#!/bin/bash

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

#Directory in which the new images are imported
#CHANGE this to your path
working_dir=/media/noopi/Data/Bilder/DigiCam
#working_dir=/home/$USER/pictures/
#working_dir=/home/$USER/Bilder
#photoworkflow user dir, here are the database and the temporary files stored
home_dir=/home/$USER/.photoworkflow

#error log file
timestamp=$(date +"%Y.%m.%d-%H:%M:%S")
error_file=$home_dir/$timestamp"_error.log"

#check, if working_dir exists, if not exit
if [ ! -d $working_dir ]
 then
    echo "ERROR: $working_dir doesn't exists!"
    exit -1
 fi

#loop over image file extensions
#CHANGE this to for your images
for ext in jpg JPG CR2 cr2; do
  #count all images with the selected extensions
  count=`ls -1 *.$ext 2>/dev/null | wc -l`
  if [ $count != 0 ]
    then
      echo $count $ext " files to proceed "
      # if there are files with this extension, check if this files were already imported (md5 sum is in database)
      # the newfiles were copied in the temporary directory, to be found here: $home_dir

      python /opt/photoworkflow/workflow.py -t $ext -d "$PWD"

      if [ -f $home_dir/newfile ]
        then
          #go in the temporary directory
          pushd $home_dir &>/dev/null

          #rename the newfiles with exiftool
          echo "rename new images"
          exiftool -m "-filename<DateTimeOriginal" -d IMG_%Y-%m-%d-%H_%M_%S%%-c.%%le -progress *.$ext
                  
          #move newfiles with exiftool in your directory structure, change file extension to lower case
          echo "move new images to: "$working_dir
          exiftool -m '-Directory<DateTimeOriginal' -d "$working_dir/%Y/%Y-%m-%d" -progress *.${ext,,} 2>$error_file
          rm $home_dir/newfile
          popd &>/dev/null

        else
          # there are files with this extension, but this files were already imported
          echo "no new images to proceed"
        fi
  fi
done

#cleanup
pushd $home_dir &>/dev/null
count=`ls -1 *.$ext 2>/dev/null | wc -l`
if [ $count != 0 ]
  then
  #rm all *.jpg files in temp directory
  #these are files, exiftool found an error during moving to new directory, because these files exist already
  rm *.jpg
fi
popd &>/dev/null
