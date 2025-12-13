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

const Homework = struct {
    rows: u64,
    cols: u64,
    nums: []u64,
    ops: []Op,

    pub fn parse(content: []u8, rows: u64, cols: u64, nums: []u64, ops: []Op) !Homework {
        var lines = std.mem.splitAny(u8, content, "\n");
        var r: u64 = 0;
        var c: u64 = 0;
        while (lines.next()) |line| : (r += 1) {
            var tokens = std.mem.splitAny(u8, line, " ");
            c = 0;
            while (tokens.next()) |token| {
                if (token.len == 0) continue;
                nums[c + r * cols] = try std.fmt.parseInt(u64, token, 10);
                c += 1;
            }
            if (r == rows - 1) break;
        }
        var tokens = std.mem.splitAny(u8, lines.next().?, " ");
        c = 0;
        while (tokens.next()) |token| {
            if (token.len == 0) continue;
            ops[c] = try Op.fromChar(token[0]);
            c += 1;
        }
        return Homework{
            .rows = rows,
            .cols = cols,
            .nums = nums,
            .ops = ops,
        };
    }

    pub fn eval(self: Homework) u64 {
        var total: u64 = 0;
        for (0..self.cols) |c| {
            var subtotal: u64 = undefined;
            switch (self.ops[c]) {
                Op.ADD => {
                    subtotal = 0;
                    for (0..self.rows) |r| {
                        subtotal += self.nums[c + r * self.cols];
                    }
                },
                Op.MUL => {
                    subtotal = 1;
                    for (0..self.rows) |r| {
                        subtotal *= self.nums[c + r * self.cols];
                    }
                },
            }
            total += subtotal;
        }
        return total;
    }
};

pub fn count_rows_and_cols(content: []u8) [2]u64 {
    var rows: u64 = 0;
    var cols: u64 = 0;
    for (content) |c| {
        switch (c) {
            '+' => cols += 1,
            '*' => cols += 1,
            '\n' => rows += 1,
            else => {},
        }
    }
    // last row is row of ops
    return [2]u64{ rows - 1, cols };
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

    const nums: []u64 = try allocator.alloc(u64, rows * cols);
    const ops: []Op = try allocator.alloc(Op, cols);
    defer allocator.free(nums);
    defer allocator.free(ops);

    const hw = try Homework.parse(content, rows, cols, nums, ops);
    std.debug.print("\n", .{});
    for (0..hw.rows) |r| {
        for (0..hw.cols) |c| {
            std.debug.print("{}\t", .{hw.nums[c + r * hw.cols]});
        }
        std.debug.print("\n", .{});
    }
    for (0..hw.cols) |c| {
        std.debug.print("{}\t", .{hw.ops[c]});
    }
    std.debug.print("\n", .{});

    try expect(hw.rows == 3);
    try expect(hw.cols == 4);
    try expect(hw.eval() == 4277556);
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

    const nums: []u64 = try allocator.alloc(u64, rows * cols);
    const ops: []Op = try allocator.alloc(Op, cols);
    defer allocator.free(nums);
    defer allocator.free(ops);

    const hw = try Homework.parse(content, rows, cols, nums, ops);
    std.debug.print("{}\n", .{hw.eval()});
}
