# Risk Profile Calculations

This module provides functions to calculate various parameters based on a given `RiskProfile`. Each calculation considers specific attributes from the `RiskProfile` structure.

---

## `calculateH`

### Description
Calculates the `H` value based on terrain attributes.

### Parameters
- `riskProfile` (`RiskProfile`): The risk profile containing terrain and weapon values.

### Returns
- (`f32`): The calculated `H` value.

### Formula
```zig
H = terrainValues.Amax + terrainValues.l
```

---

## `calculateL`

### Description
Calculates the `L` value based on terrain and weapon attributes.

### Parameters
- `riskProfile` (`RiskProfile`): The risk profile containing terrain and weapon values.

### Returns
- (`f32`): The calculated `L` value.

### Formula
```zig
L = match terrainValues.factor {
    .I => 0.8 * weaponValues.caliber.Dmax - 0.7 * terrainValues.Amax,
    .II => 0.6 * weaponValues.caliber.Dmax - 0.5 * terrainValues.Amax,
    .III => 0.4 * weaponValues.caliber.Dmax - 0.3 * terrainValues.Amax,
}
```

---

## `calculateC`

### Description
Calculates the `C` value considering forest interception and terrain factors.

### Parameters
- `riskProfile` (`RiskProfile`): The risk profile containing terrain and weapon values.

### Returns
- (`f32`): The calculated `C` value.

### Formula
```zig
C = match terrainValues.interceptingForest {
    true => weaponValues.caliber.c,
    false => match terrainValues.factor {
        .I => 0.2 * (weaponValues.caliber.Dmax - terrainValues.Amin),
        .II => 0.15 * (weaponValues.caliber.Dmax - terrainValues.Amin),
        .III => 0.08 * (weaponValues.caliber.Dmax - terrainValues.Amin),
    },
}
```

---

## `calculateQ1`

### Description
Calculates the `Q1` value based on terrain factors.

### Parameters
- `riskProfile` (`RiskProfile`): The risk profile containing terrain and weapon values.

### Returns
- (`f32`): The calculated `Q1` value.

### Formula
```zig
Q1 = match terrainValues.factor {
    .I => weaponValues.caliber.c,
    .II, .III => 400.0,
}
```

---

## `calculateQ2`

### Description
Calculates the `Q2` value based on forest distance.

### Parameters
- `riskProfile` (`RiskProfile`): The risk profile containing terrain and weapon values.

### Returns
- (`f32`): The calculated `Q2` value.

### Formula
```zig
Q2 = if (terrainValues.forestDist < 0) 0.0 else 1000.0
```

---

This documentation provides an overview of the functionality and methods available for risk calculation.
