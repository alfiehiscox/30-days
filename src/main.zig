const std = @import("std");

const DAY_SECONDS = 86400;
const HOUR_SECONDS = 3600;
const MINUTE_SECONDS = 60;

// Writes seconds into buf in the format:
//   00 Days, 00 Hrs, 00 Mins, 00 Secs
fn fmtSeconds(seconds: u64, buf: []u8) !usize {
    const days_part = seconds / DAY_SECONDS;
    const hours_part = (seconds % DAY_SECONDS) / HOUR_SECONDS;
    const minutes_part = ((seconds % DAY_SECONDS) % HOUR_SECONDS) / MINUTE_SECONDS;
    const seconds_part = ((seconds % DAY_SECONDS) % HOUR_SECONDS) % MINUTE_SECONDS;

    const act = try std.fmt.bufPrint(
        buf,
        "{d:0>2} Days, {d:0>2} Hrs, {d:0>2} Mins, {d:0>2} Secs",
        .{
            days_part,
            hours_part,
            minutes_part,
            seconds_part,
        },
    );

    return act.len;
}

pub fn main() !void {}

test "Fmt Seconds" {
    const expected = "03 Days, 04 Hrs, 23 Mins, 45 Secs";
    const days = 3 * DAY_SECONDS;
    const hrs = 4 * HOUR_SECONDS;
    const mins = 23 * MINUTE_SECONDS;
    const total = days + hrs + mins + 45;

    var buf: [64]u8 = undefined;
    const len = try fmtSeconds(total, &buf);
    const formatted = buf[0..len];

    try std.testing.expectEqualStrings(expected, formatted);
}
