# ISP Programmer for NXP Kinetis Microcontrollers (K32W061/K32W041)
Unfortunately NXP only provides a Windows Tool (DK6Programmer) for their Zigbee enabled Kinetis Processors K32W061/K32W041. But since the whole ISP Protocol is documentated inside the User Manual I have written ths small tool to use the ISP Interface for Programming the Flash.

I have used a [OM15080-K32W](https://www.nxp.com/products/wireless/bluetooth-low-energy/om15080-k32w-k32w-usb-dongle-for-bluetooth-le-zigbee-and-thread-networks:OM15080-K32W) for testing/implementing this tool. At the Moment it requires the RSTN Pin of the MCU to be connected to CBUS2 and PIO5 to CBUS3 of the FTDI Chip.

# How to build
## Prerequisits
To build this software you need

- cmake >= 3.7
- ninja
- g++/clang with C++14 Support (g++ >= 6.0 and clang >= 3.4)
- libFTDI >= 1.3
- Boost program_options >= 1.62
- Boost Log >= 1.62

To build/run unit tests you also need
- Googletest >= 1.8
- Googlemock >= 1.8

## Dependency Installation on Debian 9/10
To install all required packages run

    $ sudo apt update -qq && apt install cmake ninja-build g++ libftdi1-dev libboost-dev libboost-program-options-dev libboost-log-dev

## Dependency Installation on openSuse Tumbleweed
To install all required packages run

    $ sudo zypper refresh && sudo zypper install --no-confirm boost-devel ninja cmake gcc-c++ libftdi1-devel libboost_program_options-devel libboost_log-devel libboost_thread-devel

## Build
Building the Softweare is straight forward

    $ mkdir -p build
    $ cd build
    $ cmake -GNinja ..
    $ ninja
    $ ninja install

The Tool will be installed in `/usr/local/bin`. If you want to change that call cmake 

# How to use

Get Device Information

    $ sudo nxp-isp -d -i /dev/ttyUSB0 -v
    2020-12-22 11:45:14.037804 [info]: Open FTDI Device /dev/ttyUSB0
    2020-12-22 11:45:14.037979 [info]: Read PID from /sys/class/tty/ttyUSB0/../../../../idProduct
    2020-12-22 11:45:14.038059 [info]: Read VID from /sys/class/tty/ttyUSB0/../../../../idVendor
    2020-12-22 11:45:14.038117 [info]: VID/PID for /dev/ttyUSB0 are 0x403/0x6015
    2020-12-22 11:45:14.051651 [info]: Enable ISP Mode
    2020-12-22 11:45:14.051736 [info]: Set all CBUS Pins to Output:0
    2020-12-22 11:45:14.054703 [info]: Set CBUS Pin 2 to Output:1
    2020-12-22 11:45:14.066686 [info]: Disable CBUS Mode
    2020-12-22 11:45:14.077718 [info]: Send "Enable ISP Mode" request to device
    2020-12-22 11:45:14.098966 [info]: ISP Mode Enabled
    2020-12-22 11:45:14.099026 [info]: Read Device Info
    2020-12-22 11:45:14.099043 [info]: Get Device Information
    Found Chip K32W061
    Chip Version 0x140000cc

Erase all Flash Memory

    $ sudo nxp-isp -e FLASH -i /dev/ttyUSB0 -v
    2020-12-22 11:45:54.565849 [info]: Open FTDI Device /dev/ttyUSB0
    2020-12-22 11:45:54.566028 [info]: Read PID from /sys/class/tty/ttyUSB0/../../../../idProduct
    2020-12-22 11:45:54.566110 [info]: Read VID from /sys/class/tty/ttyUSB0/../../../../idVendor
    2020-12-22 11:45:54.566165 [info]: VID/PID for /dev/ttyUSB0 are 0x403/0x6015
    2020-12-22 11:45:54.578931 [info]: Enable ISP Mode
    2020-12-22 11:45:54.578994 [info]: Set all CBUS Pins to Output:0
    2020-12-22 11:45:54.582256 [info]: Set CBUS Pin 2 to Output:1
    2020-12-22 11:45:54.594019 [info]: Disable CBUS Mode
    2020-12-22 11:45:54.604991 [info]: Send "Enable ISP Mode" request to device
    2020-12-22 11:45:54.636987 [info]: ISP Mode Enabled
    2020-12-22 11:45:54.637056 [info]: Erase Memory FLASH
    2020-12-22 11:45:54.637082 [info]: Get Handle for memory
    2020-12-22 11:45:54.668975 [info]: Got handle 0
    2020-12-22 11:45:54.669046 [info]: Erase memory with handle 0
    2020-12-22 11:45:54.716865 [info]: Check if Memory has been erased ...
    2020-12-22 11:45:54.748907 [info]: Success
    2020-12-22 11:45:54.748976 [info]: Close memory Handle 0
    2020-12-22 11:45:54.781565 [info]: Memory FLASH erased

Flash a binary `firmware.bin` into flash at offset 0x00000000

    $ sudo nxp-isp -i /dev/ttyUSB0 -f firmware.bin -v
    2020-12-22 13:46:35.527316 [info]: Open FTDI Device /dev/ttyUSB0
    2020-12-22 13:46:35.527566 [info]: Read PID from /sys/class/tty/ttyUSB0/../../../../idProduct
    2020-12-22 13:46:35.527674 [info]: Read VID from /sys/class/tty/ttyUSB0/../../../../idVendor
    2020-12-22 13:46:35.527743 [info]: VID/PID for /dev/ttyUSB0 are 0x403/0x6015
    2020-12-22 13:46:35.539891 [info]: Enable ISP Mode
    2020-12-22 13:46:35.539930 [info]: Set all CBUS Pins to Output:0
    2020-12-22 13:46:35.543152 [info]: Set CBUS Pin 2 to Output:1
    2020-12-22 13:46:35.554999 [info]: Disable CBUS Mode
    2020-12-22 13:46:35.566019 [info]: Send "Enable ISP Mode" request to device
    2020-12-22 13:46:35.597407 [info]: ISP Mode Enabled
    2020-12-22 13:46:35.597476 [info]: Open file ../../nxp-k32w061-hello-world/build/helloWorld.bin
    2020-12-22 13:46:35.597542 [info]: Flash Firmware
    2020-12-22 13:46:35.600122 [info]: Get Handle to Flash memory
    2020-12-22 13:46:35.629284 [info]: Start flashing Firmware
    2020-12-22 13:46:35.629340 [info]: Write 512 Bytes at offset 0
    2020-12-22 13:46:35.693324 [info]: Write 512 Bytes at offset 512
    2020-12-22 13:46:35.773370 [info]: Write 512 Bytes at offset 1024
    2020-12-22 13:46:35.853418 [info]: Write 512 Bytes at offset 1536
    2020-12-22 13:46:35.933374 [info]: Write 512 Bytes at offset 2048
    2020-12-22 13:46:36.013410 [info]: Write 512 Bytes at offset 2560
    2020-12-22 13:46:36.093433 [info]: Write 512 Bytes at offset 3072
    2020-12-22 13:46:36.173466 [info]: Write 512 Bytes at offset 3584
    2020-12-22 13:46:36.253785 [info]: Write 512 Bytes at offset 4096
    2020-12-22 13:46:36.333491 [info]: Write 512 Bytes at offset 4608
    2020-12-22 13:46:36.413476 [info]: Write 512 Bytes at offset 5120
    2020-12-22 13:46:36.493533 [info]: Write 512 Bytes at offset 5632
    2020-12-22 13:46:36.573595 [info]: Write 512 Bytes at offset 6144
    2020-12-22 13:46:36.653474 [info]: Write 512 Bytes at offset 6656
    2020-12-22 13:46:36.733891 [info]: Write 512 Bytes at offset 7168
    2020-12-22 13:46:36.813568 [info]: Write 512 Bytes at offset 7680
    2020-12-22 13:46:36.893927 [info]: Write 512 Bytes at offset 8192
    2020-12-22 13:46:36.973595 [info]: Write 512 Bytes at offset 8704
    2020-12-22 13:46:37.053521 [info]: Write 512 Bytes at offset 9216
    2020-12-22 13:46:37.133190 [info]: Write 512 Bytes at offset 9728
    2020-12-22 13:46:37.213198 [info]: Write 512 Bytes at offset 10240
    2020-12-22 13:46:37.293194 [info]: Write 512 Bytes at offset 10752
    2020-12-22 13:46:37.373211 [info]: Write 512 Bytes at offset 11264
    2020-12-22 13:46:37.453295 [info]: Write 512 Bytes at offset 11776
    2020-12-22 13:46:37.533254 [info]: Write 512 Bytes at offset 12288
    2020-12-22 13:46:37.613311 [info]: Write 512 Bytes at offset 12800
    2020-12-22 13:46:37.693302 [info]: Write 512 Bytes at offset 13312
    2020-12-22 13:46:37.773289 [info]: Write 512 Bytes at offset 13824
    2020-12-22 13:46:37.853680 [info]: Write 512 Bytes at offset 14336
    2020-12-22 13:46:37.933336 [info]: Write 512 Bytes at offset 14848
    2020-12-22 13:46:38.013673 [info]: Write 512 Bytes at offset 15360
    2020-12-22 13:46:38.093311 [info]: Write 140 Bytes at offset 15872
    2020-12-22 13:46:38.141339 [info]: Close Memory Handle 0
    2020-12-22 13:46:38.173358 [info]: Success

# License
This Software is Licensed under `BSD + Patent`. See the LICENSE.txt for the full license text.

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This Documentation is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.