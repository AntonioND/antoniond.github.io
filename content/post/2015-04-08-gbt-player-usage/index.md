---
title: "GBT Player usage"
slug: "2015-04-08-gbt-player-usage"
publishDate: "2015-04-08T01:36:00"
Lastmod: "2026-01-14T01:28:00"
authors:
- name: "Antonio Niño Díaz"
tags: ["gameboy", "programming"]
---

Over the last months I've seen a few tutorials about GB programming that use my
GBT Player for music. I have to say a few things about that.

First: Thanks a lot for using my library! The fact that you like it enough to
use it in your projects is what keeps it alive. Version 2 only happened because
I was asked to add a few things to previous versions.

Second: **You are using it wrong!**

Ok, it's partly my fault, but it's your fault too, obviously: *You are using
GBDK*... I mean, you just don't understand the implications of the ROM banking
system the GB uses. I know I don't really have to explain this kind of things,
but I feel a bit responsible for my library, so I'm going to explain why you are
using it wrong and how to fix it. Let's see...

My (now old) example does something like this:

```c {linenos=table hl_lines=[15]}
#include <gb/gb.h> // Include GBDK lib
#include "gbt_player.h" // Include player

// Reference to song data
extern const unsigned char * song_Data[];

void main()
{
    // Disable interrupts while they are being configured
    disable_interrupts();

    gbt_play(song_Data, 2, 7); // Setup song
    gbt_loop(0); // The default is 0, this could be removed

    add_VBL(gbt_update); // Add callback for VBL interrupt (*)

    set_interrupts(VBL_IFLAG); // Enable VBL interrupt
    enable_interrupts();

    while (1)
    {
        wait_vbl_done(); // Wait loop with reduced CPU usage
    }
}
```

While the new one does this:

```c {linenos=table hl_lines=[22]}
#include <gb/gb.h> // Include GBDK lib
#include "gbt_player.h" // Include player

// Reference to song data
extern const unsigned char * song_Data[];

void main()
{
    // Disable interrupts while they are being configured
    disable_interrupts();

    gbt_play(song_Data, 2, 7); // Setup song
    gbt_loop(0); // The default is 0, this could be removed

    set_interrupts(VBL_IFLAG); // Enable VBL interrupt
    enable_interrupts();

    while (1)
    {
        wait_vbl_done(); // Wait loop with reduced CPU usage

        gbt_update(); // Update player (*)
    }
}
```

So what's the big deal?

Well, let's explain how the GB banking system works. You should know that. If
you don't know that, you shouldn't be coding for GB, but whatever... The first
16 KB of the ROM are always mapped to addresses `0000h-3FFFh`. This means that
this code and data is always available to read! That's the place where you want
your game engine to be. But GBT code doesn't go there by default. It goes to
bank 1. Why? Because 16 KB is not much space. GBT player needs quite a bit of
space and it's stupid to put it in bank 0 when GBDK is already using a lot of
that space. It would leave you even less space for your code!

Banks 1 and beyond are mapped to addresses `4000h-7FFFh`. Only one of them can
be mapped at once there, so they must be switched when the program needs to
access to data in other bank. This means that you can have as much 16 KB banks
as you need (so you could have ROMs with *infinite* banks), but you have to take
care to switch to the correct bank whenever you are trying to get some data or
execute some code.

So GBT runs in bank 1, again, what's the big deal?

The problem here is that the first example uses interrupt for the player update
function. If your game loop is small, and your ROM is small, and your game is
more or less a "Hello World!" this won't be a problem because you won't use bank
switching and bank 1 will always be available. If your game is big and you need
to load data from other banks, there are problems because you will sometimes use
data from other banks (in fact, GBT Player loads data from the bank where the
song is placed, but it returns to bank 1 afterwards to execute its code).

An interrupt means that the CPU jumps to an interrupt vector, executes its code
and then returns to its previous state. Again, you should know that. If you
don't, something is wrong and you should stop and learn this kind of things
first. But you won't, that's why I'm explaining this. This is useful to know
when hardware events happen, like screen redraw. Vertical blanking period is
entered when the current frame has been drawn, so it happens once every frame
(around 60 times per second). This interrupt is very useful to synchronize the
game, and GBT Player uses it to update itself.

Let's say you want to load a background placed in bank 4. You switch to bank 4,
start copying... and vertical blank period is reached. An interrupt is triggered
and CPU jumps to the VBL interrupt vector at address `0040h`. It eventually
calls `gbt_update()`, which switches to bank 1, and returns. The CPU returns
to the same state as before the interrupt... but the ROM bank is still bank 1,
so the copy won't work because it's reading incorrect data! This can also happen
with code. In that case, the game is likely to crash immediately. If you only
had banks 0 and 1, this couldn't happen. That's why small demos and games run
fine, but they will eventually crash if they are more than 32 KB big (2 banks).

That's why the code of `gbt_player.h` says "this changes to bank 1!". To warn
you that this does changes to the memory that you have to revert. I don't know
what system GBDK uses to know what ROM bank is being used or anything like that.
When I made a game (that I didn't finish) I created a ROM bank stack to keep
track of the banks that I used, so I could save the bank that was being used
when `gbt_update()` was called and I could restore it afterwards. I suppose
most of you won't be able to do something like that, so the new example is an
alternative.

The new example calls `gbt_update()` every frame in the main loop of the game.
You need to put it in EVERY main loop, and you need to synchronize the game to
VBL with `wait_vbl_done()`. That's it. No more problems of banking. Well,
there still can be problems, but it's more difficult. If you can write code that
has that kind of problems, you should be able to fix them.

In fact, if your game doesn't use `wait_vbl_done()`, your game is evil. This
function enters a low consumption state until VBL is entered, and it should be
used whenever it's possible. I've seen code of "games" that don't use it. They
are bad. No, seriously, use that function. Please.

Examples of bad tutorials (I could only find 2 right now, both in Spanish):

http://www.elotrolado.net/hilo_desarrollo-software-proyectos-de-darkryoga_1901847

http://www.fasebonus.net/foro/index.php?topic=36662.msg60626#msg60626

PS: But you are, in fact, using GBDK, which should be avoided. :P It's better if
you try to learn ASM and use RGBDS or WLA-DX assemblers instead. The GB CPU is
very slow, so you need every CPU cycle you can get. Maybe you are doing a
text-only game, and then GBDK should be fine, but you are wasting a lot of CPU
power. GBDK functions are mostly written in ASM. I know it's harder and you want
to see results right now, but it's better.

PS2: Anyway, update to the latest version (2.1.1 at the time of writing this,
the same as 2.1.0 but with a new GBDK example):

https://codeberg.org/SkyLyrac/gbt-player

**Update (2026-01-14)**

Updated links from GitHub to Codeberg.
