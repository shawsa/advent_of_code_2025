const std = @import("std");
const expect = std.testing.expect;

const Range = struct {
    lower: u64,
    upper: u64,

    pub fn fromStr(string: []const u8) !Range {
        const trimed = std.mem.trim(u8, string, &std.ascii.whitespace);
        var chunks = std.mem.splitAny(u8, trimed, "-");
        const lower = try std.fmt.parseInt(u64, chunks.next().?, 10);
        const upper = try std.fmt.parseInt(u64, chunks.next().?, 10);
        return Range{
            .lower = lower,
            .upper = upper,
        };
    }

    pub fn contains(self: Range, id: u64) bool {
        return self.lower <= id and id <= self.upper;
    }

    pub fn print(self: Range) []u8 {
        std.debug.print("{}-{}\n", .{ self.lower, self.upper });
    }

    pub fn numIds(self: Range) u64 {
        return self.upper - self.lower + 1;
    }
};

test "Range" {
    const range = try Range.fromStr(" 123-456 \n"[0..]);
    try expect(range.lower == 123);
    try expect(range.upper == 456);

    try expect(range.contains(200) == true);
    try expect(range.contains(2000) == false);

    const range2 = try Range.fromStr("11-20 \n"[0..]);
    try expect(range2.numIds() == 10);
}

pub fn count_ranges_and_ids(text: []const u8) [2]u64 {
    var lines = std.mem.splitAny(u8, text, "\n");
    var ranges: u64 = 0;
    var ids: u64 = 0;

    var past_ranges: bool = false;
    while (lines.next()) |line| {
        if (line.len == 0) {
            past_ranges = true;
            continue;
        }
        if (past_ranges) {
            ids += 1;
            continue;
        }
        ranges += 1;
    }
    return .{ ranges, ids };
}

test "count ranges and ids" {
    const my_string = "123-123\n234-234\n123-123\n\n1\n2\n3\n4\n";
    var count = count_ranges_and_ids(my_string);
    try expect(count[0] == 3);
    try expect(count[1] == 4);
}

pub fn parseInput(text: []const u8, ranges: []Range, ids: []u64) !void {
    var lines = std.mem.splitAny(u8, text, "\n");
    var i: usize = 0;
    while (lines.next()) |line| : (i += 1) {
        if (line.len == 0) {
            break;
        }
        ranges[i] = try Range.fromStr(line);
    }
    i = 0;
    while (lines.next()) |line| : (i += 1) {
        if (line.len == 0) {
            break;
        }
        ids[i] = try std.fmt.parseInt(u64, line, 10);
    }
}

test "parse input" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const my_string = "123-123\n234-234\n123-123\n\n1\n2\n3\n4\n";
    const count = count_ranges_and_ids(my_string);
    var ranges = try allocator.alloc(Range, count[0]);
    var ids = try allocator.alloc(u64, count[1]);
    defer allocator.free(ranges);
    defer allocator.free(ids);

    try parseInput(my_string, ranges, ids);

    try expect(ranges[0].lower == 123);
    try expect(ranges[0].upper == 123);
    try expect(ranges[1].lower == 234);
    try expect(ranges[1].upper == 234);
    try expect(ranges[2].lower == 123);
    try expect(ranges[2].upper == 123);
    try expect(ids[0] == 1);
    try expect(ids[3] == 4);
}

const RangeLinkedList = struct {
    next_node: ?*RangeLinkedList = null,
    range: *Range,

    pub fn populate(ranges: []Range, nodes: []RangeLinkedList) void {
        for (0..ranges.len) |i| {
            nodes[i].range = &ranges[i];
        }
        for (0..nodes.len - 1) |i| {
            nodes[i].next_node = &nodes[i + 1];
        }
    }
};

test "range linked list" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const my_string = "123-123\n234-234\n123-123\n\n1\n2\n3\n4\n";
    const count = count_ranges_and_ids(my_string);
    const ranges = try allocator.alloc(Range, count[0]);
    const nodes = try allocator.alloc(RangeLinkedList, count[0]);
    const ids = try allocator.alloc(u64, count[1]);
    defer allocator.free(ranges);
    defer allocator.free(ids);
    defer allocator.free(nodes);

    try parseInput(my_string, ranges, ids);
    RangeLinkedList.populate(ranges, nodes);

    var num_nodes: u64 = 0;
    var it = nodes[0];
    while (range_list.next()) {
        num_nodes += 1;
    }
    try expect(num_nodes == 3);

    try expect(true); // #########################################################################
}

pub fn count_possible_fresh(ranges: []Range) u64 {
    var count: u64 = 0;
    for (ranges) |range| {
        count += range.numIds();
    }
    return count;
}

// test "test input" {
//     const file_name = "test_input";
//     var gpa = std.heap.GeneralPurposeAllocator(.{}){};
//     defer _ = gpa.deinit();
//     const allocator = gpa.allocator();
//     var file = try std.fs.cwd().openFile(file_name, .{ .mode = .read_only });
//     defer file.close();
//     const content = try std.fs.cwd().readFileAlloc(file_name, allocator, .unlimited);
//     defer allocator.free(content);
//     const count = count_ranges_and_ids(content);
//     const ranges = try allocator.alloc(Range, count[0]);
//     const ids = try allocator.alloc(u64, count[1]);
//     defer allocator.free(ranges);
//     defer allocator.free(ids);

//     try parseInput(content, ranges, ids);

//     const num_fresh = count_possible_fresh(ranges);
//     std.debug.print("\n{}\n", .{num_fresh});
//     try expect(num_fresh == 13);
// }

pub fn main() !void {
    const file_name = "input";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var file = try std.fs.cwd().openFile(file_name, .{ .mode = .read_only });
    defer file.close();
    const content = try std.fs.cwd().readFileAlloc(file_name, allocator, .unlimited);
    defer allocator.free(content);
    const count = count_ranges_and_ids(content);
    const ranges = try allocator.alloc(Range, count[0]);
    const ids = try allocator.alloc(u64, count[1]);
    defer allocator.free(ranges);
    defer allocator.free(ids);

    try parseInput(content, ranges, ids);

    const num_fresh = count_possible_fresh(ranges);
    std.debug.print("{}\n", .{num_fresh});
}
