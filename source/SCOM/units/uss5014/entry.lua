UnitTemplate = Import("scom/units/uss5014/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss5014", "SCOM unit identity mismatch: uss5014")
