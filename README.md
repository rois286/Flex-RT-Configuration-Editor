# Flex-RT-Configuration-Editor
Edit WinCC flexible RT Modules FWX Binary files

Written in R programming language.

First purpose is to extract the Tag names in order to be able to monitor them with MWSL (MiniWeb Server Language) tags.
There is already an app, which can export all tags to Excel file, called FlexRT at https://megaupload.nz/P0ofc9qcbc/FlexRT_rar, but it is not updated, and no source of it is found.

**Usage**

1. Download the freeware [R-Studio](https://www.rstudio.com) for easy activation of this script
1. Open the `FlexRT.Rmd` R markdown file
1. Change `fwx.name` to be the name (including path) of the fwx configuration file to parse
1. Change `fwx.html` to be the name (including path) of the html page to create with names of all the tags inside the `fwx.name` FWX file
1. Run this script (Ctrl+Alt+R)
1. Copy the generated `fwx.html` file to the HMI device. Either by using network share or by uploading it thru the web interface (WWW-ROOT).

**TODO**

- [X] Export all tags to HTML file with MWSL tags to extract variable (tags) values
- [] Add WEBLINK and FUNC_STARTPROC in order for the configuration to reveal its tags in HTML (and maybe SOAP/HTTP)
- [] Export the entire configuration file (PDATA.FWX) to excel in order to be able to edit it and reconstruct it back. For the purpose of editing new languages.