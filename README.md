# 30 Day Countdown Zig Test

This test is a simple ascii 30 day countdown, that will:
- Be rendered in ASCII art, hopefully accounting for terminal width
- Have a GitHub style Heat Map to tick off the 30 days automatically
- Be stateful. i.e. on lauch if a current timer is running load that data
- A new inspirational quote everyday

## Example Art:

Something like this, it should be redrawn every second.

===========================================================================

                        25 days, 5 Hs, 3ms, 20s
                               Remaining

              "Through discipline comes freedom" ~Aristole
    
    [X][X][X][X][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
                          [ ][ ][ ][ ][ ][ ][ ][ ]

===========================================================================