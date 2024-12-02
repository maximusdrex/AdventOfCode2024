const std = @import("std");
const expect = std.testing.expect;
const eql = std.mem.eql;

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    // Read input file
    const file = try std.fs.cwd().openFile("data/day2.txt", .{});
    defer file.close();

    var buffer: [100]u8 = undefined;
    const reader = file.reader();

    var safe_count: u32 = 0;

    // Foreach line, tokenize the input
    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        const delim = [_]u8{' '};
        var tokens = std.mem.tokenize(u8, line, &delim);

        var last_token: ?u32 = null;
        var direction: ?bool = null;

        const safe = token_loop: while (tokens.next()) |new_token| {
            const new_num = try std.fmt.parseUnsigned(u32, new_token, 10);
            //std.debug.print("n: {d}\n", .{new_num});

            if (last_token) |last| {
                if (new_num != last) {
                    const new_dir: bool = new_num > last;

                    // Check direction
                    if (direction) |dir| {
                        if (new_dir != dir) {
                            //std.debug.print("unsafe dir\n", .{});
                            break :token_loop false;
                        }
                    } else {
                        // Set direction if not set before
                        direction = new_dir;
                    }
                    // Check difference
                    const diff = if (new_dir) (new_num - last) else (last - new_num);
                    if (diff > 3) {
                        //std.debug.print("unsafe diff\n", .{});
                        break :token_loop false;
                    }
                } else {
                    //std.debug.print("unsafe ne\n", .{});
                    break :token_loop false;
                }

                last_token = new_num;
            } else {
                last_token = new_num;
            }
        } else {
            //std.debug.print("safe\n", .{});
            break :token_loop true;
        };

        if (safe) safe_count += 1;
    }

    // Print the answer
    try stdout.print("total safe: {d}\n", .{safe_count});

    try bw.flush();
}
