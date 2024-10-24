//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");

const raylib = @import("raylib");

const MainState = enum { logo, main_menu, town, battle, rewards };

pub const GameState = struct {
    state: MainState = MainState.logo,
};

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // Don't forget to flush!

    raylib.initWindow(400, 200, "test");
    defer raylib.closeWindow();
    raylib.setTargetFPS(60);

    var gamestate = GameState{};

    while (!raylib.windowShouldClose()) {
        try updateFrame(&gamestate);
        drawFrame(&gamestate);
    }
}

pub fn updateFrame(game: *GameState) !void {
    const newState = switch (game.state) {
        MainState.logo => MainState.main_menu,
        MainState.main_menu => MainState.town,
        MainState.town => MainState.battle,
        MainState.battle => MainState.rewards,
        MainState.rewards => MainState.logo,
    };

    game.state = newState;
}

pub fn drawFrame(game: *GameState) void {
    raylib.beginDrawing();
    defer raylib.endDrawing();

    raylib.clearBackground(raylib.Color.white);

    switch (game.state) {
        MainState.logo => raylib.drawText("uzir", 30, 30, 10, raylib.Color.gray),
        MainState.main_menu => raylib.drawText("Uzir", 30, 30, 10, raylib.Color.gray),
        MainState.town => raylib.drawText("uZir", 30, 30, 10, raylib.Color.gray),
        MainState.battle => raylib.drawText("uzIr", 30, 30, 10, raylib.Color.gray),
        MainState.rewards => raylib.drawText("uziR", 30, 30, 10, raylib.Color.gray),
    }
}

//test "simple test" {
//    var list = std.ArrayList(i32).init(std.testing.allocator);
//    defer list.deinit(); // Try commenting this out and see if zig detects the memory leak!
//    try list.append(42);
//    try std.testing.expectEqual(@as(i32, 42), list.pop());
//}

// test "fuzz example" {
// Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
//    const input_bytes = std.testing.fuzzInput(.{});
//    try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input_bytes));
//}
