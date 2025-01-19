const reg = @import("reg");
const data = reg.data;
const math = reg.math;
const risk = math.risk;
const weapon = data.weapon;
const ammunition = data.ammunition;
const validation = data.validation;

const RiskProfile = @This();

const Sort = enum {
    Box,
    SST,
    Halva,
};
const Factor = enum {
    I,
    II,
    III,
};
const Target = enum {
    Fast,
    Flyttbart,
};
const Config = struct {
    show: bool = true,
    valid: bool = false,
    sort: Sort = .Halva,
    showText: bool = false,
};
const TerrainValues = struct {
    interceptingForest: bool = false,
    factor: Factor = .I,
    Amin: f32 = 100,
    Amax: f32 = 200,
    f: f32 = 50,
    forestDist: f32 = 300,
    l: f32 = 0,
    h: f32 = 0,
    q1: f32 = 0,
    q2: f32 = 0,
    ch: f32 = 1000,
};
const WeaponValues = struct {
    weapon_enum_value: weapon.Models = .P88,
    target: Target = .Fast,
    model: weapon.Model = .EHV,
    caliber: ammunition.Caliber = .ptr9_sk_39b,
    v: f32 = 0,
    amm556: ammunition.Calibers.ptr556 = .ptr556_sk_prj_slprj,
    amm762: ammunition.Calibers.ptr762 = .ptr762_sk_10_pprj,
    amm9: ammunition.Calibers.ptr9 = .ptr9_sk_39b,
    amm127: ammunition.Calibers.ptr127 = .ptr127_sk_45_nprj_slnprj,
    support: bool = false,
    c: f32 = 0,
};
const Box = struct {
    length: f32 = 100,
    width: f32 = 50,
    h: f32 = 300,
    v: f32 = 300,
};
const SST = struct {
    width: f32 = 50,
    hh: f32 = 100,
    hv: f32 = 100,
    vv: f32 = 100,
    vh: f32 = 100,
};

terrainValues: TerrainValues,
weaponValues: WeaponValues,
config: Config,
box: Box,
sst: SST,

pub fn init() RiskProfile {
    return RiskProfile{
        .terrainValues = TerrainValues{},
        .weaponValues = WeaponValues{},
        .config = Config{},
        .box = Box{},
        .sst = SST{},
    };
}

pub fn getHasSupport(self: *RiskProfile) bool {
    return weapon.getWeaponModel(self.weaponValues.weapon_enum_value, false).supportable;
}

pub fn reset(self: *RiskProfile) void {
    self.terrainValues = TerrainValues{};
    self.weaponValues = WeaponValues{};
    self.config = Config{};
    self.box = Box{};
    self.sst = SST{};
}

pub fn update(self: *RiskProfile) void {
    self.terrainValues.l = risk.calculateL(self.*);
    self.terrainValues.h = risk.calculateH(self.*);
    self.terrainValues.q1 = risk.calculateQ1(self.*);
    self.terrainValues.q2 = risk.calculateQ2(self.*);
    self.weaponValues.c = risk.calculateC(self.*);
    self.weaponValues.model = weapon.getWeaponModel(self.weaponValues.weapon_enum_value, self.weaponValues.support);
    self.weaponValues.v = if (self.weaponValues.target == .Fast) self.weaponValues.model.v_still else self.weaponValues.model.v_moveable;

    //TODO fixa alla vapen
    switch (self.weaponValues.weapon_enum_value) {
        .AK5, .KSP90 => self.weaponValues.caliber = ammunition.getCaliber(self.weaponValues.amm556),
        .KSP58 => self.weaponValues.caliber = ammunition.getCaliber(self.weaponValues.amm762),
        .KSP88, .AG90 => self.weaponValues.caliber = ammunition.getCaliber(self.weaponValues.amm127),
        .P88 => self.weaponValues.caliber = ammunition.getCaliber(self.weaponValues.amm9),
    }

    self.config.valid = validation.validate(self);
}

pub fn save(self: *RiskProfile) !void {
    try reg.io.sync.save(self.state);
}

pub fn load(self: *RiskProfile) !void {
    try reg.io.sync.load(self.state);
}
