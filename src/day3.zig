const std = @import("std");
const expect = std.testing.expect;
const eql = std.mem.eql;
const ArrayListU8 = std.ArrayList(u8);

const MatchState = enum { unmatched, fn_name, paren_open, num1, num2 };

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        //fail test; can't try in defer as defer is executed after we return
        if (deinit_status == .leak) expect(false) catch std.debug.print("leaked\n", .{});
    }

    const data = try getData(allocator, "data/day3.txt");
    defer {
        allocator.free(data);
    }

    var state: MatchState = MatchState.unmatched;
    const expected_name = "mul";
    var matched_name = ArrayListU8.init(allocator);
    defer matched_name.deinit();

    var count: i32 = 0;

    var n1 = ArrayListU8.init(allocator);
    var n2 = ArrayListU8.init(allocator);
    defer {
        n1.deinit();
        n2.deinit();
    }

    std.debug.print("Starting match\n", .{});

    for (data) |char| {
        std.debug.print("Matching {c} at {any}\n", .{ char, state });
        switch (state) {
            .unmatched => {
                if (char == 'm') {
                    state = .fn_name;
                    matched_name.clearAndFree();
                    try matched_name.append(char);
                } else {
                    state = .unmatched;
                }
            },
            .fn_name => {
                if (char == expected_name[matched_name.items.len]) {
                    try matched_name.append(char);
                } else {
                    state = .unmatched;
                }

                if (state == .fn_name and eql(u8, expected_name, matched_name.items)) {
                    state = .paren_open;
                }
            },
            .paren_open => {
                if (char == '(') {
                    state = .num1;
                    n1.clearAndFree();
                    n2.clearAndFree();
                }
            },
            .num1 => {
                if (char == ',' and n1.items.len > 0) {
                    state = .num2;
                } else if (isDigit(char) and n1.items.len < 3) {
                    try n1.append(char);
                } else {
                    state = .unmatched;
                }
            },
            .num2 => {
                if (char == ')' and n2.items.len > 0) {
                    count += try std.fmt.parseInt(i32, n1.items, 10) * try std.fmt.parseInt(i32, n2.items, 10);
                    std.debug.print("Count: {d}\n", .{count});
                    state = .unmatched;
                } else if (isDigit(char) and n2.items.len < 3) {
                    try n2.append(char);
                } else {
                    state = .unmatched;
                }
            },
        }
    }

    try stdout.print("Answer: {d}\n", .{count});

    try bw.flush();
}

fn isDigit(c: u8) bool {
    return c >= '0' and c <= '9';
}

fn getData(allocator: std.mem.Allocator, file_name: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();

    return try file.readToEndAlloc(allocator, 50000);
}

test "read file test" {
    const alloc = std.testing.allocator;

    const expected = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";
    const file_data = getData(alloc, "../data/day3_test.txt");

    try expect(eql(u8, file_data, expected));
}
