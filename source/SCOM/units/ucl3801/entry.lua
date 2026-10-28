UnitTemplate = Import("scom/units/ucl3801/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucl3801", "SCOM unit identity mismatch: ucl3801")
