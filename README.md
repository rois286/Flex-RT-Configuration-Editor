# Flex-RT-Configuration-Editor
Edit WinCC flexible RT Modules FWX Binary files (PDATA.FWX)

Written in R programming language.

First purpose is to extract the Tag names in order to be able to monitor them with MWSL (MiniWeb Server Language) tags.
There is already an app, which can export all tags to Excel file, called FlexRT at https://megaupload.nz/P0ofc9qcbc/FlexRT_rar, but it is not updated, and no source of it is found.

**Usage for exporting tags into HTML**

1. Download the freeware [R-Studio](https://www.rstudio.com) for easy activation of this script
1. Open the `FlexRTHTML.Rmd` R markdown file
1. Change `fwx.name` to be the name (including path) of the fwx configuration file to parse
1. Change `fwx.html` to be the name (including path) of the html page to create with names of all the tags inside the `fwx.name` FWX file
1. Run this script (Ctrl+Alt+R)
1. Copy the generated `fwx.html` file to the HMI device. Either by using network share or by uploading it thru the web interface (WWW-ROOT).

**Usage for exporting languages into Excel**

1. Download the freeware [R-Studio](https://www.rstudio.com) for easy activation of this script
1. Open the `FlexRTLang.Rmd` R markdown file
1. Change `fwx.name` to be the name (including path) of the fwx configuration file to parse
1. Change `fwx.xlsx` to be the name (including path) of the Excel file to create with all dictionary values inside the `fwx.name` FWX file
1. Run this script (Ctrl+Alt+R)
1. Open the `fwx.xlsx` with Excel, each language code will have its own sheet (0x409 - English, 0x407 - German, 0x40d - Hebrew)

**Background**

At our Ben-Gurion University of the Negev (BGU) we have a *Labmaster 20G* Glove Box (GB) with Nitrogen environment. It has a Human Machine Interface (HMI) which controls the GB.

This controller is called *SIEMENS SIMATIC HMI TP 177B 6" PN/DP*, which means it has a 6 in. color screen.

One day the screen blacked out. After checking it we saw that only the backlit is gone, because if we juxtaposition a cellphone light to it - we can see the contents of the screen clearly. That prodded us into finding other ways to communicate with the TP (Touch Panel) than its own interface screen.

By inspecting the device further we noticed an RJ45 connector (Ethernet), thus we took a cross cable ethernet connected it to a Personal Computer (aka host computer), setup a static IP for the device (192.168.1.xxx), but we couldn't connect.

Tried running [Advanced Port Scanner](http://www.advanced-port-scanner.com) to skim thru available ports, and found out that only Telnet (port 23) is open.

This allowed us to connect with [Putty](https://putty.org), and transfer files to and from the host computer by the following means:

1. We used a Windows XP host PC called `GloveBox`
1. Created a shared directory on the PC called `Simatic` with user `simatic` and password `12345678`
1. Run the following command in the putty of the Touch Panel: `net use PC \\GloveBox\Simatic /user:simatic`
    * Note 1: An IP cannot be used for the share name, it will not work and will return `Status 53`
    * Note 2: The term `PC` is just a name and can be anything. The term `GloveBox` is the name of the host computer.
1. A pop up screen will appear on the panel. Here you need to put the user/password of the share (`simatic / 12345678`)
1. It will create automatically a directory called `PC` under `\Network` folder in the device.
1. We copied the executable file from `\Flash\simatic` called `HmiRTm.exe` to the host PC, right clicked -> Properties, and saw the following details:
    * File version: `7.4.100.67`
    * Product name: `WinCC flexible RT`
    * Production version: `2008 SP1`
1. We got a development environment of Siemens SIMATIC WinCC flexible 2008 SP1, and copied three files back to `\Flash\simatic`:
    * `SmartServer.exe`
    * `ljpgce.dll`
    * `SmartServer.rld`
1. Rebooted the device, and now we had an editional [VNC](https://www.realvnc.com) port.
1. We installed VNC client on the host computer, connected to the device (192.168.1.xxx), and used the default password `100`. This way we could see the device despite the blacked-out screen.
1. And now, we got greedy and wanted not just to be able to watch the screen remotely, but also to be able to monitor the data (H2O and O2), which led us to this project.
    * Note 1: [Soap](https://en.wikipedia.org/wiki/SOAP) did not work, the link http://192.168.1.xxx/soap/RuntimeAccess?wsdl returned nothing, because we didn't have HTML support.
    * Note 2: Copying all the files to support HTML / HTTP (`Miniweb.exe, SystemData.zip, Templates.zip, WwwSiemens.dll, HmiWebLink.dll, SOAP.dll, RuntimeAccess_SOAP.dll, DeviceInfo.xml, UserdatabaseEdt.exe`) did not work because the `FWX` does not support html. Yet this enabled port 80 and the web interface which allows uploading files thru the `WWW-ROOT` directory, after login in with Administrator/100.
    * Note 3: Injecting `WEBLINK` and `FUNC_STARTPROC` tables into the `FWX` file to support HTML / HTTP did not work on the Touch Panel, and returned the message: **SIMATIC WinCC flexible Runtime**: *The "\\Flash\\Simatic\\PDATA.FWX" configuration file could not be loaded. The application will be terminated.*
    * Note 4: The above injection worked on Windows XP and enabled reading all the tags thru MiniWeb Server Language (MWSL). Yet the [Soap](https://en.wikipedia.org/wiki/SOAP) did not work, not with the [VBA](https://en.wikipedia.org/wiki/Visual_Basic_for_Applications) of [Excel](https://en.wikipedia.org/wiki/Microsoft_Excel) and not with [SoapUI](https://www.soapui.org), both of which returned `ERROR - Runtime is offline`.
    * Note 5: If it works on WinXP then maybe upgrading the TP will enable it. Thus it is worth a try, backing up the device with [ProSave](https://support.industry.siemens.com/cs/document/10347815/servicetool-simatic-prosave?dti=0&lc=en-WW), upgrading the OS, and retry this injection method. Yet we still are intimidated by this method.

For the moment, possible scenarios are:

1. Maybe there is an option to create a Recipe and export it with ProSave (the web interface just wrote `Runtime is offline`).
1. Purchase an RS-485 serial port for the PC and connect to the S7 directly thru Windows XP which can be monitored by MWSL HTML tags (after injection of the WEBLINK table).
1. Capture the screen with [VNC](https://en.wikipedia.org/wiki/Virtual_Network_Computing) and do [OCR](https://en.wikipedia.org/wiki/Optical_character_recognition). Cons: there are different screens which require different OCR methods, and sometimes we can be inside a screen which does not show the O2/H2O measurements.
1. Use some kind of serial port sniffer, because the HMI is connected thru RS-485 serial port to the S7 computer, thus something like [IO Ninja](https://ioninja.com) can be suitable to sniff the datagrams. Cons: It costs money, and if it'll break down - we have to disassemble it because it'll interrupt the communication.

And for the screen:

* We checked the spec of the TP screen, called `SX14Q006 REV. D`, its MTBF is 50,000 hours thus every 5.7 years it will need a replacement.
* We ordered the same screen online, but got Revision B instead of D, we're not sure if the revision is the problem or the screen was faulty, but only half of the upper screen worked.
* Thus, we disassembled the backlit from the new screen (REV. B) and put it in the original screen (REV. D) and it worked as before.

**TODO**

- [X] Export all tags to HTML file with MWSL tags to extract variable (tags) values
- [ ] Add WEBLINK and FUNC_STARTPROC in order for the configuration to reveal its tags in HTML (and maybe SOAP/HTTP)
- [ ] Export the entire configuration file (PDATA.FWX) to excel in order to be able to edit it and reconstruct it back. For the purpose of editing new languages.
