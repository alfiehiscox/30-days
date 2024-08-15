const std = @import("std");
const fs = std.fs;

const DAY_SECONDS = 86400;
const HOUR_SECONDS = 3600;
const MINUTE_SECONDS = 60;
const SAVE_FILE = ".30-days";
const quoteFile = @embedFile("quotes.txt");
const COLS = 80;
const NUM_QUOTES = 99;

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
// If it cannot find a current timer, a new one of 30 days is created.
// If the current time has expired, a new one of 30 days is created.
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

    var timestamp = try std.fmt.parseInt(u64, buf[0..amount], 10);

    if (std.time.timestamp() > timestamp) {
        try cwd.deleteFile(SAVE_FILE);
        timestamp = try getTargetTime();
    }

    return timestamp;
}

fn getNextQuote(delta: u64) ![]const u8 {
    var splits = std.mem.splitSequence(u8, quoteFile, "\n");

    // The -1 here means a new quote is given at the
    // strike of the hour.
    const day = @divFloor(delta - 1, DAY_SECONDS) % 30;

    var line_number: u8 = 0;
    while (splits.next()) |line| {
        defer line_number += 1;
        if (line_number == day) return line;
    }

    unreachable;
}

fn clearScreen() !void {
    const writer = std.io.getStdOut().writer();
    try writer.print("\x1b[2J", .{}); // clears screen
    try writer.print("\x1b[H", .{}); // cursor to top left
}

fn centerText(text: []const u8, buff: []u8) !usize {
    if (text.len > COLS) return error.Error;

    const padding_amt = COLS - text.len;
    const left_pad_amt = padding_amt / 2;
    const right_pad_amt = padding_amt - left_pad_amt;

    var padding_buf: [64]u8 = undefined; // assume 64 elems is enough
    @memset(&padding_buf, ' ');
    const padding_left = padding_buf[0..left_pad_amt];
    const padding_right = padding_buf[0..right_pad_amt];

    const act = try std.fmt.bufPrint(buff, "{s}{s}{s}", .{ padding_left, text, padding_right });
    return act.len;
}

fn print(time_remaining: []u8, quote: []const u8) !void {
    const stdout = std.io.getStdOut();
    const writer = stdout.writer();
    try writer.print("=" ** COLS ++ "\n\n", .{});

    var buf: [COLS]u8 = undefined;
    var amount = try centerText(time_remaining, &buf);
    try writer.print("{s}\n", .{buf[0..amount]});

    try writer.print("\n", .{});

    buf = undefined;
    if (quote.len > COLS) {
        const half = @divFloor(quote.len, 2);
        const first = quote[0..half];
        const second = quote[half..];
        const first_amount = try centerText(first, &buf);
        try writer.print("{s}\n", .{buf[0..first_amount]});
        const second_amount = try centerText(second, &buf);
        try writer.print("{s}\n\n", .{buf[0..second_amount]});
    } else {
        amount = try centerText(quote, &buf);
        try writer.print("{s}\n\n", .{buf[0..amount]});
    }

    try writer.print("=" ** COLS ++ "\n", .{});
}

pub fn main() !void {
    const target_time: u64 = try getTargetTime();

    while (true) : (std.time.sleep(1e+9)) {
        // Time Logic
        const current_time: u64 = @intCast(std.time.timestamp());
        const delta = target_time - current_time;
        var buf: [33]u8 = undefined;
        const amount = try fmtSeconds(delta, &buf);
        const formatted = buf[0..amount];

        // Quote Logic
        const quote = try getNextQuote(delta);

        // Render
        try clearScreen();
        try print(formatted, quote);

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
