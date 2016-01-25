# photoworkflow
workflow to import images from different sources into local photo collection

# content
| file name  | description |
| ------------- | ------------- |
| install.sh | script to install photoworkflow and exiftool |
| photoworkflow.sh  | script to execute the workflow  and call exiftool |
| workflow.py | python script to do background jobs (md5 calculation, sqlite, file copy) |
| schema.sql | sqlite database schema |
| LICENSE | MIT licence |

# customize
To customize photoworkflow, you can change the following variables:

1. path to install photoworkflow
  * file: **install.sh:**
  * install_path="/opt/photoworkflow"
  * *note: also change this inside photoworkflow.sh*

2. Directory in which the new images are imported 
  * file: **photoworkflow.sh**
  * working_dir=/home/$USER/pictures/
  
3. Specify file formats to import
  * default: only jpg and cr2 files are supported
  * file: **photoworkflow.sh**
  * append the loop `for ext in jpg JPG CR2 cr2; do`

# install

run install.sh as root to install photoworkflow into **/opt/photoworkflow** (default)

`$ sudo ./install.sh`

# workflow

1. open a terminal
2. change directory into import folder (where your new pictures are)
3. run photoworkflow   `$ photoworkflow`

**What happens inside photoworkflow**

1. The md5 sum of each image will be calculated.
2. If the result is in the database, the next image will be proceed, if not the image will be copied into the tmp dir (**default: /home/$USER/.photoworkflow**)
3. change dir into tmp dir
4. call exiftool to rename all images into: **IMG_%Y-%m-%d-%H_%M_%S%%-c.%%le**, based on the DateTimeOriginal
5. call exiftool to move all images into **$working_dir/%Y/%Y-%m-%d**, based on the DateTimeOriginal
6. cleanup tmp dir

* note: The database is stored in /home/$USER/.photoworkflow *
