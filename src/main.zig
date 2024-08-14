const std = @import("std");

const DAY_SECONDS = 86400;
const HOUR_SECONDS = 3600;
const MINUTE_SECONDS = 60;

// Writes seconds into buf in the format:
//   00 Days, 00 Hrs, 00 Mins, 00 Secs
fn fmtSeconds(seconds: u64, buf: []u8) !usize {
    const days_part = @divFloor(seconds, DAY_SECONDS);
    const hours_part = @divFloor(@mod(seconds, DAY_SECONDS), HOUR_SECONDS);
    const minutes_part = @divFloor(@mod(@mod(seconds, DAY_SECONDS), HOUR_SECONDS), MINUTE_SECONDS);
    const seconds_part = @mod(@mod(@mod(seconds, DAY_SECONDS), HOUR_SECONDS), MINUTE_SECONDS);

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

pub fn main() !void {
    const target_time: u64 = @intCast(std.time.timestamp() + 30);

    while (true) : (std.time.sleep(1e+9)) {
        const current_time: u64 = @intCast(std.time.timestamp());
        const delta = target_time - current_time;
        var buf: [64]u8 = undefined;
        const amount = try fmtSeconds(delta, &buf);
        const formatted = buf[0..amount];
        std.log.debug("{s}", .{formatted});
        if (delta <= 0) break;
    }
}

// ================ TESTS ===================

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
