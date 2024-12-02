const std = @import("std");
const expect = std.testing.expect;
const eql = std.mem.eql;
const ArrayList = std.ArrayList;

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    const out: u64 = undefined;

    // Read the input data into two arrays/lists

    // Sort the arrays

    // Accumulate the differences

    try stdout.print("Final answer: {d}\n", .{out});

    try bw.flush(); // don't forget to flush!
}

test "read file test" {
    const file = try std.fs.cwd().openFile("../data/day1_test.txt", .{});
    defer file.close();

    var buffer: [100]u8 = undefined;
    const expected = "3   4\n4   3\n2   5\n1   3\n3   9\n3   3";
    const bytes_read = try file.readAll(&buffer);

    try expect(eql(u8, buffer[0..bytes_read], expected));
}

fn read_data(file_name: []const u8, list_1: *ArrayList(u32), list_2: *ArrayList(u32)) !void {
    const file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();

    var buffer: [100]u8 = undefined;
    const reader = file.reader();

    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        const delim = [_]u8{' '};
        var tokens = std.mem.tokenize(u8, line, &delim);

        const l1 = tokens.next().?;
        const l2 = tokens.next().?;

        // std.debug.print("{s} {s}\n", .{ l1, l2 });

        try list_1.append(try std.fmt.parseUnsigned(u32, l1, 10));
        try list_2.append(try std.fmt.parseUnsigned(u32, l2, 10));

        try expect(tokens.next() == null);
    }
}

test "read data test" {
    const allocator = std.heap.page_allocator;

    var l1 = ArrayList(u32).init(allocator);
    var l2 = ArrayList(u32).init(allocator);
    try read_data("../data/day1_test.txt", &l1, &l2);

    // std.debug.print("List1: {any}\n", .{l1.items});
    // std.debug.print("List2: {any}\n", .{l2.items});
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
