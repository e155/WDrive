# WDrive Setup Script

This PowerShell script automates the creation, mounting, and management of a virtual hard disk (VHDX) for development or production use. 
It can either create a new VHDX file and set it up as a drive, or copy an existing VHDX file, mount it, and make it available at system startup.

## Features

- **Automated Hyper-V setup check**: Installs and enables the Hyper-V feature if it’s not already enabled.
- **VHDX Creation and Mounting**:  
  - **Create Mode**:  
    - Creates a new dynamic VHDX file at a suitable location.  
    - Initializes, partitions, and formats the VHDX as ReFS with Dev Drive features.  
    - Assigns a drive letter (default: `W:`).  
    - Optionally copies a predefined bundle of files to the new drive.
  - **Copy Mode**:  
    - Copies an existing VHDX file from a source location.  
    - Mounts it and assigns the specified drive letter.
- **Automatic Remounting at Startup**:  
  Sets up a scheduled task that will mount the VHDX automatically on system startup.
  
- **Configurable Options**:  
  - **Drive Letter** (`$drvletter`): Default is `W`.  
  - **Mode** (`$Mode`): `Create` (default) or `Copy`.  
  - **Copy Source** (`$CopySource`): Location of the files to copy into the VHDX if needed.  
  - **Copy Bundle** (`$CopyBundle`): `Yes` or `No`. When `Yes`, files from `$CopySource` are copied to the newly created drive.  
  - **VHDX Size** (`$vhdSize`): Default is `51GB`.

## Parameters

- **$drvletter** (char, default = 'W')  
  Drive letter to assign to the mounted VHDX.

- **$Mode** (string, default = "Create")  
  - **Create**: Create and initialize a new VHDX.
  - **Copy**: Copy and mount an existing VHDX file.

- **$CopySource** (string, default = "\\\\yourserver\\share\\DiskWFiles\\*")  
  Source path for files to be copied into the newly created or mounted VHDX (used primarily in Create mode with `$CopyBundle = "Yes"`).

- **$CopyBundle** (string, default = "Yes")  
  When set to `Yes`, copies the contents of `$CopySource` to the newly created drive.

- **$vhdSize** (string, default = "51GB")  
  The size of the VHDX file to be created (if in Create mode).

## Process Overview

1. **Check Hyper-V Installation**:  
   If Hyper-V is not enabled, the script enables it. The system may require a reboot afterward.

2. **Determine VHDX Storage Location**:  
   The script looks for a suitable local drive (other than C:) with at least 10GB free space to store `Dev_DriveDLP.vhdx`. If none is found, it defaults to `C:\DevDrive\Dev_DriveDLP.vhdx`.

3. **Modes of Operation**:
   - **Create Mode**:  
     - Creates a new VHDX at the determined path.  
     - Mounts the VHDX.  
     - Initializes the disk, creates a partition, and formats it as ReFS with Dev Drive features.  
     - Assigns the chosen drive letter.  
     - If `$CopyBundle = "Yes"`, copies the files from `$CopySource` into the new drive.
   
   - **Copy Mode**:  
     - Copies a pre-existing VHDX from `$CopySource` to the determined path.  
     - Mounts the VHDX and assigns the chosen drive letter.

4. **Scheduled Task Setup**:  
   The script creates a scheduled task (`Mount Dev_Drive`) to automatically mount the VHDX at system startup.

5. **Enabling Performance Mode**:  
   Sets `Set-MpPreference -PerformanceModeStatus Enabled` for optimized performance.

## Usage

1. **Run in PowerShell**:  
   Open PowerShell with Administrator privileges.

2. **Execute the Script**:
   ```powershell
   .\DevDriveSetup.ps1 -Mode Create -CopyBundle Yes -vhdSize 60GB
