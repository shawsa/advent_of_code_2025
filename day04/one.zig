const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;

const TileError = error{
    BadChar,
};

const Tile = enum(u8) {
    ROLL = '@',
    SPACE = '.',

    pub fn fromChar(char: u8) TileError!Tile {
        const e = switch (char) {
            '@' => Tile.ROLL,
            '.' => Tile.SPACE,
            else => TileError.BadChar,
        };
        return e;
    }
};

test "Tile" {
    try expect(try Tile.fromChar('@') == Tile.ROLL);
    try expect(try Tile.fromChar('.') == Tile.SPACE);
    try std.testing.expectError(TileError.BadChar, Tile.fromChar('X'));
}

const Grid = struct {
    data: []Tile,
    width: u64,
    height: u64,

    pub fn get(self: Grid, row: u64, col: u64) !Tile {
        return self.data[col + row * self.width];
    }

    pub fn isTile(self: Grid, tile: Tile, row: u64, col: u64) bool {
        return tile == (self.get(row, col) catch Tile.SPACE);
    }

    pub fn adj_like(self: Grid, tile: Tile, row: u64, col: u64) u8 {
        if (row > self.height or col > self.width) return 0;
        var num: u8 = 0;
        // top left
        if (row > 0 and col > 0 and self.isTile(tile, row - 1, col - 1)) num += 1;
        // top
        if (row > 0 and self.isTile(tile, row - 1, col)) num += 1;
        // top right
        if (row > 0 and col < (self.width - 1) and self.isTile(tile, row - 1, col + 1)) num += 1;
        // left
        if (col > 0 and self.isTile(tile, row, col - 1)) num += 1;
        // right
        if (col < self.width - 1 and self.isTile(tile, row, col + 1)) num += 1;
        // bottom left
        if (row < (self.height - 1) and col > 0 and self.isTile(tile, row + 1, col - 1)) num += 1;
        // bottom
        if (row < self.height - 1 and self.isTile(tile, row + 1, col)) num += 1;
        // bottom right
        if (row < self.height - 1 and col < self.width - 1 and self.isTile(tile, row + 1, col + 1)) num += 1;
        return num;
    }
};

test "Grid" {
    var data = [_]Tile{
        Tile.ROLL,  Tile.ROLL,  Tile.SPACE,
        Tile.SPACE, Tile.ROLL,  Tile.SPACE,
        Tile.SPACE, Tile.SPACE, Tile.SPACE,
        Tile.SPACE, Tile.ROLL,  Tile.SPACE,
        Tile.SPACE, Tile.SPACE, Tile.SPACE,
    };
    var grid = Grid{
        .data = data[0..],
        .height = 5,
        .width = 3,
    };
    try expect(try grid.get(0, 0) == Tile.ROLL);
    try expect(try grid.get(0, 1) == Tile.ROLL);
    try expect(try grid.get(0, 2) == Tile.SPACE);
    try expect(try grid.get(1, 0) == Tile.SPACE);

    try expect(grid.isTile(Tile.SPACE, 1, 0) == true);
    try expect(grid.isTile(Tile.SPACE, 0, 1) == false);

    try expect(grid.adj_like(Tile.SPACE, 0, 0) == 1);
    try expect(grid.adj_like(Tile.SPACE, 200, 3) == 0);
    try expect(grid.adj_like(Tile.SPACE, 3, 1) == 8);
}

pub fn parseGrid(allocator: std.mem.Allocator, string: []u8) !Grid {
    var data: []Tile = try allocator.alloc(Tile, string.len);
    var instruction_stream = std.mem.splitAny(u8, string, "\n");
    var height: u64 = 0;
    var total: u64 = 0;
    while (instruction_stream.next()) |row| {
        if (row.len == 0 or row[0] == '\n') continue;
        height += 1;
        for (row) |char| {
            if (char == '\n') break;
            data[total] = try Tile.fromChar(char);
            total += 1;
        }
    }
    return Grid{
        .data = data,
        .height = height,
        .width = total / height,
    };
}

test "parse_grid" {
    const file_name = "test_input";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var file = try std.fs.cwd().openFile(file_name, .{ .mode = .read_only });
    defer file.close();
    const content = try std.fs.cwd().readFileAlloc(file_name, allocator, .unlimited);
    defer allocator.free(content);

    var grid: Grid = try parseGrid(allocator, content);

    try expect(try grid.get(0, 0) == Tile.SPACE);
    try expect(try grid.get(9, 9) == Tile.SPACE);
    try expect(try grid.get(0, 2) == Tile.ROLL);

    allocator.free(grid.data);
}

pub fn count_acceissible(grid: Grid) u64 {
    // print("\n", .{});
    var total: u64 = 0;
    for (0..grid.height) |row| {
        for (0..grid.width) |col| {
            if (try grid.get(row, col) == Tile.SPACE) {
                // print(".", .{});
                continue;
            }
            const adj = grid.adj_like(Tile.ROLL, row, col);
            // print("{}", .{adj});
            if (adj < 4) {
                total += 1;
                // print("x", .{});
            } else {
                // print("@", .{});
            }
        }
        // print("\n", .{});
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

    var grid: Grid = try parseGrid(allocator, content);
    const total = count_acceissible(grid);
    allocator.free(grid.data);
    try expect(total == 13);
}

pub fn main() !void {
    const file_name = "input";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var file = try std.fs.cwd().openFile(file_name, .{ .mode = .read_only });
    defer file.close();
    const content = try std.fs.cwd().readFileAlloc(file_name, allocator, .unlimited);
    defer allocator.free(content);

    var grid: Grid = try parseGrid(allocator, content);
    const total = count_acceissible(grid);
    allocator.free(grid.data);
    std.debug.print("part one: {}\n", .{total});
}
