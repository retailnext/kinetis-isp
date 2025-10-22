/*******************************************************************************
 *
 * Copyright (c) 2020 Albert Krenz
 *
 * This code is licensed under BSD + Patent (see LICENSE.txt for full license text)
 *******************************************************************************/
 /* SPDX-License-Identifier: BSD-2-Clause-Patent */

#include "vid_pid_reader.h"
#include <libusb-1.0/libusb.h>
#include <iostream>
#include <stdexcept>
#include <sstream>
#include <vector>
#include <cstring>

std::tuple<int, int> VIDPIDReader::getVidPidForDev(std::string dev_path) {
  libusb_context* ctx = nullptr;
  libusb_device** devs = nullptr;
  libusb_device_handle* handle = nullptr;

  int r = libusb_init(&ctx);
  if (r < 0) {
    throw std::runtime_error("libusb_init failed");
  }

  ssize_t cnt = libusb_get_device_list(ctx, &devs);
  if (cnt < 0) {
    libusb_exit(ctx);
    throw std::runtime_error("libusb_get_device_list failed");
  }

  int found_vid = -1;
  int found_pid = -1;

  for (ssize_t i = 0; i < cnt; i++) {
    libusb_device* dev = devs[i];
    libusb_device_descriptor desc;

    if (libusb_get_device_descriptor(dev, &desc) != 0)
      continue;

    if (libusb_open(dev, &handle) == 0) {
      unsigned char serial[256];
      int len = 0;

      if (desc.iSerialNumber > 0) {
          len = libusb_get_string_descriptor_ascii(handle, desc.iSerialNumber, serial, sizeof(serial));
      }

      std::string serial_str = (len > 0) ? std::string((char*)serial, len) : "";

      if (!serial_str.empty() && dev_path.find(serial_str) != std::string::npos) {
        found_vid = desc.idVendor;
        found_pid = desc.idProduct;
        libusb_close(handle);
        break;
      }

      libusb_close(handle);
    }
  }

  libusb_free_device_list(devs, 1);
  libusb_exit(ctx);

  if (found_vid == -1 || found_pid == -1) {
    throw std::runtime_error("Could not find matching USB device for " + dev_path);
  }

  return std::make_tuple(found_vid, found_pid);
}
