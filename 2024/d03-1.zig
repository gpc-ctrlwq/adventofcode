const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("./d03-1_input.txt", .{});
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const lineBuf = try allocator.alloc(u8, 4000);
    defer allocator.free(lineBuf);

    var string: ?[]const u8 = undefined;
    var aStr: [3]u8 = [3]u8{ 0, 0, 0 };
    var bStr: [3]u8 = [3]u8{ 0, 0, 0 };

    for (0..1000) |_| {
        string = try file.reader().readUntilDelimiterOrEof(lineBuf, '\n');
        var iter = std.mem.splitSequence(u8, string.?, "mul(");

        outer: while (iter.next()) |operandStr| {
            // get aStr
            for (0..3) |ii| {
                if (std.ascii.isDigit(operandStr[ii])) {
                    aStr[ii] = operandStr[ii];
                } else if (operandStr[ii] == ',' and ii > 0) {
                    // we have the first number
                    break;
                } else {
                    // invalid char, zero strings, go next
                    aStr = std.mem.zeroes(@TypeOf(aStr));
                    continue :outer;
                }
            }

            // TODO check for comma if it hasn't already been reached

            // get bStr
            for (0..3) |ii| {
                if (std.ascii.isDigit(operandStr[ii])) {
                    bStr[ii] = operandStr[ii];
                } else if (operandStr[ii] == ')' and ii > 0) {
                    // we have the second number
                    break;
                } else {
                    // invalid char, zero strings, go next
                    aStr = std.mem.zeroes(@TypeOf(aStr));
                    bStr = std.mem.zeroes(@TypeOf(bStr));
                    continue :outer;
                }
            }

            // TODO check for closing parentheses if it hasn't already been reached

            // TODO convert to numbers, multiply and add to total
        }
    }
}
