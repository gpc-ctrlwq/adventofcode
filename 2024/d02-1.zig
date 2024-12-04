const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("./d02-1_input.txt", .{});
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const lineBuf = try allocator.alloc(u8, 25);
    defer allocator.free(lineBuf);

    var safeReportCount: u64 = 0;
    var string: ?[]const u8 = undefined;

    var prev: u64 = undefined;
    var curr: u64 = undefined;
    var isIncreasing: ?bool = null;
    var diff: i64 = undefined;

    // for each report
    outer: for (0..1000) |_| {
        string = try file.reader().readUntilDelimiter(lineBuf, '\n');
        var iter = std.mem.splitScalar(u8, string.?, ' ');

        prev = std.zig.parseNumberLiteral(iter.first()).int;
        curr = undefined;
        isIncreasing = null;
        diff = undefined;

        // for each report level
        while (iter.peek() != null) {
            const cleanString = std.mem.trim(u8, iter.next().?, &std.ascii.whitespace);

            curr = std.zig.parseNumberLiteral(cleanString).int;
            defer prev = curr;

            diff = @as(i64, @bitCast(prev)) - @as(i64, @bitCast(curr));

            // set initial direction
            if (isIncreasing == null) {
                if (diff == 0) {
                    // report unsafe
                    continue :outer;
                }
                if (diff < 0) {
                    isIncreasing = true;
                } else {
                    isIncreasing = false;
                }
            }

            // check direction is consistent
            if (diff == 0) {
                // report unsafe
                continue :outer;
            }
            if (diff < 0 and !isIncreasing.? or diff > 0 and isIncreasing.?) {
                // report unsafe
                continue :outer;
            }

            // check delta
            if (@abs(diff) > 3) {
                // report unsafe
                continue :outer;
            }
        }

        // report is safe
        safeReportCount += 1;
    }

    // print
    _ = try std.io.getStdOut().writer().print("Safe report count: {d}\n", .{safeReportCount});
}
