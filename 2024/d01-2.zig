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

    const Frequency = struct {
        l: u64,
        r: u64,
    };

    // get frequency of each value in each list
    var map = std.AutoHashMap(u64, Frequency).init(hpa);
    defer map.deinit();

    var val: u64 = undefined;
    for (0..listLength) |ii| {
        val = leftList[ii];
        var entry = try map.getOrPut(val);
        if (!entry.found_existing) {
            entry.value_ptr.l = 1;
            entry.value_ptr.r = 0;
        } else {
            entry.value_ptr.l += 1;
        }

        for (0..listLength) |kk| {
            if (rightList[kk] == val) {
                entry.value_ptr.r += 1;
            }
        }
    }

    // calc similatiry score
    var similarityScore: u64 = 0;
    var iter = map.iterator();

    while (iter.next()) |entry| {
        similarityScore += (entry.key_ptr.* * entry.value_ptr.l * entry.value_ptr.r);
    }

    // print
    _ = try std.io.getStdOut().writer().print("Similarity score: {d}\n", .{similarityScore});
}
