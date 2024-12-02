const std = @import("std");
const expect = std.testing.expect;
const eql = std.mem.eql;
const ArrayList = std.ArrayList;
const sort = std.mem.sort;

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    // Read the input data into two arrays/lists
    const allocator = std.heap.page_allocator;

    var l1 = ArrayList(u64).init(allocator);
    defer l1.deinit();
    var l2 = ArrayList(u64).init(allocator);
    defer l2.deinit();
    try readData("data/day1.txt", &l1, &l2);

    // Sort the arrays
    sortArrayListsDesc(&l1, &l2);

    // Accumulate the differences
    const dist = getDistance(&l1, &l2);

    // Part 2

    // Create a hash map storing a count of the numbers
    var map = std.AutoHashMap(u64, u64).init(allocator);
    defer map.deinit();

    try constructFreqMap(&l2, &map);

    const similarity = getSimilarityScore(&l1, &map);

    try stdout.print("Distance: {any}\n", .{dist});
    try stdout.print("Similarity: {any}\n", .{similarity});

    try bw.flush(); // don't forget to flush!
}

test "read file test" {
    const file = try std.fs.cwd().openFile("data/day1_test.txt", .{});
    defer file.close();

    var buffer: [100]u8 = undefined;
    const expected = "3   4\n4   3\n2   5\n1   3\n3   9\n3   3";
    const bytes_read = try file.readAll(&buffer);

    try expect(eql(u8, buffer[0..bytes_read], expected));
}

fn readData(file_name: []const u8, list_1: *ArrayList(u64), list_2: *ArrayList(u64)) !void {
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

        try list_1.append(try std.fmt.parseUnsigned(u64, l1, 10));
        try list_2.append(try std.fmt.parseUnsigned(u64, l2, 10));

        try expect(tokens.next() == null);
    }
}

test "read data test" {
    const allocator = std.heap.page_allocator;

    var l1 = ArrayList(u64).init(allocator);
    defer l1.deinit();
    var l2 = ArrayList(u64).init(allocator);
    defer l2.deinit();
    try readData("data/day1_test.txt", &l1, &l2);

    // std.debug.print("List1: {any}\n", .{l1.items});
    // std.debug.print("List2: {any}\n", .{l2.items});
}

fn sortArrayListsDesc(list_1: *ArrayList(u64), list_2: *ArrayList(u64)) void {
    std.mem.sort(u64, list_1.items, {}, std.sort.asc(u64));
    std.mem.sort(u64, list_2.items, {}, std.sort.asc(u64));
}

test "test sorting" {
    const allocator = std.heap.page_allocator;

    var l1 = ArrayList(u64).init(allocator);
    defer l1.deinit();
    var l2 = ArrayList(u64).init(allocator);
    defer l2.deinit();

    const vals_1 = [_]u64{ 3, 4, 2, 1, 3, 3 };
    try l1.appendSlice(vals_1[0..]);

    const vals_2 = [_]u64{ 4, 3, 5, 3, 9, 3 };
    try l2.appendSlice(vals_2[0..]);

    sortArrayListsDesc(&l1, &l2);

    const out_1 = [_]u64{ 1, 2, 3, 3, 3, 4 };

    const out_2 = [_]u64{ 3, 3, 3, 4, 5, 9 };

    try expect(eql(u64, l1.items, out_1[0..]));
    try expect(eql(u64, l2.items, out_2[0..]));
}

fn getDistance(list_1: *ArrayList(u64), list_2: *ArrayList(u64)) u64 {
    var out: u64 = 0;
    for (list_1.items, list_2.items) |l1, l2| {
        const diff = if (l1 > l2) (l1 - l2) else (l2 - l1);
        out += diff;
    }

    return out;
}

test "test distance" {
    const allocator = std.heap.page_allocator;

    var l1 = ArrayList(u64).init(allocator);
    defer l1.deinit();
    var l2 = ArrayList(u64).init(allocator);
    defer l2.deinit();

    const vals_1 = [_]u64{ 1, 2, 3, 3, 3, 4 };
    try l1.appendSlice(vals_1[0..]);

    const vals_2 = [_]u64{ 3, 3, 3, 4, 5, 9 };
    try l2.appendSlice(vals_2[0..]);

    const dist = getDistance(&l1, &l2);

    try expect(dist == 11);
}

fn constructFreqMap(list_1: *ArrayList(u64), map: *std.AutoHashMap(u64, u64)) !void {
    for (list_1.items) |i| {
        // Increment the previous value or set it to 1
        const prev_val = map.get(i) orelse 0;
        try map.put(i, prev_val + 1);
    }
}

test "construct frequency map" {
    const allocator = std.testing.allocator;

    var l1 = ArrayList(u64).init(allocator);
    defer l1.deinit();
    var map = std.AutoHashMap(u64, u64).init(allocator);
    defer map.deinit();

    const vals_1 = [_]u64{ 3, 4, 2, 1, 3, 3 };
    try l1.appendSlice(vals_1[0..]);

    try constructFreqMap(&l1, &map);

    try expect(map.count() == 4);
}

fn getSimilarityScore(list_1: *ArrayList(u64), map: *std.AutoHashMap(u64, u64)) u64 {
    var out: u64 = 0;

    for (list_1.items) |l1| {
        out += l1 * (map.get(l1) orelse 0); // Multiply by zero if the entry wasn't in the other list
    }

    return out;
}

test "test similarity" {
    const allocator = std.heap.page_allocator;

    var l1 = ArrayList(u64).init(allocator);
    defer l1.deinit();
    var l2 = ArrayList(u64).init(allocator);
    defer l2.deinit();

    const vals_1 = [_]u64{ 1, 2, 3, 3, 3, 4 };
    try l1.appendSlice(vals_1[0..]);

    const vals_2 = [_]u64{ 3, 3, 3, 4, 5, 9 };
    try l2.appendSlice(vals_2[0..]);

    var map = std.AutoHashMap(u64, u64).init(allocator);
    defer map.deinit();

    try constructFreqMap(&l2, &map);

    const similarity = getSimilarityScore(&l1, &map);

    try expect(similarity == 31);
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
