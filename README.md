# ORION
Automated timelapse image capture and stacking for Raspberry Pi and the Pi camera

## Requirements

This is a simple projects and requires only few things:

* Raspberry Pi
* Pi camera connected to the Pi
* Access to the shell on the Pi
* Basic knowledge/ability to run shell commands
* Some kind of weatherproof housing for the Pi and the camera
* Internet connection

The housing is optional, but it will come in handy if you don't want to damage your Pi as it will have to be installed outside (to have a full view of the sky) and it will be exposed to the elements. There is no need for Internet connectivity while the Pi is imaging; it is needed only if you want to remotely view the results of ORION's work :)

## Installation

At minimum you need to know your decimal *latitude* and *longitude*. These are used to determine sunset/sunrise hours for your location. You can edit the `./data/settings.json` file by hand and insert those values under the *location* object.

From the command line run `./bin/install.pl` and be patient. The installer will download all necessary libraries.

## How to use

From the command line run `./bin/orion.pl` and sit back. The program will run as daemon and will automatically perform all required tasks.

## Support

There are bound to be issues. Feel free to contact me with problems you might come across.