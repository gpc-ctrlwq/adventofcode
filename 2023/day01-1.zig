const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("./day01-1_input.txt", .{});
    defer file.close();

    const allocator = std.heap.page_allocator;
    const lineBuf = try allocator.alloc(u8, 150);
    defer allocator.free(lineBuf);

    var sum: u64 = 0;
    var digit1: u8 = 0;
    var digit2: u8 = 0;
    var char: u8 = 0;
    var index: u8 = 0;

    var line: ?[]const u8 = null;

    while (true) {
        // get line
        line = try file.reader().readUntilDelimiterOrEof(lineBuf, '\n');
        if (line == null) {
            break;
        }

        // get first and last chars that are digits
        while (char != 13) {
            char = line.?[index];
            if (char >= '0' and char <= '9') {
                if (digit1 == 0) {
                    digit1 = char;
                }
                digit2 = char;
            }
            index += 1;
        }

        sum += (try std.fmt.charToDigit(digit1, 10) * 10) + try std.fmt.charToDigit(digit2, 10);

        digit1 = 0;
        digit2 = 0;
        char = 0;
        index = 0;
    }

    _ = try std.io.getStdOut().writer().print("Total: {d}\n", .{sum});
}
