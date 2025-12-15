/*******************************************************************************
 *
 * Copyright (c) 2020 Albert Krenz
 *
 * This code is licensed under BSD + Patent (see LICENSE.txt for full license text)
 *******************************************************************************/
 /* SPDX-License-Identifier: BSD-2-Clause-Patent */

#include "vid_pid_reader.h"
#include <libusb-1.0/libusb.h>
#include <stdexcept>
#include <fstream>

namespace {
  // Helper function to trim whitespace from a string
  std::string trim(const std::string& str) {
    size_t first = str.find_first_not_of(" \t\r\n");
    if (first == std::string::npos) return "";
    size_t last = str.find_last_not_of(" \t\r\n");
    return str.substr(first, last - first + 1);
  }

  // Helper function to read VID/PID from sysfs
  std::tuple<int, int> readVidPidFromSysfs(const std::string& tty_name) {
    std::string vid_path = "/sys/class/tty/" + tty_name + "/device/../../idVendor";
    std::string pid_path = "/sys/class/tty/" + tty_name + "/device/../../idProduct";
    
    std::ifstream vid_file(vid_path);
    std::ifstream pid_file(pid_path);
    
    if (!vid_file.good() || !pid_file.good()) {
      return std::make_tuple(-1, -1);
    }
    
    std::string vid_str, pid_str;
    std::getline(vid_file, vid_str);
    std::getline(pid_file, pid_str);
    
    vid_str = trim(vid_str);
    pid_str = trim(pid_str);
    
    if (vid_str.empty() || pid_str.empty()) {
      return std::make_tuple(-1, -1);
    }
    
    try {
      int vid = std::stoi(vid_str, nullptr, 16);
      int pid = std::stoi(pid_str, nullptr, 16);
      return std::make_tuple(vid, pid);
    } catch (const std::exception&) {
      return std::make_tuple(-1, -1);
    }
  }

  // Helper function to extract tty name from device path
  std::string extractTtyName(const std::string& dev_path) {
    size_t last_slash = dev_path.find_last_of('/');
    if (last_slash != std::string::npos && last_slash + 1 < dev_path.length()) {
      return dev_path.substr(last_slash + 1);
    }
    return dev_path;
  }

  // Helper function to safely close libusb device and reattach kernel driver
  void closeLibusbDevice(libusb_device_handle* handle) {
    if (handle != nullptr) {
      libusb_attach_kernel_driver(handle, 0); // Reattach kernel driver
      libusb_close(handle);
    }
  }
}

std::tuple<int, int> VIDPIDReader::getVidPidForDev(std::string dev_path) {
  // First, try to read VID/PID directly from sysfs (most reliable method)
  // This works by following the symlink from /dev/ttyUSB0 to the USB device
  std::string tty_name = extractTtyName(dev_path);
  auto result = readVidPidFromSysfs(tty_name);
  if (std::get<0>(result) != -1 && std::get<1>(result) != -1) {
    return result;
  }

  // Fallback: Use libusb to find device by matching serial number
  // This is needed if sysfs method fails or if dev_path is a symlink with serial number
  libusb_context* ctx = nullptr;
  if (libusb_init(&ctx) < 0) {
    throw std::runtime_error("libusb_init failed");
  }

  libusb_device** devs = nullptr;
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

    if (libusb_get_device_descriptor(dev, &desc) != 0) {
      continue;
    }

    libusb_device_handle* handle = nullptr;
    if (libusb_open(dev, &handle) != 0) {
      continue;
    }

    // libusb_open automatically detaches the kernel driver
    // We need to reattach it before closing so libftdi can access the device

    // Read serial number
    std::string serial_str;
    if (desc.iSerialNumber > 0) {
      unsigned char serial[256];
      int len = libusb_get_string_descriptor_ascii(handle, desc.iSerialNumber, serial, sizeof(serial));
      if (len > 0) {
        serial_str = std::string(reinterpret_cast<char*>(serial), len);
      }
    }

    // Check if serial number appears in dev_path (for symlinks like /dev/serial/by-id/...)
    if (!serial_str.empty() && dev_path.find(serial_str) != std::string::npos) {
      found_vid = desc.idVendor;
      found_pid = desc.idProduct;
      closeLibusbDevice(handle);
      break;
    }

    closeLibusbDevice(handle);
  }

  libusb_free_device_list(devs, 1);
  libusb_exit(ctx);

  if (found_vid == -1 || found_pid == -1) {
    throw std::runtime_error("Could not find matching USB device for " + dev_path);
  }

  return std::make_tuple(found_vid, found_pid);
}
