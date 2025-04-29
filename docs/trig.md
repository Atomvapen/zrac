## Documentation for Angle Calculations

### AngleUnit
An enumeration to represent different units of angle measurement.

```zig
pub const AngleUnit = enum {
    Mils,       // Angle measurement in milliradians
    Degrees,    // Angle measurement in degrees
    Radians,    // Angle measurement in radians
};
```

---

### `triangleOppositeLeg`
Calculates the length of one leg of a right triangle given the other leg and an angle.

#### Parameters
- `length` (`f32`): Length of the adjacent leg (a).
- `angle` (`f32`): Angle \( \theta \) (where \( 0 < \theta < 90^\circ \)) in milliradians.

#### Returns
- (`f32`): The length of the opposite leg (b).

#### Formula
\[
b = a \cdot \tan(\theta)
\]

#### Example
```zig
const length: f32 = 10.0;
const angle: f32 = 1600.0; // in mils
const oppositeLeg: f32 = triangleOppositeLeg(length, angle);
```

#### Implementation
```zig
pub fn triangleOppositeLeg(length: f32, angle: f32) f32 {
    return length * @tan(convertAngle(angle, .Mils, .Radians));
}
```

---

### `convertAngle`
Converts an angle measurement from one unit to another.

#### Parameters
- `value` (`f32`): The angle value to convert.
- `from` (`AngleUnit`): The unit of the input angle. Must be one of:
  - `.Mils`: Milliradians
  - `.Degrees`: Degrees
  - `.Radians`: Radians
- `to` (`AngleUnit`): The desired unit for the output angle. Must also be one of the options in `AngleUnit`.

#### Returns
- (`f32`): The converted angle value.

#### Conversion Constants
- `MILS_TO_DEGREES` = 0.05625
- `DEGREES_TO_RADIANS` = \( \pi / 180 \)

#### Example
```zig
const angleInMils: f32 = 1600.0;
const angleInRadians: f32 = convertAngle(angleInMils, .Mils, .Radians);
```

#### Implementation
```zig
pub fn convertAngle(value: f32, from: AngleUnit, to: AngleUnit) f32 {
    const MILS_TO_DEGREES: f32 = 0.05625;
    const DEGREES_TO_RADIANS: f32 = std.math.pi / 180.0;

    if (from == to) return value;

    const intermediateDegrees: f32 = switch (from) {
        .Mils => value * MILS_TO_DEGREES,
        .Degrees => value,
        .Radians => value / DEGREES_TO_RADIANS,
    };

    return switch (to) {
        .Mils => intermediateDegrees / MILS_TO_DEGREES,
        .Degrees => intermediateDegrees,
        .Radians => intermediateDegrees * DEGREES_TO_RADIANS,
    };
}
```

---

This documentation provides an overview of the functionality and methods available for manipulating angles in 2D space.
