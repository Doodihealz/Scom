UnitTemplate = Import("scom/units/ucs2801/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs2801", "SCOM unit identity mismatch: ucs2801")
