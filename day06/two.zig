const std = @import("std");
const expect = std.testing.expect;

const OpError = error{
    BadChar,
};

const Op = enum(u8) {
    ADD = '+',
    MUL = '*',

    pub fn fromChar(char: u8) !Op {
        const e = switch (char) {
            '+' => Op.ADD,
            '*' => Op.MUL,
            else => OpError.BadChar,
        };
        return e;
    }
};

pub fn count_rows_and_cols(content: []u8) [2]u64 {
    var cols: u64 = 0;
    for (content) |c| {
        switch (c) {
            '\n' => {
                break;
            },
            else => {
                cols += 1;
            },
        }
    }
    cols += 1; // account for newline
    var rows: u64 = 0;
    for (content) |c| {
        switch (c) {
            '\n' => {
                rows += 1;
            },
            else => {},
        }
    }
    return [2]u64{ rows - 1, cols };
}

pub fn eval_part_two(content: []u8, rows: u64, cols: u64) !u64 {
    const op_row = rows;
    var total: u64 = 0;
    var c: u64 = 0;
    while (true) {
        const op_char = content[c + op_row * cols];
        if (op_char == '\n') break;
        const op: Op = try Op.fromChar(op_char);
        var end: u64 = c + 1;
        while (content[end + op_row * cols] == ' ') : (end += 1) {}
        var subtotal: u64 = 0;
        switch (op) {
            Op.ADD => subtotal = 0,
            Op.MUL => subtotal = 1,
        }
        var c2 = end - 1;
        if (content[c2 + 1] == '\n') c2 += 1; // last col has no space
        for (c..c2) |i| {
            var num: u64 = 0;
            for (0..rows) |r| {
                const string = &[_]u8{content[i + r * cols]};
                if (string[0] == ' ') continue;
                num *= 10;
                num += try std.fmt.parseInt(u64, string, 10);
            }
            switch (op) {
                Op.ADD => subtotal += num,
                Op.MUL => subtotal *= num,
            }
        }
        total += subtotal;
        c = end;
    }

    return total;
}

test "test input" {
    const file_name = "test_input";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var file = try std.fs.cwd().openFile(file_name, .{ .mode = .read_only });
    defer file.close();
    const content = try std.fs.cwd().readFileAlloc(file_name, allocator, .unlimited);
    defer allocator.free(content);

    var rows: u64 = undefined;
    var cols: u64 = undefined;
    rows, cols = count_rows_and_cols(content);
    try expect(rows == 3);

    try expect(try eval_part_two(content, rows, cols) == 3263827);
    // try expect(try eval_part_two(content, rows, cols) == 2);
}

pub fn main() !void {
    // const file_name = "test_input";
    const file_name = "input";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var file = try std.fs.cwd().openFile(file_name, .{ .mode = .read_only });
    defer file.close();
    const content = try std.fs.cwd().readFileAlloc(file_name, allocator, .unlimited);
    defer allocator.free(content);

    var rows: u64 = undefined;
    var cols: u64 = undefined;
    rows, cols = count_rows_and_cols(content);

    std.debug.print("{}\n", .{try eval_part_two(content, rows, cols)});
}
