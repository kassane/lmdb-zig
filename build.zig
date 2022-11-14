const std = @import("std");
const builtin = @import("builtin");

const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    std.debug.print("\nZig Info:\n\nVersion: {}\nStage: {s}\n", .{ builtin.zig_version, @tagName(builtin.zig_backend) });

    b.prominent_compile_errors = true;
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const lmdb = b.addStaticLibrary("lmdb", null);
    lmdb.setTarget(target);
    lmdb.setBuildMode(mode);
    // zig fmt: off
    lmdb.addCSourceFiles(
        &[_][]const u8{ "vendor/lmdb/libraries/liblmdb/mdb.c", "vendor/lmdb/libraries/liblmdb/midl.c" },
        &[_][]const u8{ "-Oz", "-fno-sanitize-trap", "-Wall", "-Wno-unused-parameter", "-Wbad-function-cast", "-Wuninitialized" });
    lmdb.linkLibC();
    lmdb.install();
    // zig fmt: on
    const tests = b.addTest("lmdb.zig");
    tests.setTarget(target);
    tests.use_stage1 = true;
    tests.setBuildMode(mode);
    tests.addIncludePath("vendor/lmdb/libraries/liblmdb");
    tests.linkLibrary(lmdb);

    const test_step = b.step("test", "Run libary tests");
    test_step.dependOn(&tests.step);
}
