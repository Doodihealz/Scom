UnitTemplate = Import("scom/units/usl3801/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usl3801", "SCOM unit identity mismatch: usl3801")
