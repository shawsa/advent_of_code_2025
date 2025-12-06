const std = @import("std");

pub fn num_digits(number: u64) u64 {
    var num: u64 = number;
    var digits: u64 = 0;
    while (num > 0) {
        num /= 10;
        digits += 1;
    }
    return digits;
}

pub fn repeat_num(base: u64, repeats: u64) u64 {
    var rep = repeats;
    var num = base;
    const factor = std.math.pow(u64, 10, num_digits(base));
    while (rep > 1) : (rep -= 1) {
        num = factor*num + base;
    }
    return num;
}

test "repeat_num" {
    try std.testing.expect(repeat_num(12, 4) == 12121212);
    try std.testing.expect(repeat_num(123, 3) == 123123123);
}

fn invalid(num: u64) bool {
    const limit: u64 = num_digits(num);
    for (1..limit) |exp| {
        const factor: u64 = std.math.pow(u64, 10, exp);
        const base: u64 = @mod(num, factor);
        if (base == 0) continue;
        var rep: u8 = 2;
        while (true) : (rep += 1) {
            const match: u64 = repeat_num(base, rep);
            if (match == num) return true;
            if (match > num) break;

        }
    }
    return false;
}

test "invalid" {
    try std.testing.expect(invalid(1111) == true);
    try std.testing.expect(invalid(1212) == true);
    try std.testing.expect(invalid(1234512345) == true);
    try std.testing.expect(invalid(1121) == false);
    try std.testing.expect(invalid(12121) == false);
    try std.testing.expect(invalid(1234123) == false);
}

const Range = struct {
    lower: u64,
    upper: u64,

    fn parse(string: []const u8) !Range {
        const range = std.mem.trim(u8, string, &std.ascii.whitespace);
        var bounds = std.mem.splitAny(u8, range, "-");
        const str_lower = bounds.next().?;
        const str_upper = bounds.next().?;
        const lower = try std.fmt.parseInt(u64, str_lower, 10);
        const upper = try std.fmt.parseInt(u64, str_upper, 10);
        return Range{
            .lower = lower,
            .upper = upper,
        };
    }

    fn sum_invalid(self: Range) u64 {
        var total: u64 = 0;
        var num: u64 = self.lower;
        while (num <= self.upper) : (num += 1) {
            if (invalid(num)) total += num;
        }
        return total;
    }

};

pub fn part_one(file_name: []const u8) !u64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var file = try std.fs.cwd().openFile(file_name, .{ .mode = .read_only });
    defer file.close();
    const content = try std.fs.cwd().readFileAlloc(file_name, allocator, .unlimited);
    defer allocator.free(content);

    var total: u64 = 0;
    var range_strings = std.mem.splitAny(u8, content, ",");

    while (range_strings.next()) |string| {
        if (string.len < 3) continue;
        const range = try Range.parse(string);
        total += range.sum_invalid();
    }
    return total;
}

test "part_two" {
    const total: u64 = try part_one("test_input");
    try std.testing.expect(total == 4174379265);
}

pub fn main() !void {
    const file_name = "input";
    const total: u64 = try part_one(file_name);
    std.debug.print("part two: {}\n", .{total});
}
