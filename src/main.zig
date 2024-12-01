const std = @import("std");
const expect = std.testing.expect;
const eql = std.mem.eql;

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    const out: u64 = undefined;

    // Read the input data into two arrays/lists

    // Sort the arrays

    // Accummulate the differences

    try stdout.print("Final answer: {d}\n", .{out});

    try bw.flush(); // don't forget to flush!
}

test "read file test" {
    const file = try std.fs.cwd().openFile("../data/day1_test.txt", .{});
    defer file.close();

    var buffer: [100]u8 = undefined;
    const expected = "3   4\n4   3\n2   5\n1   3\n3   9\n3   3";
    const bytes_read = try file.readAll(&buffer);

    std.debug.print("{s}\n", .{buffer[0..bytes_read]});

    try expect(eql(u8, buffer[0..bytes_read], expected));
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
