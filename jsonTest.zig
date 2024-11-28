const std = @import("std");

const Place = struct {
    lat: f32,
    long: f32,
};

const x = Place{
    .lat = 51.997664,
    .long = -0.740687,
};

pub fn main() !void {
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer _ = gpa.deinit();

    // var allocator = gpa.allocator();

    // const json = try jsonComposerGPA(@TypeOf(x), &allocator, x);
    // defer allocator.free(json);
    // std.debug.print("{s}", .{json});

    const val = try jsonComposerFBA(x);
    std.debug.print("{s}", .{val});

    // const parsed = try jsonParserFBA(Place,
    //     \\{ "lat": 40.684540, "long": -74.401422 }
    // );

    // std.debug.print("{any}", .{parsed.lat});
    // std.debug.print("{any}", .{parsed.long});

    // const parsed = try jsonParserGPA(Place, &allocator,
    //     \\{ "lat": 40.684540, "long": -74.401422 }
    // );

    // std.debug.print("{any}", .{parsed.lat});
    // std.debug.print("{any}", .{parsed.long});
}

/// Composes a JSON string from a value of type `T`.
///
/// This function serializes the provided value of type `T` into a JSON string, using a fixed buffer allocator for memory management.
/// The result is a byte slice representing the serialized JSON string.
///
/// The function guarantees that the memory allocated for the string is appropriately freed once it goes out of scope.
///
/// - `T`: The type to serialize into JSON. This can be any type that is supported by `std.json.stringify`.
///
/// Returns an error if the serialization fails.
pub fn jsonComposerFBA(T: anytype) ![]const u8 {
    // Usage
    // const val = try jsonComposerFBA(x);
    // std.debug.print("{s}", .{val});

    var buf: [100]u8 = undefined;
    var fba: std.heap.FixedBufferAllocator = std.heap.FixedBufferAllocator.init(&buf);
    var string = std.ArrayList(u8).init(fba.allocator());
    // defer string.deinit();
    try std.json.stringify(T, .{}, string.writer());

    return string.items;
}

/// Serialize a value of type `T` into a JSON string.
/// The caller is responsible for freeing the returned slice using the provided allocator.
///
/// - T: Any serializable type
/// - allocator: Allocator used for memory management
/// - value: The value to be serialized
pub fn jsonComposerGPA(comptime T: anytype, allocator: *std.mem.Allocator, value: T) ![]const u8 {
    // Usage
    //
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer _ = gpa.deinit();
    //
    // var allocator = gpa.allocator();
    //
    // const json = try jsonComposerGPA(@TypeOf(x), &allocator, x);
    // defer allocator.free(json);
    // std.debug.print("{s}", .{json});

    var string = std.ArrayList(u8).init(allocator.*);
    defer string.deinit();
    try std.json.stringify(value, .{}, string.writer());
    string.shrinkRetainingCapacity(string.items.len);

    return string.toOwnedSlice();
}

/// Parses a JSON string into a value of type `T`.
///
/// This function ensures that memory is managed correctly using the allocator,
/// and that the provided JSON string is parsed into the appropriate type `T`.
/// The allocator's memory is freed when the parsed result goes out of scope.
///
/// - `T`: The type to parse the JSON string into. This type must be supported by `std.json`.
/// - `string`: The JSON input as a slice of bytes (`[]const u8`), which will be parsed.
///
/// Returns an error if the JSON parsing fails.
pub fn jsonParserFBA(T: type, string: []const u8) !T {
    // Usage
    // const parsed = try jsonParserFBA(Place,
    //     \\{ "lat": 40.684540, "long": -74.401422 }
    // );
    //
    // std.debug.print("{any}", .{parsed.lat});
    // std.debug.print("{any}", .{parsed.long});

    var buf: [100]u8 = undefined;
    var fba: std.heap.FixedBufferAllocator = std.heap.FixedBufferAllocator.init(&buf);

    const parsed = try std.json.parseFromSlice(
        T,
        fba.allocator(),
        string,
        .{},
    );
    defer parsed.deinit();

    return parsed.value;
}

/// Parses a JSON string into a value of type `T`.
/// The caller is responsible for ensuring the allocator's memory is appropriately managed.
///
/// - T: The type to parse the JSON string into.
/// - allocator: Allocator for dynamic memory management.
/// - string: The JSON input as a byte slice.
pub fn jsonParserGPA(comptime T: anytype, allocator: *std.mem.Allocator, string: []const u8) !T {
    // Usage
    //
    // const parsed = try jsonParserGPA(Place, &allocator,
    //     \\{ "lat": 40.684540, "long": -74.401422 }
    // );

    // std.debug.print("{any}", .{parsed.lat});
    // std.debug.print("{any}", .{parsed.long});

    const parsed = try std.json.parseFromSlice(T, allocator.*, string, .{});
    defer parsed.deinit(); // Ensure cleanup of parsed resources

    return parsed.value; // Return the parsed value
}
