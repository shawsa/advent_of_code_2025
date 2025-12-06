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

    fn in_range(self: Range, num: u64) bool {
        return self.lower <= num and num <= self.upper;
    }

    fn sum_invalid(self: Range) u64 {
        var total: u64 = 0;
        const factor10 = std.math.pow(u64, 10, (1 + num_digits(self.lower)) / 2);
        const bottom: u64 = @mod(self.lower, factor10);
        var top: u64 = self.lower / factor10;
        const top_min = factor10 / 10;
        // std.debug.print("  {}\n", .{top_min});
        if (top_min > top) top = top_min;
        var half = bottom;
        if (top < half) half = top;
        // std.debug.print("{}-{}\n", .{self.lower, self.upper});
        // std.debug.print("  {}\n", .{half});
        while (true) : (half += 1) {
            const whole: u64 = half + half * std.math.pow(u64, 10, num_digits(half));
            if (whole < self.lower) continue;
            if (whole > self.upper) break;
            // std.debug.print("\t{}\n", .{whole});
            total += whole;
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
        // std.debug.print("{}-{}\n", .{range.lower, range.upper});
        total += range.sum_invalid();
    }
    return total;
}

pub fn main() !void {
    const file_name = "input";
    const total1: u64 = try part_one(file_name);
    std.debug.print("part one: {}\n", .{total1});
}

test "part_one" {
    const total: u64 = try part_one("test_input");
    try std.testing.expect(total == 1227775554);
}


test "digits" {
    try std.testing.expect(num_digits(0) == 0);
    try std.testing.expect(num_digits(1234) == 4);
    try std.testing.expect(num_digits(1000) == 4);
    try std.testing.expect(num_digits(9999) == 4);
}

test "sum range" {
    try std.testing.expect( (Range{
        .lower = 11,
        .upper = 22,
    }).sum_invalid() == 33);
    try std.testing.expect( (Range{
        .lower = 1188511880,
        .upper = 1188511890,
    }).sum_invalid() == 1188511885);
    try std.testing.expect( (Range{
        .lower = 998,
        .upper = 1012,
    }).sum_invalid() == 1010);
}

