# Virtual Machine Management Guide

This guide covers how to manage VMs using the libvirt module in this NixOS configuration.

## Table of Contents
- [Enabling VMs](#enabling-vms)
- [VM Configuration](#vm-configuration)
- [Starting VMs](#starting-vms)
- [Stopping VMs](#stopping-vms)
- [Destroying VMs](#destroying-vms)
- [When to Use Which Command](#when-to-use-which-command)
- [Managing ISO/CDROM](#managing-isocdrom)
- [Connecting to VMs](#connecting-to-vms)
- [Troubleshooting](#troubleshooting)

---

## Enabling VMs

### 1. Configure in flake.nix

Add the libvirt configuration to your system in `flake.nix`:

```nix
nixosConfigurations.homeserver = nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    ./system/homeserver/configuration.nix
    ./modules/default.nix
    
    {
      # Enable libvirt module
      myModules.libvirt = {
        enable = true;
        users = [ "samuel" ];  # Users who can manage VMs
        
        # Bridge networking (VMs get IPs from router)
        bridge = {
          enable = true;
          interface = "vmbr0";           # Bridge name
          physicalInterface = "enp2s0";  # Your physical network interface
        };
        
        # Define VMs
        vms = {
          ubuntu-vm = {
            name = "ubuntu-vm";
            memory = 4096;                # RAM in MB
            cpus = 4;                     # Number of CPUs
            diskSize = "100G";            # Disk size
            diskPath = "/data/vm/disk/ubuntu-vm.qcow2";  # Optional: custom disk path
            imagePath = "/data/vm/iso/ubuntu-24.04.3-live-server-amd64.iso";
            imageFormat = "iso";          # iso, qcow2, raw, or vmdk
            autostart = false;            # Start VM on boot
            bridgeInterface = "vmbr0";    # Network bridge to use
          };
        };
      };
    }
    
    sops-nix.nixosModules.sops
    home-manager.nixosModules.home-manager
  ];
};
```

### 2. Apply Configuration

```bash
cd ~/dotfiles
sudo nixos-rebuild switch --flake .#homeserver
```

### 3. Manually Define VM (First Time Only)

After the first `nixos-rebuild`, the VM disk is created but not defined. Run:

```bash
sudo bash /var/lib/libvirt/hooks/ubuntu-vm-activate.sh
```

This defines the VM in libvirt. Future rebuilds will handle this automatically.

---

## VM Configuration

### Image Formats

- **`iso`** (default): For installation ISOs. Creates empty disk + attaches ISO as CDROM.
- **`qcow2`**: For QEMU cloud images. Converts and resizes the image.
- **`raw`**: For raw disk images. Converts to qcow2.
- **`vmdk`**: For VMware images. Converts to qcow2.

### Example Configurations

**ISO Installation:**
```nix
ubuntu-vm = {
  name = "ubuntu-vm";
  memory = 4096;
  cpus = 4;
  diskSize = "50G";
  imagePath = "/data/isos/ubuntu-22.04-live-server-amd64.iso";
  imageFormat = "iso";
  autostart = false;
};
```

**Cloud Image:**
```nix
cloud-vm = {
  name = "cloud-vm";
  memory = 2048;
  cpus = 2;
  diskSize = "30G";
  imagePath = "/data/isos/ubuntu-22.04-server-cloudimg-amd64.img";
  imageFormat = "qcow2";
  autostart = true;
};
```

---

## Starting VMs

### Start a VM
```bash
sudo virsh start ubuntu-vm
```

### List All VMs (Running and Stopped)
```bash
sudo virsh list --all
```

### Auto-start on Boot
```bash
sudo virsh autostart ubuntu-vm
```

Or set `autostart = true;` in the VM configuration and rebuild.

---

## Stopping VMs

### Graceful Shutdown (Recommended)
Sends ACPI shutdown signal to the VM (like pressing power button):
```bash
sudo virsh shutdown ubuntu-vm
```

**Use when:**
- Normal shutdown
- You want the OS to shut down cleanly
- Saving data is important

**Wait time:** Can take 30 seconds to a few minutes depending on the VM.

### Check if VM is Stopped
```bash
sudo virsh list --all
```

---

## Destroying VMs

### Force Stop (Immediate)
Immediately powers off the VM (like pulling the power plug):
```bash
sudo virsh destroy ubuntu-vm
```

**Use when:**
- VM is frozen or not responding
- `shutdown` command doesn't work
- Emergency stop needed
- You don't care about unsaved data

**Warning:** May cause data loss or corruption!

### Delete VM Definition (Does NOT Delete Disk)
```bash
sudo virsh undefine ubuntu-vm
```

**Use when:**
- Removing VM completely
- Reconfiguring VM from scratch
- VM disk will remain at `/data/vm/disk/ubuntu-vm.qcow2`

### Delete VM and Disk
```bash
# Stop VM
sudo virsh destroy ubuntu-vm

# Remove VM definition
sudo virsh undefine ubuntu-vm

# Delete disk file
sudo rm /data/vm/disk/ubuntu-vm.qcow2
```

---

## When to Use Which Command

| Scenario | Command | Why |
|----------|---------|-----|
| Normal shutdown | `virsh shutdown` | Clean OS shutdown, saves data |
| VM not responding | `virsh destroy` | Immediate stop |
| Start VM | `virsh start` | Boot the VM |
| Auto-start on boot | `virsh autostart` | Automatic startup |
| After installation complete | Eject CDROM | Remove installation media |
| Reconfigure VM | `virsh undefine` then rebuild | Fresh VM definition |
| Remove VM completely | `destroy` + `undefine` + `rm disk` | Full cleanup |

---

## Managing ISO/CDROM

### Eject CDROM After Installation

After installing an OS from ISO, eject it so the VM boots from disk:

```bash
sudo virsh change-media ubuntu-vm sda --eject
```

**When to eject:**
- After completing OS installation
- VM keeps booting to installer
- "Failed unmounting cdrom.mount" errors

### Re-insert ISO
```bash
sudo virsh change-media ubuntu-vm sda /data/vm/iso/ubuntu-24.04.3-live-server-amd64.iso --insert
```

### View Current CDROM Status
```bash
sudo virsh domblklist ubuntu-vm
```

### Permanently Remove CDROM Device

Edit VM configuration:
```bash
sudo virsh edit ubuntu-vm
```

Find and delete the entire `<disk type='file' device='cdrom'>` section.

---

## Connecting to VMs

### From Homeserver (No GUI)

VMs are configured with SPICE graphics. Since the homeserver has no display:

**Option 1: From Windows/Linux Desktop with virt-viewer**
```bash
remote-viewer spice://HOMESERVER_IP:5900
```

**Option 2: SSH Tunnel (More Secure)**
```bash
# On your local machine:
ssh -L 5900:localhost:5900 samuel@homeserver

# Then connect to localhost:
remote-viewer spice://localhost:5900
```

### Via SSH (After OS Installation)

Once the VM is installed and has SSH enabled:
```bash
# Find VM's IP address
sudo virsh domifaddr ubuntu-vm

# SSH to the VM
ssh user@VM_IP_ADDRESS
```

### Using virt-manager

If you have X11 forwarding:
```bash
ssh -X samuel@homeserver
virt-manager
```

---

## Troubleshooting

### VM Won't Start

**Check VM status:**
```bash
sudo virsh list --all
```

**View VM info:**
```bash
sudo virsh dominfo ubuntu-vm
```

**Check libvirtd service:**
```bash
sudo systemctl status libvirtd
```

### VM Not Defined After Rebuild

Run the activation script manually:
```bash
sudo bash /var/lib/libvirt/hooks/ubuntu-vm-activate.sh
```

### Bridge Network Not Working

**Check bridge status:**
```bash
ip addr show vmbr0
brctl show vmbr0  # if bridge-utils installed
```

**Verify VM network:**
```bash
sudo virsh domiflist ubuntu-vm
```

### Can't Connect to SPICE

**Check SPICE port:**
```bash
sudo virsh domdisplay ubuntu-vm
```

**Check if VM is running:**
```bash
sudo virsh list
```

### Disk Space Issues

**Check VM disk usage:**
```bash
sudo qemu-img info /data/vm/disk/ubuntu-vm.qcow2
```

**Check actual disk size:**
```bash
du -h /data/vm/disk/ubuntu-vm.qcow2
```

### CDROM Mount Errors on Reboot

Eject the ISO:
```bash
sudo virsh change-media ubuntu-vm sda --eject
```

---

## Useful Commands Cheat Sheet

```bash
# List all VMs
sudo virsh list --all

# Start VM
sudo virsh start VM_NAME

# Stop VM (graceful)
sudo virsh shutdown VM_NAME

# Stop VM (force)
sudo virsh destroy VM_NAME

# VM info
sudo virsh dominfo VM_NAME

# VM network info
sudo virsh domifaddr VM_NAME

# Eject CDROM
sudo virsh change-media VM_NAME sda --eject

# Auto-start on boot
sudo virsh autostart VM_NAME

# Disable auto-start
sudo virsh autostart VM_NAME --disable

# View VM XML
sudo virsh dumpxml VM_NAME

# Edit VM config
sudo virsh edit VM_NAME

# Delete VM (keeps disk)
sudo virsh undefine VM_NAME

# View console
sudo virsh console VM_NAME  # Press Ctrl+] to exit

# Get SPICE connection
sudo virsh domdisplay VM_NAME
```

---

## Quick Start Example

```bash
# 1. Add VM to flake.nix (see above)

# 2. Apply configuration
cd ~/dotfiles
sudo nixos-rebuild switch --flake .#homeserver

# 3. Define VM (first time only)
sudo bash /var/lib/libvirt/hooks/ubuntu-vm-activate.sh

# 4. Start VM
sudo virsh start ubuntu-vm

# 5. Connect from Windows/Linux desktop
remote-viewer spice://HOMESERVER_IP:5900

# 6. Install OS from ISO

# 7. After installation, eject ISO
sudo virsh change-media ubuntu-vm sda --eject

# 8. Reboot VM
sudo virsh reboot ubuntu-vm

# 9. SSH to VM (if SSH was installed)
ssh user@VM_IP
```
