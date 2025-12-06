const std = @import("std");

const Battery = struct {
    on: bool,
    num: u7,

    pub fn parse_char(char: u8) !Battery {
        return Battery{ .on = false, .num = try std.fmt.parseInt(u7, &.{char}, 10) };
    }
};

test "Battery" {
    const string = "11234";
    try std.testing.expect((try Battery.parse_char(string[0])).num == 1);
    try std.testing.expect((try Battery.parse_char(string[1])).num == 1);
    try std.testing.expect((try Battery.parse_char(string[2])).num == 2);
    try std.testing.expect((try Battery.parse_char(string[4])).num == 4);
}

pub fn read_voltage(bank: []Battery) u64 {
    var voltage: u64 = 0;
    for (bank) |bat| {
        if (bat.on) {
            voltage = voltage * 10 + bat.num;
        }
    }
    return voltage;
}

test "Bank" {
    var bank = [_]Battery{
        Battery{ .on = true, .num = 3 },
        Battery{ .on = false, .num = 7 },
        Battery{ .on = true, .num = 7 },
    };
    try std.testing.expect(read_voltage(&bank) == 37);
}

pub fn parse_bank(string: []const u8, bank: []Battery) !void {
    for (0..string.len) |i| {
        bank[i] = try Battery.parse_char(string[i]);
    }
}

test "parse_bank" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const string = "1234";

    var bank: []Battery = try allocator.alloc(Battery, string.len);
    defer allocator.free(bank);
    try parse_bank(string, bank);

    for (0..string.len) |i| {
        try std.testing.expect(bank[i].num == i + 1);
    }
}

pub fn max_voltage(bank: []Battery, num_on: u64) u64 {
    // set the batteries to provide the max voltage
    // and return that voltage
    var max_v: u64 = 0;
    // turn all off
    for (0..bank.len) |i| {
        bank[i].on = false;
    }
    // turn on one at a time
    for (0..num_on) |_| {
        // turn one one
        var max_id: usize = undefined;
        for (0..bank.len) |i| {
            // skip if on
            if (bank[i].on) continue;
            // turn on and test
            bank[i].on = true;
            const v: u64 = read_voltage(bank);
            if (v > max_v) {
                max_id = i;
                max_v = v;
            }
            // remember to turn back off
            bank[i].on = false;
        }
        // turn the max on permanently
        bank[max_id].on = true;
    }
    return max_v;
}

test "max_voltage" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var bank: []Battery = undefined;

    const string = "987654321111111";
    bank = try allocator.alloc(Battery, string.len);
    try parse_bank(string, bank);
    try std.testing.expect(max_voltage(bank, 3) == 987);
    allocator.free(bank);

    const string2 = "234234234234278";
    bank = try allocator.alloc(Battery, string2.len);
    try parse_bank(string2, bank);
    try std.testing.expect(max_voltage(bank, 1) == 8);
    try std.testing.expect(max_voltage(bank, 2) == 78);
    try std.testing.expect(max_voltage(bank, 12) == 434234234278);
    allocator.free(bank);

    const string3 = "818181911112111";
    bank = try allocator.alloc(Battery, string3.len);
    try parse_bank(string3, bank);
    try std.testing.expect(max_voltage(bank, 12) == 888911112111);
    allocator.free(bank);
}

pub fn part_two(file_name: []const u8) !u64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var file = try std.fs.cwd().openFile(file_name, .{ .mode = .read_only });
    defer file.close();
    const content = try std.fs.cwd().readFileAlloc(file_name, allocator, .unlimited);
    defer allocator.free(content);

    var total: u64 = 0;
    var banks = std.mem.splitAny(u8, content[0 .. content.len - 1], "\n");

    while (banks.next()) |string| {
        const bank = try allocator.alloc(Battery, string.len);
        try parse_bank(string, bank);
        total += max_voltage(bank, 12);
        allocator.free(bank);
    }
    return total;
}

test "part_two" {
    const total: u64 = try part_two("test_input");
    try std.testing.expect(total == 3121910778619);
}

pub fn main() !void {
    const file_name = "input";
    const total: u64 = try part_two(file_name);
    std.debug.print("part one: {}\n", .{total});
}
