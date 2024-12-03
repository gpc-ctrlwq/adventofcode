const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("./d01-1_input.txt", .{});
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const lineBuf = try allocator.alloc(u8, 15);
    defer allocator.free(lineBuf);

    var string: ?[]const u8 = undefined;
    const listLength = 1000;
    const leftList = try allocator.alloc(u64, listLength);
    const rightList = try allocator.alloc(u64, listLength);
    defer allocator.free(leftList);
    defer allocator.free(rightList);

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

    // get frequency of each value in right list
    // map key is the list value, map value is frequency
    var map = std.AutoHashMap(u64, u64).init(allocator);
    defer map.deinit();
    for (0..listLength) |ii| {
        const entry = try map.getOrPut(rightList[ii]);
        if (!entry.found_existing) {
            entry.value_ptr.* = 1;
        } else {
            entry.value_ptr.* += 1;
        }
    }

    // calc similarity score
    var similarityScore: u64 = 0;
    for (0..listLength) |ii| {
        const value = map.get(leftList[ii]);
        if (value != null) {
            similarityScore += leftList[ii] * value.?;
        }
    }

    // print
    _ = try std.io.getStdOut().writer().print("Similarity score: {d}\n", .{similarityScore});
}
