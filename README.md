# ORION
Automated timelapse image capture and stacking for Raspberry Pi and the Pi camera

## Install

At minimum you need to know your decimal *latitude* and *longitude*. These are used to determine sunset/sunrise hours for your location. You can edit the `./data/settings.json` file by hand and insert those values under the *location* object.

From the command line run `./bin/install.pl` and be patient. The installer will download all necessary libraries.

## Run

From the command line run `./bin/orion.pl` and sit back. The program will run as daemon and will automatically perform all required tasks.

## Support

There are bound to be issues. Feel free to contact me with problems you might come accross.