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
    var lineIdx: u8 = 0;

    var line: ?[]const u8 = null;

    // init search trie
    const searchTrie = TrieNode.newTrieNode();
    searchTrie.addWord("one");
    var trieDepth: u8 = 0;

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

            // if number word
            // todo search char in tree, update depth var
            trieDepth = 0;

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
    children: ?[26]*TrieNode,
    val: u8,
    isEndOfWord: bool = false,

    pub fn newTrieNode() TrieNode {
        return .{
            .children = null,
            .isEndOfWord = false,
            .val = 0,
        };
    }

    pub fn addWord(self: *const TrieNode, val: []const u8) void {
        var currentNode = self;

        ch: for (val) |char| {
            if (currentNode.children) |children| {
                for (children) |child| {
                    if (child.val == char) {
                        // char already exists at this depth, go next
                        currentNode = child;
                        continue :ch;
                    }
                }
            }

            // if no match at this depth, add a new node for char
            currentNode.children[char] = TrieNode;
            currentNode = &currentNode.children[char];
        }
        currentNode.isEndOfWord = true;
    }

    pub fn deinit() void {
        // TODO
        // self.children.deinit
    }
};
