##########################################################
### This script will explode FWX file into directories ###
###   every element of the TOC will be its own dir.    ###
###   inside every dir will be all sub elements        ###
##########################################################

# name if input FWX configuration file
fwx.name <- "G:/Documents and Settings/WinXP/My Documents/simatic/PDATA.fwx"
# location of directory to extract FWX to
fwx.dir <- "G:/Documents and Settings/WinXP/My Documents/simatic/pdata"

# extract the basic information
library(knitr)
source(purl('FlexRT.rmd', output = tempfile()))

# function to create a directory if doesn't exist
make_dir <- function(dir_name) {
  # append `dir_name` to the base directory
  subDir <- file.path(fwx.dir,dir_name)

  # create directory recursively if doesn't exist
  if (!dir.exists(subDir)) dir.create(subDir, recursive = TRUE, showWarnings = FALSE)
  # move to it
  setwd(subDir)
}

# convert a set of bytes to hexdecimal values
to_hex <- function(offset, length) {
  # convert raw data to integers
  ints <- as.integer(fwx.data[(offset+1):(offset+length)])
  
  # convert integers to hexadecimal
  hex <- as.hexmode(ints)
  
  # format hex decimal numbers to fixed length of 2
  fixed <- format(hex, width=2)
  
  # convert all the hexdecimal digits into a single string
  # format it with spaces between them
  paste(fixed, collapse=' ')
}

# save current working directory
cur_dir <- getwd()

# loop thru all TOC entries
for (i in 1:nrow(toc.entries)) {
  # get current TOC entry
  entry <- toc.entries[i,]
  
  # display message on what are we working
  print(paste0(entry$name,' (',round(100*i/nrow(toc.entries),2),'%)'))
  
  # get ID as hex to become the name of its directory along with the TOC entry name
  dir_name <- paste('0x',as.hexmode(entry$id),'_',entry$name,sep='')
  
  # create the directory if doesn't already exist
  make_dir(dir_name)
  
  # save the 0x34 bytes header of the entry
  header <- to_hex(entry$offset, 0x34)
  # current working directory is under the name of the entry
  cat(header, file='header.hex.txt')
  
  # extract all elements inside this entry into their own files
  total <- entry$entries
  # data block start
  data_block_start <- entry$offset + 0x34 + total*4
  for (j in 1:total) {
    offset_location <- entry$offset + 0x34 + (j-1)*4
    
    # relative offset of current item (from the beginning of data block)
    relative_offset <- d4(offset_location)
    
    # item start
    item_offset <- data_block_start + relative_offset
    
    # item size
    if (j < total-1) {
      # get next item offset (same algorithm as above thus do not explain it again)
      next_offset_location <- entry$offset + 0x34 + j*4
      next_relative_offset <- d4(next_offset_location)
      next_item_offset <- data_block_start + next_relative_offset
      
      item_length <- next_item_offset - item_offset
    } else {
      # calculate item size according to entire object size
      item_length <- (entry$offset + entry$item_size) - item_offset
    }
    
    # file name will be index out total entries
    file_name <- paste0(j,'_',total,'.hex.txt')
    
    # save binary data of entries as hex
    hex_data <- to_hex(item_offset, item_length)
    cat(hex_data, file=file_name)
  }
}

# go back to the original working directory (or click in the file section on More->Set As Working Diretory...)
setwd(cur_dir)
