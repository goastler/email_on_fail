# email_on_fail

This script and systemd service aims to execute a command / script and then email on a non-zero exit code. The script will continue running until the email is send successfully, i.e. wait until there's a network connection.

This is paired with a systemd service and timer for providing periodic checks.

## Motivation

I needed a method of checking if encrypted drives have been mounted. They may become unmounted if a) the machine reboots (e.g. powercut) or b) I executed a poorly thought out command on the server and accidentally / unknowingly unmount them. When the drives are unmounted most of my services fail to run, as there's no where to put data. This is logged, but I don't babysit the logs, so an email notification is more useful. Upon receiving the email I can mount the drives manually.

## Setup on arch linux (adjust as required for other distros)
1. Adjust the command to run in the systemd service (and service / timer name if you like)
1. Copy systemd service and timer onto your machine
1. Copy the script onto your machine
2. Edit .mailrc to configure SMTP servers and the sending account. Currently, this is configured for a gmail address.
3. Copy .mailrc to /root (the service runs by default as root, so the mail config needs to be in root's home dir). Alternatively, you can put .mailrc in your home directory (/home/<username>) and run the systemd service as your user. I prefer to configure the root user's mail config so all system notification, from this service or otherwise, go to my email.
4. Start and enable the systemd timer
  - `sudo systemctl enable check_storage_mounted.timer`
  - `sudo systemctl start check_storage_mounted.timer`
  
## How does it work?
- Timer runs on system boot
- Timer kicks off the service every 24hrs
- Service runs the script
- Script runs the command, in this case checking if the encrypted drives are mounted
- If the command fails, the script then tries to send an email every 5 minutes until an email is sent successfully. This avoids cases where the network goes down and the email does not get sent. Note that if there is no network, the script will keep trying to email indefinitely. In this case, the systemd timer will timeout but *will not* run another instance of the service as one is already active.
