pub const Vec2i = @Vector(2, i32);
pub const Vec3i = @Vector(3, i32);
pub const Vec4i = @Vector(4, i32);

pub const Vec2f = @Vector(2, f32);
pub const Vec3f = @Vector(3, f32);
pub const Vec4f = @Vector(4, f32);

// ------------------------------------------------------------------------------
// Generic vector functions
// ------------------------------------------------------------------------------

pub inline fn dimensions(v: anytype) comptime_int {
    const info = @typeInfo(@TypeOf(v));
    if (info != .vector) @compileError("any() can only be used on vectors.");
    return @typeInfo(@TypeOf(v)).vector.len;
}

pub inline fn Element(v: anytype) type {
    const info = @typeInfo(@TypeOf(v));
    if (info != .vector) @compileError("any() can only be used on vectors.");
    return @typeInfo(@TypeOf(v)).vector.child;
}

pub inline fn normalize(v: anytype) @TypeOf(v) {
    return v / @as(@TypeOf(v), @splat(length(v)));
}

pub inline fn length(v: anytype) @typeInfo(@TypeOf(v)).vector.child {
    return @sqrt(@reduce(.Add, v * v));
}

pub inline fn lengthSq(v: anytype) @typeInfo(@TypeOf(v)).vector.child {
    return @reduce(.Add, v * v);
}

pub inline fn distance(a: anytype, b: @TypeOf(a)) @typeInfo(@TypeOf(a)).vector.child {
    return length(a - b);
}

pub inline fn distanceSquared(a: anytype, b: @TypeOf(a)) @typeInfo(@TypeOf(a)).vector.child {
    return lengthSq(a - b);
}

pub inline fn reflect(v: anytype, n: @TypeOf(v)) @TypeOf(v) {
    return v - (n * (2 * dot(v * n)));
}

pub inline fn scale(v: anytype, scalar: @typeInfo(@TypeOf(v)).vector.child) @TypeOf(v) {
    return v * @as(@TypeOf(v), @splat(scalar));
}

pub inline fn descale(v: anytype, scalar: @typeInfo(@TypeOf(v)).vector.child) @TypeOf(v) {
    return v / @as(@TypeOf(v), @splat(scalar));
}

pub inline fn invert(v: anytype) @TypeOf(v) {
    return v * @as(@TypeOf(v), @splat(-1));
}

pub inline fn negate(v: anytype) @TypeOf(v) {
    return -v;
}

pub inline fn max(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    return @max(a, b);
}

pub inline fn sqrt(a: anytype) @TypeOf(a) {
    return @sqrt(a);
}

pub inline fn min(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    return @min(a, b);
}

pub inline fn add(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    return a + b;
}

pub inline fn abs(v: anytype) @TypeOf(v) {
    return @abs(v);
}

pub inline fn sub(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    return a - b;
}

pub inline fn mul(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    return a * b;
}

pub inline fn div(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    return a / b;
}

pub inline fn mod(v: anytype, scalar: @typeInfo(@TypeOf(v)).vector.child) @TypeOf(v) {
    return @mod(v, @as(@TypeOf(v), @splat(scalar)));
}

pub inline fn dot(a: anytype, b: @TypeOf(a)) @typeInfo(@TypeOf(a)).vector.child {
    return @reduce(.Add, a * b);
}

/// Returns `true` if **any** element in the boolean vector `v` is `true`.
///
/// Only works with `@Vector(N, bool)` types. If the vector contains any `true`
/// values, the function returns `true`; otherwise, it returns `false`.
pub fn any(v: anytype) bool {
    const info = @typeInfo(@TypeOf(v));
    if (info != .vector) @compileError("any() can only be used on vectors.");
    if (info.vector.child != bool) @compileError("any() only works on vectors of bool.");
    const ab: [info.vector.len]bool = v;
    var result = false;
    inline for (ab) |b| result = result or b;
    return result;
}

/// Returns `true` if **all** elements in the boolean vector `v` are `true`.
///
/// Only works with `@Vector(N, bool)` types. If every element in the vector is
/// `true`, the function returns `true`; otherwise, it returns `false`.
pub fn all(v: anytype) bool {
    const info = @typeInfo(@TypeOf(v));
    if (info != .vector) @compileError("all() can only be used on vectors.");
    if (info.vector.child != bool) @compileError("all() only works on vectors of bool.");
    const ab: [info.vector.len]bool = v;
    var result = true;
    inline for (ab) |b| result = result and b;
    return result;
}

/// Returns a boolean vector where each element is `true` if the corresponding
/// value in `v` is `NaN` (Not a Number).
///
/// This uses the fact that `NaN != NaN` is always true in IEEE 754.
pub inline fn isNan(v: anytype) @Vector(@typeInfo(@TypeOf(v)).vector.len, bool) {
    const info = @typeInfo(@TypeOf(v));
    if (info != .vector) @compileError("isNan() can only be used on vectors.");
    return v != v;
}

/// Returns a boolean vector where each element is `true` if the corresponding
/// value in `v` is finite (i.e., not `NaN` or infinite).
///
/// Works with floating-point vectors like `@Vector(N, f32)` or `@Vector(N, f64)`.
pub inline fn isFinite(v: anytype) @Vector(@typeInfo(@TypeOf(v)).vector.len, bool) {
    const info = @typeInfo(@TypeOf(v));
    if (info != .vector) @compileError("isFinite() can only be used on vectors.");
    if (info.vector.child != .float) @compileError("isFinite() can only be used on float vectors.");
    return v - v == @as(@TypeOf(v), @splat(0));
}

/// Returns a boolean vector where each element is `true` if the corresponding
/// value in `v` is infinite (i.e., either positive or negative infinity).
///
/// Works with floating-point vectors like `@Vector(N, f32)` or `@Vector(N, f64)`.
pub inline fn isInfinity(v: anytype) @Vector(@typeInfo(@TypeOf(v)).vector.len, bool) {
    const info = @typeInfo(@TypeOf(v));
    if (info != .vector) @compileError("isInfinity() can only be used on vectors.");
    if (info.vector.child != .float) @compileError("isInfinity() can only be used on float vectors.");
    return v - v == v;
}

/// Returns a boolean vector indicating whether each element of `v`
/// is within the range [-bounds, bounds].
///
/// This function assumes symmetric bounds, meaning it checks if
/// each element of `v` is between `-bounds` and `+bounds`.
pub inline fn isInBounds(v: anytype, bounds: @TypeOf(v)) @Vector(@typeInfo(@TypeOf(v)).vector.len, bool) {
    const info = @typeInfo(@TypeOf(v));
    if (info != .vector) @compileError("isInBounds() can only be used on vectors.");
    const b0 = v <= bounds;
    const b1 = (bounds * @as(@TypeOf(v), @splat(-1.0))) <= v;
    const b0u: @Vector(info.vector.len, u1) = @bitCast(b0);
    const b1u: @Vector(info.vector.len, u1) = @bitCast(b1);
    return @bitCast(b0u & b1u);
}

/// Returns a boolean vector where each element is `true` if the corresponding
/// element in `v` is between `min` and `max`, inclusive.
///
/// Useful for checking if a vector is element-wise within a non-symmetric range.
///
/// Works with floating-point vectors of the same type and length.
pub inline fn isInBoundsRange(v: anytype, min_v: @TypeOf(v), max_v: @TypeOf(v)) @Vector(@typeInfo(@TypeOf(v)).vector.len, bool) {
    const info = @typeInfo(@TypeOf(v));
    if (info != .vector) @compileError("isInBoundsRange() can only be used on vectors.");
    const ge = v >= min_v;
    const le = v <= max_v;
    const Tu = @Vector(info.vector.len, u1);
    return @bitCast(@as(Tu, @bitCast(ge)) & @as(Tu, @bitCast(le)));
}

/// Rounds a scalar or floating-point vector value according to the specified rounding mode.
///
/// Only works for numerical vector types.
///
/// Rounding modes:
///   - `.nearest`: Round to the nearest integer (ties to even).
///   - `.floor`: Round down (toward -∞).
///   - `.ceil`: Round up (toward +∞).
///   - `.trunc`: Round toward zero.
pub inline fn round(v: anytype, mode: enum { nearest, floor, ceil, trunc }) @TypeOf(v) {
    const info = @typeInfo(@TypeOf(v));
    if (info != .vector) @compileError("round() can only be used on vectors.");
    if (@typeInfo(info.vector.child) != .Float) @compileError("round() only supports vectors of floats.");
    return switch (mode) {
        .nearest => @round(v),
        .floor => @floor(v),
        .ceil => @ceil(v),
        .trunc => @trunc(v),
    };
}

/// Produces a new vector from the first `n` elements of the input vector.
///
/// Out-of-bounds element indexes of `n` result in compile errors.
pub fn slice(v: anytype, comptime n: usize) @Vector(n, @typeInfo(@TypeOf(v)).vector.child) {
    const info = @typeInfo(@TypeOf(v));
    if (info != .vector) @compileError("slice() can only be used on vectors.");
    if (info.vector.len < n) @compileError("Amount cannot be greater than vector length.");
    var result: @Vector(n, @typeInfo(@TypeOf(v)).vector.child) = undefined;
    inline for (0..n) |i| result[i] = v[i];
    return result;
}

pub fn rotate2D(v: anytype, angle: f32) @TypeOf(v) {
    const info = @typeInfo(@TypeOf(v));
    if (info != .vector) @compileError("rotate2D() can only be used on vectors.");
    if (info.vector.len == 3) @compileError("Vector must have 2 elements.");

    const cosTheta = @cos(angle);
    const sinTheta = @sin(angle);

    return .{
        v[0] * cosTheta - v[1] * sinTheta, // x′ = x * cos(θ) − y * sin(θ)
        v[0] * sinTheta + v[1] * cosTheta, // y' = x * sin(θ) + y * cos(θ)
    };
}

/// Returns the `.x` component of a vector.
///
/// Supports any vector with at least 1 component.
pub fn x(v: anytype) @typeInfo(@TypeOf(v)).vector.child {
    const info = @typeInfo(@TypeOf(v));
    if (info != .vector) @compileError("x() can only be used on vectors.");
    if (info.vector.len < 1) @compileError("Vector must have at least 1 element.");
    return v[0];
}

/// Returns the `.y` component of a vector.
///
/// Supports any vector with at least 2 components.
pub fn y(v: anytype) @typeInfo(@TypeOf(v)).vector.child {
    const info = @typeInfo(@TypeOf(v));
    if (info != .vector) @compileError("y() can only be used on vectors.");
    if (info.vector.len < 2) @compileError("Vector must have at least 2 element.");
    return v[1];
}

/// Returns the `.z` component of a vector.
///
/// Supports any vector with at least 3 components.
pub fn z(v: anytype) @typeInfo(@TypeOf(v)).vector.child {
    const info = @typeInfo(@TypeOf(v));
    if (info != .vector) @compileError("z() can only be used on vectors.");
    if (info.vector.len < 3) @compileError("Vector must have at least 3 element.");
    return v[2];
}

/// Returns the `.w` component of a vector.
///
/// Supports any vector with at least 4 components.
pub fn w(v: anytype) @typeInfo(@TypeOf(v)).vector.child {
    const info = @typeInfo(@TypeOf(v));
    if (info != .vector) @compileError("w() can only be used on vectors.");
    if (info.vector.len < 4) @compileError("Vector must have at least 4 element.");
    return v[3];
}

/// Returns a new vector containing the `.x` and `.y` components of the input.
///
/// Works with any vector that has at least 2 components.
pub fn xy(v: anytype) @Vector(2, @typeInfo(@TypeOf(v)).vector.child) {
    const info = @typeInfo(@TypeOf(v));
    if (info != .vector) @compileError("xy() can only be used on vectors.");
    if (info.vector.len < 2) @compileError("Vector must have at least 2 elements.");
    return @shuffle(info.vector.child, v, undefined, [_]i32{ 0, 1 });
}

/// Returns a new vector containing the `.x`, `.y`, and `.z` components of the input.
///
/// Works with any vector that has at least 3 components.
pub fn xyz(v: anytype) @Vector(3, @typeInfo(@TypeOf(v)).vector.child) {
    const info = @typeInfo(@TypeOf(v));
    if (info != .vector) @compileError("xyz() can only be used on vectors.");
    if (info.vector.len < 3) @compileError("Vector must have at least 3 elements.");
    return @shuffle(@typeInfo(@TypeOf(v)).vector.child, v, undefined, [_]i32{ 0, 1, 2 });
}

/// Returns a new vector containing the `.x`, `.y`, `.z`, and `.w` components of the input.
///
/// Works with any vector that has at least 4 components.
pub fn xyzw(v: anytype) @Vector(4, @typeInfo(@TypeOf(v)).vector.child) {
    const info = @typeInfo(@TypeOf(v));
    if (info != .vector) @compileError("xyzw() can only be used on vectors.");
    if (info.vector.len < 4) @compileError("Vector must have at least 4 elements.");
    return @shuffle(info.vector.child, v, undefined, [_]i32{ 0, 1, 2, 3 });
}

/// Reorders the components of a vector based on a given mask.
///
/// The mask is an array of indices that specifies how to reorder the vector components.
pub fn shuffle(v: anytype, mask: []i32) @Vector(mask.len, @typeInfo(@TypeOf(v)).vector.child) {
    const info = @typeInfo(@TypeOf(v));
    if (info != .vector) @compileError("shuffle() can only be used on vectors.");
    if (info.vector.len < mask.len) @compileError("Mask length cannot exceed vector length.");
    return @shuffle(info.vector.child, v, undefined, mask);
}

/// Returns true if all components of `a` and `b` are equal.
pub fn equal(a: anytype, b: @TypeOf(a)) bool {
    const info = @typeInfo(@TypeOf(a));
    if (info != .vector) @compileError("equal() can only be used on vectors.");
    return @reduce(.And, a == b);
}

/// Clamps each component of vector `v` between the scalar values `min_v` and `max_v`.
///
/// The same scalar `min_v` and `max_v` are applied to all components of `v`.
pub fn clampComponents(v: anytype, min_v: f32, max_v: f32) @TypeOf(v) {
    const info = @typeInfo(@TypeOf(v));
    if (info != .vector) @compileError("clampComponents() can only be used on vectors.");
    var result: @TypeOf(v) = undefined;
    for (0..info.vector.len) |i| result[i] = @max(min_v, @min(v[i], max_v));
    return result;
}

/// Clamps each component of vector `v` between the corresponding components
/// of vectors `min_v` and `max_v`.
pub fn clamp(v: anytype, min_v: @TypeOf(v), max_v: @TypeOf(v)) @TypeOf(v) {
    const info = @typeInfo(@TypeOf(v));
    if (info != .vector) @compileError("clamp() can only be used on vectors.");
    return @max(min_v, @min(v, max_v));
}

/// Moves vector `start` towards vector `end` by a maximum distance of `step`.
pub fn moveTowards(start: anytype, end: @TypeOf(start), step: @typeInfo(@TypeOf(start)).vector.child) @TypeOf(start) {
    const info = @typeInfo(@TypeOf(start));
    if (info != .vector) @compileError("moveTowards() can only be used on vectors.");
    const direction = end - start;
    const distanceSq = @reduce(.Add, direction * direction);
    const stepSq = step * step;

    if (distanceSq <= stepSq) return end;

    const len = @sqrt(distanceSq);
    const stepVec = @as(@TypeOf(start), @splat(step / len));
    return start + direction * stepVec;
}

/// Linearly interpolates between `start` and `end` by the factor `t`.
/// `t` should be in the range `0..1`.
pub fn lerp(start: anytype, end: @TypeOf(start), t: @typeInfo(@TypeOf(start)).vector.child) @TypeOf(start) {
    const info = @typeInfo(@TypeOf(start));
    if (info != .vector) @compileError("lerp() can only be used on vectors.");
    return start + (end - start) * t;
}

// ------------------------------------------------------------------------------
// 3D vector functions
// ------------------------------------------------------------------------------

/// Computes the cross product of two 3D vectors.
///
/// The result is a vector that is perpendicular to both `a` and `b`.
/// Only 3D vectors are supported.
pub fn cross(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    const info = @typeInfo(@TypeOf(a));
    if (info != .vector) @compileError("crossProduct() can only be used on vectors.");
    if (info.vector.len != 3) @compileError("crossProduct only supports 3D vectors.");
    return @Vector(3, info.vector.child){
        a[1] * b[2] - a[2] * b[1], // x = (ay * bz - az * by)
        a[2] * b[0] - a[0] * b[2], // y = (az * bx - ax * bz)
        a[0] * b[1] - a[1] * b[0], // z = (ax * by - ay * bx)
    };
}
