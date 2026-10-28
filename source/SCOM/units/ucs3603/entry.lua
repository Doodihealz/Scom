UnitTemplate = Import("scom/units/ucs3603/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs3603", "SCOM unit identity mismatch: ucs3603")
