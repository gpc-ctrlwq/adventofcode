const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("./d01-1_input.txt", .{});
    defer file.close();

    const hpa = std.heap.page_allocator;

    const lineBuf = try hpa.alloc(u8, 15);
    defer hpa.free(lineBuf);

    var string: ?[]const u8 = undefined;
    const listLength = 1000;
    const leftList = try hpa.alloc(u64, listLength);
    const rightList = try hpa.alloc(u64, listLength);

    var cleanString: []const u8 = undefined;

    // build lists
    for (0..listLength) |ii| {
        // get left number
        string = try file.reader().readUntilDelimiterOrEof(lineBuf, ' ');
        if (string == null) {
            break;
        }
        leftList[ii] = std.zig.parseNumberLiteral(string.?).int;

        // get right number
        string = try file.reader().readUntilDelimiterOrEof(lineBuf, '\n');
        if (string == null) {
            break;
        }
        cleanString = std.mem.trim(u8, string.?, &std.ascii.whitespace);
        rightList[ii] = std.zig.parseNumberLiteral(cleanString).int;
    }

    // sort lists
    std.mem.sort(u64, leftList, {}, comptime std.sort.asc(u64));
    std.mem.sort(u64, rightList, {}, comptime std.sort.asc(u64));

    // match lowest from each list, calc difference and add to total
    var totalDifference: u64 = 0;
    for (0..listLength) |ii| {
        totalDifference += @max(leftList[ii], rightList[ii]) - @min(leftList[ii], rightList[ii]);
    }

    // print
    _ = try std.io.getStdOut().writer().print("Total difference: {d}\n", .{totalDifference});
}
