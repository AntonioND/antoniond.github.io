---
title: "BlocksDS SDK Version 1.1.0"
slug: "2024-05-15-blocksds-sdk-version-1-1-0"
publishDate: "2024-05-15T02:19:00"
Lastmod: "2026-01-14T01:20:00"
authors:
- name: "Antonio Niño Díaz"
tags: ["programming", "nintendo-ds", "blocksds"]
---

It's been over a year since the first release of [BlocksDS](https://codeberg.org/blocksds/sdk),
and over half year since [this blog post](../2023-08-18-blocksds-sdk), which was
written after version 0.8.1 was released. The current version is 1.1.0, which
means it's time to write a new post with the current state of BlocksDS!

First of all, check this up-to-date [introduction](https://blocksds.skylyrac.net/docs/introduction)
if you have never heard of BlocksDS. Feel free to skip it if you are already
familiar with it! In short, it is an actively maintained SDK to develop
applications for the DS in C or C++.

There are too many changes between versions 1.1.0 and 0.8.1 to list them here.
You can check the [changelog](https://blocksds.skylyrac.net/docs/changelog)
 for more details, but this is a list of the most important changes:

- NitroFS has been fully reimplemented by [asie](https://asie.pl), which
  increased filesystem performance by orders of magnitude. The previous system
  (NitroFAT) was a workaround implemented by me which required two levels of FAT
  filesystem access, and that was very slow.

- There is experimental and preliminary support for the Teak DSP of the DSi. It
  isn't ready to be used by most people, but it's in a good enough state that
  developers can use the current toolchain and libraries to make incremental
  improvements.

- A new API has been added to use Slot-2 peripherals like RAM expansion packs,
  rumble, gyroscopes and tilt sensors.

- The default Makefiles have been simplified and they now use compiler-provided
  `.specs` files (which will make it easier to keep up-to-date with potential
  compiler and linker flags changes).

- A race condition between `scanKeys()` and `touchRead()` has been fixed.

- The RTC interrupt is no longer used to update the RTC time. Most emulators
  didn't support it, and it wasn't supported by the 3DS in DS/DSi mode.

- The documentation of BlocksDS and all its libraries has been dramatically
  improved and it is now available online: https://blocksds.skylyrac.net

- Lots and lots of examples have been added.

Some minor changes that are also significant:

- There are new helper functions to set and get the current RTC time in a
  convenient way. The old setter function didn't work.

- `glTexImage2D()` now accepts sizes in pixels as well as `GL_TEX_SIZE_ENUM`
  values. This is something that has always bothered me, the requirement to use
  the enumeration values always made using this function very awkward.

- There have been some improvements to `grit` to improve the `grf` format.
  `libnds` now has functions to read graphics from `grf` files, and they are
  used in some examples.

- `dlditool` has been replaced by `dldipatch`, which is less buggy.

- Some libc locking functions (`_retarget_lock_*()`) have been implemented
  to allow libc functions to work in a multithreaded environment.

- The following libc functions have been implemented: `realpath()`, `utime()`,
  `utimes()`, `scandir()`, `alphasort()`, `versionsort()`.

- Added `nitroFSOpenById()` and `nitroFSFopenById()` functions, allowing opening
  files directly without paying the cost of a directory lookup.  Accordingly,
  NitroFS file systems which contain a FAT table but no FNT table can now be
  opened.

- There is now a function to get the name of the default drive (`sd:` for DSi,
  `fat:` for DS).

- The value of the RAM size field in `REG_SCFG_EXT` in the ARM9 is now set to 16
  MB or 32 MB instead of being fixed to 32 MB even in retail DSi units.

**Update (2026-01-14)**

Updated links from GitHub to Codeberg.
