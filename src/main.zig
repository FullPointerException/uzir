//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");

const raylib = @import("raylib");

const MainState = enum { logo, main_menu, town, battle, rewards };

const CmdLineArgs = struct {
    window_width: i32 = 640,
    window_height: i32 = 480,
    target_fps: i32 = 60,
};

pub const GameState = struct {
    state: MainState = MainState.logo,
};

pub fn main() !void {
    const cmd_line_args = try readCmdLineArgs();
    // TODO handle errors nicely

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // Don't forget to flush!

    raylib.initWindow(cmd_line_args.window_width, cmd_line_args.window_height, "UZIR");
    defer raylib.closeWindow();
    raylib.setTargetFPS(cmd_line_args.target_fps);

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

// TODO better errors
pub fn readCmdLineArgs() !CmdLineArgs {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = alloc.deinit();
    var args = try std.process.argsWithAllocator(alloc.allocator());
    defer args.deinit();

    var parsed_args = CmdLineArgs{};

    // Burn the fisrt arg since it's the call path
    _ = args.next();

    //var target_fps: u8 = 60;

    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "--size")) {
            parsed_args.window_width = try std.fmt.parseInt(i32, args.next().?, 10);
            parsed_args.window_height = try std.fmt.parseInt(i32, args.next().?, 10);
        }
        if (std.mem.eql(u8, arg, "--fps")) {
            parsed_args.target_fps = try std.fmt.parseInt(i32, args.next().?, 10);
        }
    }

    return parsed_args;
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
