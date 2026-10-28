UnitTemplate = Import("scom/units/ucs1801/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs1801", "SCOM unit identity mismatch: ucs1801")
