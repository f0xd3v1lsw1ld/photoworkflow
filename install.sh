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

#please don't change, if so you should change it also in the other files
install_path="/opt/photoworkflow"

# Make sure only root can run our script
if [ $EUID -ne 0 ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
# check install dir exists, if not create it
if [ ! -d $install_path ]; then
  mkdir $install_path
fi

#check if exiftool is installed, if not install it
#from https://stackoverflow.com/questions/1298066/check-if-a-package-is-installed-and-then-install-it-if-its-not
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' libimage-exiftool-perl|grep "install ok installed")
echo Checking for libimage-exiftool-perl: $PKG_OK
if [ "" = "$PKG_OK" ]; then
  echo "libimage-exiftool-perl not found, try to install it"
  sudo apt-get install libimage-exiftool-perl
fi

#install scripts
install "install.sh" $install_path
install "photoworkflow.sh" $install_path
install "schema.sql" $install_path
install "workflow.py" $install_path

#create symlink to photoworkflow script
if [ ! -L "/usr/bin/photoworkflow" ]; then
    ln -s $install_path/photoworkflow.sh /usr/bin/photoworkflow
fi
