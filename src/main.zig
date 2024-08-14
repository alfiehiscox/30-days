const std = @import("std");
const fs = std.fs;

const DAY_SECONDS = 86400;
const HOUR_SECONDS = 3600;
const MINUTE_SECONDS = 60;
const SAVE_FILE = ".30-days";

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

fn createNewSave() !void {
    const now: u64 = @intCast(std.time.timestamp());

    const target = now + 30 * DAY_SECONDS;
    var buff: [20]u8 = undefined;
    const slice = try std.fmt.bufPrint(&buff, "{d}", .{target});

    const cwd: std.fs.Dir = std.fs.cwd();
    const file = try cwd.createFile(SAVE_FILE, .{ .read = true });
    defer file.close();

    try file.writeAll(slice);
}

// Gets the current target time from disk.
// If it cannot find a current timer, a new one of 30days is created.
// If the current time has expired, a new one of 30days is created.
fn getTargetTime() !u64 {
    const cwd: fs.Dir = fs.cwd();

    var target: fs.File = undefined;
    if (cwd.openFile(SAVE_FILE, .{})) |f| {
        target = f;
    } else |err| switch (err) {
        fs.File.OpenError.FileNotFound => {
            try createNewSave();
            target = try cwd.openFile(SAVE_FILE, .{});
        },
        else => return err,
    }
    defer target.close();

    var buf: [20]u8 = undefined;
    const amount = try target.readAll(&buf);

    const timestamp = try std.fmt.parseInt(u64, buf[0..amount], 10);

    return timestamp;
}

pub fn main() !void {
    const target_time: u64 = try getTargetTime();

    while (true) : (std.time.sleep(1e+9)) {
        const current_time: u64 = @intCast(std.time.timestamp());
        const delta = target_time - current_time;
        var buf: [64]u8 = undefined;
        const amount = try fmtSeconds(delta, &buf);
        const formatted = buf[0..amount];
        std.debug.print("{s}\n", .{formatted});
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
