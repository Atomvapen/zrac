const rl = @import("raylib");

pub const RiskLine = struct {
    startX: i32,
    startY: i32,
    endX: i32,
    endY: i32,
    angle: f32,

    pub fn getStartVector(self: *RiskLine) rl.Vector2 {
        return rl.Vector2{
            .x = @floatFromInt(self.startX),
            .y = @floatFromInt(self.startY),
        };
    }

    pub fn getEndVector(self: *RiskLine) rl.Vector2 {
        return rl.Vector2{
            .x = @floatFromInt(self.endX),
            .y = @floatFromInt(self.endY),
        };
    }

    pub fn drawCircleSector(self: *RiskLine, radius: f32) void {
        rl.drawCircleSectorLines(.{ .x = @floatFromInt(self.startX), .y = @floatFromInt(self.startY) }, radius, -90, -90 + milsToDegree(self.angle), 50, rl.Color.maroon);
    }

    pub fn drawText(self: *RiskLine, text: [*:0]const u8, textOffsetX: i32, textOffsetY: i32, fontSize: i32) void {
        rl.drawText(text, self.endX + textOffsetX, self.endY + textOffsetY, fontSize, rl.Color.black);
    }

    pub fn drawLine(self: *RiskLine) void {
        rl.drawLine(self.startX, self.startY, self.endX, self.endY, rl.Color.maroon);
    }

    pub fn calculateXfromAngle(self: *RiskLine, width: i32, angle: f32) i32 {
        // https://www.omnicalculator.com/math/right-triangle-side-angle
        //
        // Given an angle and one leg
        // Find the missing leg using trigonometric functions
        //
        // a = b × tan(α)

        _ = self;
        const b: f32 = @as(f32, @floatFromInt(width));
        const a: f32 = @tan(milsToRadians(angle));

        return @intFromFloat(b * a);
    }

    pub fn rotateEndPoint(self: *RiskLine) void {
        // https://danceswithcode.net/engineeringnotes/rotations_in_2d/rotations_in_2d.html
        //
        // Rotating Points around an Arbitrary Center
        //
        // (x, y) = Point to be rotated
        // (ox, oy) = Coordinates of center of rotation
        // θ = Angle of rotation (positive counterclockwise) in radians
        // (x1, y1) = Coordinates of point after rotation
        //
        // rotated_x = (x – ox) * cos(θ) – (y – oy)* sin(θ) + ox
        // rotated_y = (x – ox) * sin(θ) + (y – oy)* cos(θ) + oy

        const localEndX: i32 = @intFromFloat((@as(f32, @floatFromInt(self.endX - self.startX)) * @cos(milsToRadians(self.angle)) - (@as(f32, @floatFromInt(self.endY - self.startY))) * @sin(milsToRadians(self.angle))) + @as(f32, @floatFromInt(self.startX)));
        const localEndY: i32 = @intFromFloat((@as(f32, @floatFromInt(self.endX - self.startX)) * @sin(milsToRadians(self.angle)) + (@as(f32, @floatFromInt(self.endY - self.startY))) * @cos(milsToRadians(self.angle))) + @as(f32, @floatFromInt(self.startY)));

        self.*.endX = localEndX;
        self.*.endY = localEndY;
    }

    pub fn milsToDegree(mils: f32) f32 {
        return mils * 0.05625;
    }

    pub fn milsToRadians(mils: f32) f32 {
        return mils * 0.000982;
    }
};
