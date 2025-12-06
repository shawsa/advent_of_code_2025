const std = @import("std");

pub fn max_voltage(bank: []const u8) !u64 {
    var my_max: u64 = 0;
    for (0..bank.len-1) |i| {
        const v1: u64 = try std.fmt.parseInt(u64, bank[i..i+1], 10);
        for (bank[(i+1)..]) |v2_str| {
            const v2: u64 = try std.fmt.parseInt(u64, &[_]u8{v2_str}, 10);
            const my_num: u64 = 10 * v1 + v2;
            if (my_num > my_max) my_max = my_num;
        }
    }
    return my_max;
}

test "max_voltage" {
    try std.testing.expect(try max_voltage("987654321111111") == 98);
    try std.testing.expect(try max_voltage("811111111111119") == 89);
    try std.testing.expect(try max_voltage("234234234234278") == 78);
    try std.testing.expect(try max_voltage("818181911112111") == 92);
}

pub fn part_one(file_name: []const u8) !u64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var file = try std.fs.cwd().openFile(file_name, .{ .mode = .read_only });
    defer file.close();
    const content = try std.fs.cwd().readFileAlloc(file_name, allocator, .unlimited);
    defer allocator.free(content);

    var total: u64 = 0;
    var banks = std.mem.splitAny(u8, content[0..content.len-1], "\n");

    while (banks.next()) |string| {
        total += try max_voltage(string);
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
    try std.testing.expect(total == 357);
}
