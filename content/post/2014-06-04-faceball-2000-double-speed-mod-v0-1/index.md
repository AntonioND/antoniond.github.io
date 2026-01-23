---
title: "Faceball 2000 Double Speed Mod v0.1"
slug: "2014-06-04-faceball-2000-double-speed-mod-v0-1"
publishDate: "2014-06-04T16:29:00"
authors:
- name: "Antonio Niño Díaz"
tags: ["gameboy", "hacking"]
---

Hello!

A few days ago I discovered this game, I tried it, and got disappointed because
it has a painfully low framerate [video](https://www.youtube.com/watch?v=KQAhnNiOu54)...
So I opened it with BGB and decided to fix it! :)

I've changed the initial jump to an empty area just before the ROM header. I
just switch to CPU double speed mode, wait for VBL, load greyscale palettes for
BGs and sprites and jump to real start point. Of course, it only works in GBC
and GBA now! Header's GBC flag has been changed, and checksums have been fixed.

Just to make it clear: This makes the CPU faster, so everything changes. Music
is still the same because it uses interrupts for synchronization, framerate is
multiplied by at least 2, but timer countdown is affected! Also, link
communications are affected.

- You'll need an IPS patcher like [Lunar IPS](http://www.romhacking.net/utilities/240)

- And, of course, the "Faceball 2000 (USA).gb" ROM, which I won't provide here.

The patch you have to apply is here:

[Download](/downloads/faceball_2000_gbc_mod_v01.ips)

I haven't tested Link functions, but it should work between modified copies of
the game. I haven't changed the way the game works. It still copies VRAM data
manually instead of using GDMA or something like that, but that would need some
extra work, and it runs fine now. I hope you like it!

Bye!
