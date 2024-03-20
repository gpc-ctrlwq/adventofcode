const std = @import("std");
const Allocator = std.mem.Allocator;

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
    var lineIdx: u8 = 0;

    var line: ?[]const u8 = null;

    // init search trie
    var searchTrie: TrieStructure = .{};
    try searchTrie.init(allocator, 26);
    try searchTrie.addWord("one");
    try searchTrie.addWord("two");
    try searchTrie.addWord("three");

    try searchTrie.print();

    while (true) {
        // get line
        line = try file.reader().readUntilDelimiterOrEof(lineBuf, '\n');
        if (line == null) {
            break;
        }

        // get first and last numbers in line
        while (char != 13) {
            char = line.?[lineIdx];

            // if single char number
            if (char >= '0' and char <= '9') {
                if (digit1 == 0) {
                    digit1 = char;
                }
                digit2 = char;
            }

            // if number as word
            // todo search char in tree, update current node
            //currentNode = ;

            lineIdx += 1;
        }

        sum += (try std.fmt.charToDigit(digit1, 10) * 10) + try std.fmt.charToDigit(digit2, 10);

        digit1 = 0;
        digit2 = 0;
        char = 0;
        lineIdx = 0;
    }

    _ = try std.io.getStdOut().writer().print("Total: {d}\n", .{sum});
}

const TrieNode = struct {
    children: ?[]TrieNode = null,
    val: u8 = 0,
    isEndOfWord: bool = false,

    // TODO
    pub fn getChildWithVal(self: TrieNode, val: u8) ?TrieNode {
        _ = val;
        _ = self;
    }
};

const TrieStructure = struct {
    arena: std.heap.ArenaAllocator = undefined,
    allocator: Allocator = undefined,
    children: []TrieNode = undefined,
    width: u8 = 0,

    pub fn init(self: *TrieStructure, allocator: Allocator, width: u8) !void {
        self.arena = std.heap.ArenaAllocator.init(allocator);
        self.allocator = allocator;
        self.width = width;
        self.children = try self.allocator.alloc(TrieNode, self.width);
    }

    pub fn deinit(self: TrieStructure) void {
        self.allocator.deinit();
    }

    pub fn print(self: TrieNode) !void {
        std.debug.print("print()\n", .{});
        if (self.children) |children| {
            std.debug.print("len{d}\n", .{self.children.?.len});
            for (children) |child| {
                std.debug.print("{d}\n", .{child.val});
                try child.print();
            }
        }
    }

    pub fn addWord(self: TrieStructure, word: []const u8) !void {
        //TODO
        var currentNode: TrieNode = self.children;

        for (word) |char| {
            // offset char ascii value to children index
            // NOTE: assumes lowercase alpha only
            const index = char - 97;

            // if children is uninitialized, init
            if (currentNode.children == null) {
                currentNode.children = try self.allocator.alloc(TrieNode, self.width);
            }

            // if no match at this depth add child obj
            if (currentNode.children.?[index].val != char) {
                currentNode.children.?[index] = .{ .val = char };
            }
            // char exists at this depth, go next
            currentNode = currentNode.children.?[index];
        }
        //TODO
        //currentNode.isEndOfWord = true;
    }
};
