const std = @import("std");

pub fn part_one(file_name: []const u8) !u64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var file = try std.fs.cwd().openFile(file_name, .{ .mode = .read_only });
    defer file.close();
    const content = try std.fs.cwd().readFileAlloc(file_name, allocator, .unlimited);
    defer allocator.free(content);

    var count: u64 = 0;
    var count2: u64 = 0;
    count2 = 1;
    var pos: i64 = 50;
    var pos_old: i64 = 50;
    var dist: i64 = undefined;

    var instruction_stream = std.mem.splitAny(u8, content, "\n");
    while (instruction_stream.next()) |turn| {
        pos_old = pos;
        if (turn.len < 1) { continue;}
        dist = try std.fmt.parseInt(u32, turn[1..], 10);
        switch (turn[0]) {
            'L' => { pos = @mod(pos - dist, 100); },
            'R' => { pos = @mod(pos + dist, 100); },
            else => {}
        }
        if (pos == 0) { count = count + 1; }
    }
    return count;
}

pub fn part_two(file_name: []const u8) !u64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var file = try std.fs.cwd().openFile(file_name, .{ .mode = .read_only });
    defer file.close();
    const content = try std.fs.cwd().readFileAlloc(file_name, allocator, .unlimited);
    defer allocator.free(content);

    var count2: u64 = 0;
    var pos: i64 = 50;
    var dist: i64 = undefined;

    var instruction_stream = std.mem.splitAny(u8, content, "\n");
    while (instruction_stream.next()) |turn| {
        if (turn.len < 1) continue;
        dist = try std.fmt.parseInt(u32, turn[1..], 10);
        if (dist == 0) continue;
        switch (turn[0]) {
            'L' => {
                while (dist > 0): (dist -= 1) {
                    pos = @mod(pos - 1, 100);
                    if (pos == 0) { count2 += 1; }
                }
            },
            'R' => {
                while (dist > 0): (dist -= 1) {
                    pos = @mod(pos + 1, 100);
                    if (pos == 0) { count2 += 1; }
                }
                pos = pos + dist;
                if (pos >= 100 ) { count2 += 1; }
            },
            else => {}
        }

        // std.debug.print("{s}\t", .{turn});
        // std.debug.print("{}\t", .{pos});
        // std.debug.print("{}\n", .{count2});
    }

    return count2;
}

pub fn main() !void {

// const file_name = "test_input";
    const file_name = "input";
    const count1: u64 = try part_one(file_name);
    std.debug.print("part one: {}\n", .{count1});
    const count2: u64 = try part_two(file_name);
    std.debug.print("part two: {}\n", .{count2});
}


test "part_one" {
    const count: u64 = try part_one("test_input");
    try std.testing.expect(count == 3);
}

test "part_two" {
    const count: u64 = try part_two("test_input");
    try std.testing.expect(count == 6);
}
