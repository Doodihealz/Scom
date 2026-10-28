UnitTemplate = Import("scom/units/ucs2802/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs2802", "SCOM unit identity mismatch: ucs2802")
