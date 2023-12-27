# Block An Entire Folder In Windows Firewall With One Click
These scripts are used to block/unblock outgoing and incoming traffic for for all executables of any directory and its subdirectories using Windows Firewall. The success and failure of each operation are logged in the `firewall_changes.log` file. At the end, a summary is displayed of all operation. 


## [`FirewallBlocker.bat`](https://github.com/NE0ND3M0N/folder_firewall_blocker_script/blob/main/FirewallBlocker.bat)
This script blocks incoming and outgoing traffic for all `.exe` and `.dll` files in the current directory and its subdirectories. It checks if the script is running with administrator privileges, and if not, it prompts the user to run the script as an administrator.

The script iterates through all the `.exe` and `.dll` files, and for each file, it checks if a firewall rule already exists. If a rule exists, it logs an information message. If a rule does not exist, it adds a new firewall rule to block the traffic.

The success and failure of each operation are logged in the `firewall_changes.log` file. At the end, a summary is displayed showing the files for which traffic was successfully blocked, the files for which blocking failed, and the files for which rules already existed.

## [`FirewallUnblocker.bat`](https://github.com/NE0ND3M0N/folder_firewall_blocker_script/blob/main/FirewallUnblocker.bat)

This script is used to unblock the traffic for the files that were blocked by the [`FirewallBlocker.bat`](https://github.com/NE0ND3M0N/folder_firewall_blocker_script/blob/main/FirewallBlocker.bat) script.

## Requirements

These scripts require administrator privileges to run.

## How to use

To use the scripts, navigate to the folder you want to block and place the batch script at the root of the folder, then run the script as an administrator (right-click on the script and choose "Run as administrator"). 

Here's an example of how your folder structure should look:

```
folder_to_block
│
├── subfolder1
│   ├── file1.exe
│   └── file2.dll
│
├── subfolder2
│   ├── file3.exe
│   └── file4.dll
│
├── file5.exe
├── file6.dll
│
├── FirewallBlocker.bat
└── FirewallUnblocker.bat
```

In this example, running `FirewallBlocker.bat` will block traffic for `file1.exe`, `file2.dll`, `file3.exe`, `file4.dll`, `file5.exe`, and `file6.dll`.