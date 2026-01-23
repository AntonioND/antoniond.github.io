---
title: "BlocksDS SDK"
slug: "2023-08-18-blocksds-sdk"
publishDate: "2023-08-18T17:44:00"
Lastmod: "2026-01-14T01:43:00"
authors:
- name: "Antonio Niño Díaz"
tags: ["programming", "nintendo-ds", "blocksds"]
---

A few months ago I created [BlocksDS](hhttps://codeberg.org/blocksds/sdk), a new
SDK for Nintendo DS. It uses libnds, DS WiFI and Maxmod, so it is compatible
with projects that use devkitARM. The toolchain it uses comes from
[Wonderful Toolchain](https://wonderful.asie.pl) by [asie](https://asie.pl).

Its main objective is to remain as compatible as possible with old projects that
use devkitARM, while adding new features that have been needed for a long time,
but that would have never been added to the original repositories of devkitPro.

In order to achieve this, the libraries have been forked, and there are some
visible improvements over devkitARM already:

- Binaries are smaller and they use less RAM. The main reasons for that are:

  - Instead of using [newlib](https://sourceware.org/newlib), BlocksDS uses
    [picolibc](https://github.com/picolibc/picolibc) (thanks to Wonderful
    Toolchain). The `tinystdio` of picolibc has smaller versions of `stdio`
    functions (like `scanf()`, `printf()` or `fopen()`) than newlib.

  - There have been some changes that optimize memory usage in libnds:
    [[1]](https://codeberg.org/blocksds/libnds/pulls/1),
    [[2]](https://codeberg.org/blocksds/libnds/pulls/2) and
    [[3]](https://codeberg.org/blocksds/libnds/pulls/24).

  - BlocksDS doesn't have anything similar to `devoptab`, which is used in
    devkitARM. While this is very flexible, and very useful in platforms like
    the Wii or Switch, it's too big for the GBA or NDS, where it doesn't offer
    almost any benefit. There is more information about this change further down
    this article.

- The [licensing status](https://blocksds.skylyrac.net/docs/guides/licenses)
  of all libraries has been clarified and documented. This is important.
  Anything that doesn't have a license defaults to "all rights reserved", not
  "public domain". Many things that devkitPro distributes don't have a license.
  The examples don't have a license, but that's not the worst thing, as it can
  be argued that most of them are trivial and copyright doesn't apply to them.
  However, it is a problem for non-trivial code, and it looks like the devkitPro
  maintainers seem to mistakenly believe that the lack of a license is fine, and
  that it [leaves the code in the public domain](https://github.com/devkitPro/wut/pull/148#issuecomment-652337319).

  They also may be in violation of the [GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html)
  by distributing build scripts for GPLv3-licensed software under incompatible
  [restrictive terms](https://github.com/devkitPro/buildscripts/blob/f06196c43cca687108c6f73fe0b48ed01a606d85/build-devkit.sh#L17-L19).
  Any build scripts for GPLv3 software must also be released under the GPLv3:

  > The "Corresponding Source" for a work in object code form means all the
  > source code needed to generate, install, and (for an executable work) run
  > the object code and to modify the work, including scripts to control those
  > activities.

  The biggest practical problem for BlocksDS is that a library crucial for NDS
  development doesn't have any license: [NitroFS](https://github.com/devkitPro/libfilesystem/issues/3).
  I tried to contact the original author in every way I could think of with no
  luck. This means that the library isn't open source, and it can't be used
  without permission from the [author](http://blea.ch/wiki/index.php/Nitrofs).
  The devkitPro maintainers aren't interested in fixing this situation.

  BlocksDS does thing in a different way. devkitARM uses [libfat](https://github.com/devkitPro/libfat)
  by Chishm to access FAT filesystems and interface with the DS hardware, and
  [libfilesystem](https://github.com/devkitPro/libfilesystem) to use the
  filesystem embedded in the NDS ROM (and it uses the official filesystem format
  of the official SDK provided by Nintendo).

  BlocksDS uses [FatFs](http://elm-chan.org/fsw/ff/00index_e.html) by Elm and a
  thin wrapper on top of libnds to access libnds functions. Instead of using the
  official format of Nintendo, BlocksDS uses what I've decided to call
  **NitroFAT**, which appends a FAT filesystem image to the NDS ROM, and it uses
  FatFs to access it. This allows BlocksDS to reuse code, as accessing the
  filesystem of the SD card and the filesystem of the ROM uses the same code.
  This is one of the reasons why NDS programs built with BlocksDS are smaller
  than with devkitARM.

  This took a lot of effort to get working, and it is the best example I can
  think of about why it is important to license your code so that people can
  reuse it when you move on and stop caring about it.

  So, in order to ensure that this project can survive over time, all files in
  all repositories of BlocksDS use [SPDX](https://spdx.dev) identifiers, so that
  the licensing status of all individual files is always clear, which will allow
  other projects to reuse the code of BlocksDS easily if they want. It also
  allows other people to fork BlocksDS if something happens in the future.

  I also talked to the author to change the
  [license of GL2D](https://codeberg.org/blocksds/libnds/commit/60e7f002daf4be9588865e654b9776e3004d002f)
  to Zlib, like the rest of `libnds`.

- There is now basic multithreading support. `libnds` wasn't thread-safe, so
  it had to be modified so that multithreading works safely. Thread-local
  storage support has also been added. You can define variables that are
  unique per thread like this:

  ```c
  __thread int my_variable = 1000;
  __thread int other_variable;
  ```

- DLDI can now be used from both the ARM9 and ARM7.

  You can make the ARM9 ask the ARM7 to load files in one thread. While the ARM7
  load files the ARM9 can be doing other things in other threads, so you aren't
  blocked. This can also be done when loading files from the SD card of the DSi.
  This has always been one of the limitations that annoyed me about creating
  games with devkitARM, and now it's fixed.

  There is a big issue with DLDI drivers, and it's that some of them have been
  compiled for the ARM9 and can't run on the ARM7. This is why, by default,
  BlocksDS makes them run from the ARM9. The code must explicitly set ARM7 mode,
  or the user needs to use a DLDI driver built with a
  [new configuration flag](https://codeberg.org/blocksds/sdk/src/commit/c7e3f22054dc2b473089d064c3780f6c2fea1889/tests/dldi_arm9_arm7).

- The DSi camera is supported (thanks, asie!). It's still quite basic, but
  enough to be able to take photos from the front and back cameras.

- **libnds** has been documented in many places, like the
  [MPU setup](https://codeberg.org/blocksds/libnds/src/commit/9763b22fee597025777ec4c853c94d95944ffe37/source/arm9/system/mpu_setup.s),
  the [FIFO system](https://codeberg.org/blocksds/libnds/src/commit/9763b22fee597025777ec4c853c94d95944ffe37/source/common/fifo_ipc_messages.h),
  and the code that allows a program to [return to the loader](https://codeberg.org/blocksds/sdk/src/commit/c7e3f22054dc2b473089d064c3780f6c2fea1889/docs/exit-to-loader.rst)
  if the loader supports it.

- BlocksDS includes versions of `memcpy()`, `memset()` and `memmove()`
  optimmized for the CPUs of the NDS by using **ndsabi**, a fork of
  [agbabi](https://github.com/felixjones/agbabi) by felixjones.

- **ndstool** now supports multiple languages in the banner, as well as icons in
  formats like PNG or GIF (even animated GIFs!).

- **libxm7** has been added as an alternative to Maxmod.

- **no$gba** debug messages are now supported in the ARM7, not only ARM9.

- A few people have started to contribute with bugfixes, like [asie](https://asie.pl/),
  [lifehackerhansol](https://github.com/lifehackerhansol) and [Pk11](https://pk11.us),
  which I'm very grateful about!

There is guide that helps new users [port devkitARM projects](https://codeberg.org/blocksds/sdk/src/commit/c7e3f22054dc2b473089d064c3780f6c2fea1889/docs/porting-guide.rst)
to BlocksDS. Even though most code is compatible, there are a few things to
consider:

- BlocksDS is available on Windows and Linux. If you're using Mac, you can use
  the [Docker images](https://codeberg.org/blocksds/sdk/src/commit/c7e3f22054dc2b473089d064c3780f6c2fea1889/docker)
  distributed by BlocksDS. There is no native way to use BlocksDS on Mac, and
  currently there are no immediate plans to support it.

- The Makefiles are completely different from the ones used in devkitARM. For
  most users this won't be a problem, the migration is very easy (it only
  involves copying folder names from the old Makefiles to the new ones).

- There is no `devoptab` support. Most likely you've never heard of it or used
  it directly, but `devoptab` is the way that devkitARM uses to make things
  like filesystem functions work (`fopen()`, etc), or things like getting the
  time and date from the OS (with `time()`).

  BlocksDS supports the same features without any intermediate layers (like
  `devoptab`) between libc functions and the hardware functions. This is one
  of the reasons why binaries generated by BlocksDS are smaller and require less
  RAM to run.

  However, in rare situations where user code uses `devoptab`, it won't be
  possible to migrate to BlocksDS without big changes.

Here is a list of projects that now benefit from using BlocksDS:

- [Angband](https://github.com/angband/angband/pull/5700)
- [dsbf_dump](https://github.com/DS-Homebrew/dsbf_dump/releases/tag/v1.0)
- [GameYob](https://github.com/DS-Homebrew/GameYob)
- [NitrousTracker](https://github.com/asiekierka/nitrotracker/releases/tag/0.4.3-unofficial)
- [uxnds](https://github.com/asiekierka/uxnds/releases/tag/v0.3.7)
- [VNDS](https://github.com/asiekierka/vnds/releases/tag/1.4.10-pre)

Thanks to the work of the maintainers of the projects it was possible to
exhaustively test BlocksDS, and it's now stable enough to be used by real
projects. A lot of work has been put into all of this by several people, so
it's great that some projects have started to use it for real!

Finally, I'd like to mention NFlib and Nitro Engine.

- [NFlib](https://github.com/knightfox75/nds_nflib) is a library that
  [NightFox](https://github.com/knightfox75) created many years ago. It helps
  developers create 2D games (and it has very basic 3D support). I've spent
  quite a bit of time cleaning it up and documenting the library and examples
  properly by adding Doxygen comments and translating everything from Spanish to
  English (sorry, but it's too easy for the documentation to be outdated if it's
  in multiple languages!).

  I also talked to the author to change the license to MIT instead of Creative
  Commons. Note that Creative Commons is a license that
  [shouldn't be used for code](https://creativecommons.org/faq/#can-i-apply-a-creative-commons-license-to-software).

- [Nitro Engine](https://codeberg.org/SkyLyrac/nitro-engine) is a library that I
  created many years ago as well. It's used to develop 3D games. I've spent some
  time over the last few years cleaning it up and improving it. In fact, I came
  up with the idea of BlocksDS when I was frustrated because I couldn't
  implement a system to load assets from the filesystem asynchronously with
  devkitARM.

Both libraries are now fully supported in BlocksDS. The examples in both
repositories will build with BlocksDS, and Nitro Engine comes with an example of
how to use both libraries in the same project, which can be found
[here](https://codeberg.org/SkyLyrac/nitro-engine/src/commit/db33780b45da84dcdb7aeb7e763dcff995469f04/examples/templates/using_nflib).

At the time of writing this post, the latest version of BlocksDS is
[0.8.1](https://codeberg.org/blocksds/sdk/releases/tag/v0.8.1). Give it a try!
If you find any problems, or you have questions, feel free to open issues in the
repository (or send a pull request with a fix!).

P.S.: I haven't written anything in this blog for over 3 years... I still have a
few more updates to post in the coming days!

**Update (2023-09-06)**

This post has been updated to reflect the fact that Windows is now supported by
Wonderful Toolchain, which enables BlocksDS to work on Windows natively.

**Update (2026-01-14)**

Updated links from GitHub to Codeberg.
