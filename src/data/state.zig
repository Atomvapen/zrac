const weapon = @import("weapon.zig");
const ammunition = @import("ammunition.zig");
// const state = @import("../gui/renderer.zig").guiState;
const math = @import("../math/risk.zig");

pub const riskProfile = struct {
    terrainValues: terrainValues2,
    weaponValues: weaponValues2,

    show: bool = true,

    pub fn init() riskProfile {
        return riskProfile{
            .terrainValues = terrainValues2{},
            .weaponValues = weaponValues2{},
        };
    }

    const factor = enum {
        I,
        II,
        III,
    };

    const targetType = enum {
        Fast,
        Flyttbart,
    };

    pub const terrainValues2 = struct {
        interceptingForest: bool = false,
        factor_enum_value: factor = .I,
        Amin: f32 = 0,
        Amax: f32 = 0,
        f: f32 = 0,
        forestDist: f32 = 0,
        l: f32 = 0,
        h: f32 = 0,
        v: f32 = 0,
    };

    pub const weaponValues2 = struct {
        weapon_enum_value: weapon.Models = .AK5,
        amm_enum_values: ammunition.Calibers = .hagelptr,
        target_enum_value: targetType = .Fast,
        model: weapon.Model = .EHV, //weapon.Model.EHV,
        caliber: ammunition.Caliber = .hagelptr, //ammunition.Caliber.ptr556_sk_prj_slpr
    };

    pub fn update(self: *riskProfile) void {
        self.terrainValues.l = math.calculateL(self);
        self.terrainValues.h = math.calculateH(self);
    }

    pub fn validate(self: *riskProfile) bool {
        _ = self;
        return true;
        //     // Check for zero values in Amax or Amin
        //     if (self.getAmax() == 0 or self.getAmin() == 0) {
        //         return false;
        //     }

        //     // Check for invalid range conditions
        //     if (self.getAmin() > self.getAmax() or self.getAmin() > self.getDmax() or self.getAmax() > self.getDmax()) {
        //         return false;
        //     }

        //     // Check for negative values
        //     if (self.getDmax() < 0 or self.getAmax() < 0 or self.getAmin() < 0 or self.getF() < 0 or self.q1 < 0 or self.c < 0 or self.l < 0 or self.h < 0) {
        //         return Rfalse;
        //     }

        //     // Check for integer overflow (example check - you can adjust based on your logic)
        //     if (self.getAmax() > std.math.floatMax(f32) or self.getAmin() > std.math.floatMax(f32) or self.getDmax() > std.math.floatMax(f32) or self.getF() > std.math.floatMax(f32)) {
        //         return false;
        //     }

        //     // If all checks pass, set the valid flag
        //     return true;
    }
};
