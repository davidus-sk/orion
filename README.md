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

At minimum you need to know your decimal *latitude* and *longitude*. These are used to determine sunset/sunrise hours for your location. You can edit the `./data/settings.json` file by hand and insert those values under the *location* object or better yet, run the installer and follow simple steps.

From the command line run `sudo ./bin/install.pl` and enter your latitude, longitude and email address if you want to share your stacked images and be notified when stacking has completed. Be patient with the process. The installer will download all necessary libraries.

## How to use

From the command line run `sudo ./bin/orion.pl` and sit back. The program will run as daemon and will automatically perform all required tasks.

The program continuously captures images from sunset to sunrise and then it stacks them into one single JPEG image named `orion-YYYY-MM-DD.jpg` where *YYYY-MM-DD* is the day the image was rendered. Image stacking is a very intensive process and can take several hours to complete; the duration depends on number and size of images being stacked.

If you are running the default configuration and your Pi is connected to your network, you can access your stacked images at `http://<your Pi's address>/orion-YYYY-MM-DD.jpg`.

## Support

There are bound to be issues. Feel free to contact me with problems you might come across.
