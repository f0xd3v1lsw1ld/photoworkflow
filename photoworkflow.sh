#/bin/bash

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

#loop over image file extensions
#CHANGE this to for your images
for ext in jpg JPG CR2 cr2; do
  #count all images with the selected extensions
  count=`ls -1 *.$ext 2>/dev/null | wc -l`
  if [ $count != 0 ]
    then
      echo $count $ext " files to proceed "
      # if there are files with this extension, check if this files were already imported (md5 sum is in database)
      # the newfiles were copied in the temporary directory, to be found here: /home/$USER/.photoworkflow
      newfiles=`python /opt/photoworkflow/workflow.py -t $ext -d "$PWD" 2>/dev/null | wc -l`

      if [ $newfiles != 0 ]
        then
          #go in the temporary directory
          pushd /home/$USER/.photoworkflow

          echo $newfiles" images to proceed"
          #rename the newfiles with exiftool
          exiftool -m "-filename<DateTimeOriginal" -d IMG_%Y-%m-%d-%H_%M_%S%%-c.%%le *.$ext

          #move newfiles with exiftool in your directory structure
          exiftool -m "-Directory<DateTimeOriginal" -d $working_dir"/%Y/%Y-%m-%d" *.$ext 2>/dev/null
          popd

        else
          # there are files with this extension, but this files were already imported
          echo "no new images to proceed"
        fi
   else
     # there are no files with this extension in the directory
     echo "no "$ext " files to proceed "
   fi
done
