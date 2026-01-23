---
title: "Switch GBA into GBC mode by software"
slug: "2014-04-20-switch-gba-into-gbc-mode-by-software"
publishDate: "2014-04-20T20:46:00"
Lastmod: "2026-01-14T01:16:00"
authors:
- name: "Antonio Niño Díaz"
tags: ["gameboy", "gameboy-advance", "hacking"]
---

Hello!

I know dwedit did something like this a few years ago, but I never managed to
compile its code and make it run (even though the precompiled binary worked
fine). Anyway, the code was incomprehensible:

http://www.dwedit.org/dwedit_board/viewtopic.php?id=339

This morning I've read that the GBA bios still had the piece of code that
switches the GBA into GBC mode, like Nintendo planned to do in the beginning
(before deciding that it would be better to do it with a hardware switch).

I've disassembled the part that performs this switch and made a little demo to
show that it works! Here it is:

https://codeberg.org/SkyLyrac/gba-switch-to-gbc

But it doesn't end here! It can also apply an affine transformation to the GBC
video output, and even enable mosaic effect or `GREENSWP` register! The
`GREENSWP` register works a bit different than in GBA mode, by the way.

The bad thing is that the video output only works in GB Micro, in GBA and GBA SP
it shows a black screen, and in DS it doesn't work at all (it doesn't have a GB
CPU).

I've also uploaded a video:

https://www.youtube.com/watch?v=-SkR8SAdS9w

Bye!

**Update (2026-01-14)**

Updated links from GitHub to Codeberg.
