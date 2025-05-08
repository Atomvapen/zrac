/// Calculates the length of one leg of a right triangle given the other leg and an angle.
///
/// ### Paramaters
/// - `angle` Angle θ (where 0<θ<90∘) in rad
/// - `length` Length of the adjacent leg a
pub fn triangleOppositeLeg(length: f32, angle: f32) f32 {
    return length * @tan(angle);
}
