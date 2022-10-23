# DMCA Link Grabber
This tool (for Windows users) is meant for cammers to generate a list of links for DMCA takedown purposes from the sites that have automated recording and publishing of shows. 

## Requirements
You need to enable execution of unsigned PowerShell scripts on your system to run this. This will mean that any downloaded PowerShell script will be able to run, and this has the same implication as being able to run any random `.exe` file you come across. If you are not comfortable with this, that's perfectly fine - feel free to ask more questions about it or simply do not use it.

### Steps
 1. Open a PowerShell prompt as Admin: Press `Win` + `X` -> select `Windows PowerShell (Admin)` (`Terminal (Admin)` on Windows 11)
 2. Paste in `Set-ExecutionPolicy unrestricted`
 3. Read the prompt, type `Y` and press `Enter` if you understand.

 ## Using the script
 1. Download the `.ps1` script from [the latest release](https://github.com/ellipsis2198/dmca-link-grabber/releases/latest)
 2. Find the downloaded file on your system (In Chrome, click the small arrow next to the filename in the bar that pops up along the bottom, then `Show in folder`).
 3. Right click the downloaded file in Windows Explorer and select `Run with PowerShell` 
 4. Type the username of the model and press `Enter`
 5. For each site where videos were found, a Save dialog will open - enter the desired name for the `.txt` document containing the offending links and save it. Repeat as necessary.

 ## Requesting support (e.g. for another site be added)
[Submit your request here](https://github.com/ellipsis2198/dmca-link-grabber/issues/new) with as many details as possible. *Please* make an issue if you've found a similar site that has your copyrighted content on it, and I'll try to add support quickly.
## Currently supported sites
### Misc
  * `recurbate.com`
  * `camstube.me`
  * `webcamrips.to`
  * `tstube.net`
### Shared backend #1
  * `savemycam.com`
  * `cbcamsclub.com`
  * `freecinemaclub.com`
  * `webcamrecs.com`
### Shared backend #2
#### These all use the same database and external filehost - the tool will get you the links from the backing filehost for a DMCA takedown, as well as the links from each of the frontends. 
  * `tsrecs.com`
  * `tscam.net`
  * `tsvideos.org`
  * `gayrecs.com`
  * `gaywebcamblog.com`
