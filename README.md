# 30 Day Countdown Zig Test

This test is a simple ascii 30 day countdown, that will:
- Be rendered in ASCII art, hopefully accounting for a column constant 
- Be stateful. i.e. on lauch if a current timer is running load that data
- A new inspirational quote everyday

## Example Art:

Something like this, it should be redrawn every second.

```
===========================================================================

                        25 days, 5 Hs, 3ms, 20s

              "Through discipline comes freedom" ~Aristole

===========================================================================
```

## Retrospective

I really like zig. Adding the constraint of only have stack-allocated memory 
ala [the power of 10](https://en.wikipedia.org/wiki/The_Power_of_10:_Rules_for_Developing_Safety-Critical_Code) 
was a fun challenge, but mostly due to **no** knowledge of allocation in zig.

On that note, [this blog post](https://blog.orhun.dev/zig-bits-01/) was really helpful. 

I credit this program for really hammering into me what slices under the hood, 
and the experience of passing buffers around to functions. I'm not sure if it's 
idiomatic, but had a cool time. 

## Run from source

```
git clone https://github.com/alfiehiscox/30-days.git
cd 30-days
zig build run 
```