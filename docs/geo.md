# Shape Structures Documentation

This documentation describes the implementation and functionality of three geometric structures: `Point`, `Semicircle`, and `Line`. These structures are part of a system designed for mathematical and graphical operations.

## Shape Union

The `Shape` union allows a `Point`, `Semicircle`, or `Line` to be represented within a single type:
```zig
pub const Shape = union(enum) {
    Point: Point,
    Semicircle: Semicircle,
    Line: Line,
};
```

---

## Point
The `Point` structure represents a 2D point with an optional text label.

### Fields:
- `pos`: Position of the point (`rl.Vector2`).
- `text`: Optional text properties including visibility, content, and formatting.

### Methods:
#### `init(pos: rl.Vector2) Point`
Creates a `Point` with the given position.

#### `getLength(self: *Point) f32`
Calculates the distance of the point from the origin (0, 0).

#### `add(self: *Point, b: Point) void`
Adds another point's position to this point.

#### `sub(self: *Point, b: Point) void`
Subtracts another point's position from this point.

#### `scale(self: *Point, factor: f32) void`
Scales the point's position by a given factor.

#### `multiply(self: *Point, b: Point) void`
Multiplies the position of the point by another point's position.

#### `addText(self: *Point, text: [*:0]const u8, textOffsetX: i32, textOffsetY: i32, fontSize: i32, color: rl.Color, show: bool) void`
Adds text properties to the point.

#### `rotate(self: *Point, point: rl.Vector2, angle: f32) void`
Rotates the point around another point by a specified angle in mils.

---

## Semicircle
The `Semicircle` structure represents a semicircle with properties for drawing and optional text.

### Fields:
- `color`: The color of the semicircle.
- `startAngle`, `endAngle`: Angles defining the arc.
- `radius`: Radius of the semicircle.
- `center`: Center position of the semicircle.
- `segments`: Number of segments to approximate the arc.
- `drawCommand`: Command for rendering the semicircle.
- `text`: Optional text properties.

### Methods:
#### `init(color: rl.Color, startAngle: f32, endAngle: f32, radius: f32, center: rl.Vector2, segments: i32) Semicircle`
Creates a semicircle with the given parameters.

#### `addText(self: *Semicircle, text: [*:0]const u8, textOffsetX: i32, textOffsetY: i32, fontSize: i32, color: rl.Color, pos: rl.Vector2, show: bool) void`
Adds text properties to the semicircle.

#### `createDrawCommand(self: *Semicircle) void`
Generates a draw command for rendering the semicircle.

#### `scale(self: *Semicircle, factor: f32) void`
Scales the semicircle by a factor.

#### `add(self: *Semicircle, semicircle: Semicircle) void`
Adds the properties of another semicircle to this one.

---

## Line
The `Line` structure represents a line segment with optional text and drawing capabilities.

### Fields:
- `start`, `end`: Start and end points of the line.
- `text`: Optional text properties.
- `textCommand`, `drawCommand`: Commands for text and graphical rendering.

### Methods:
#### `init(start: rl.Vector2, end: rl.Vector2) Line`
Creates a line with the given start and end points.

#### `addText(self: *Line, text: [*:0]const u8, textOffsetX: i32, textOffsetY: i32, fontSize: i32, color: rl.Color, pos: rl.Vector2, show: bool) void`
Adds text properties to the line.

#### `createTextCommand(self: *Line, text: [*:0]const u8, textOffsetX: i32, textOffsetY: i32, fontSize: i32, color: rl.Color, pos: rl.Vector2) void`
Generates a text command for rendering.

#### `createDrawCommand(self: *Line) void`
Generates a draw command for rendering the line.

#### `getLength(self: *Line) f32`
Calculates the length of the line segment.

#### `getEndLength(self: *Line) f32`
Calculates the distance from the origin to the endpoint.

#### `getStartLength(self: *Line) f32`
Calculates the distance from the origin to the start point.

#### `add(self: *Line, b: Line) void`
Adds another line's properties to this line.

#### `sub(self: *Line, b: Line) void`
Subtracts another line's properties from this line.

#### `scale(self: *Line, factor: f32) void`
Scales the line by a factor.

#### `multiply(self: *Line, b: Line) void`
Multiplies this line's start and end points by another line's points.

#### `rotate(self: *Line, direction: enum { End, Start }, angle: f32) void`
Rotates one endpoint of the line around the other by a specified angle in mils.

#### `getIntersectionPoint(self: *Line, line: Line) ?rl.Vector2`
Calculates the intersection point of this line with another line, if it exists.

#### `getParallelLine(self: *Line, offset: f32) !Line`
Calculates a parallel line at a specified offset distance.

---

This documentation provides an overview of the functionality and methods available for manipulating points, semicircles, and lines in 2D space.
