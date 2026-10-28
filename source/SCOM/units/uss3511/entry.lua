UnitTemplate = Import("scom/units/uss3511/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss3511", "SCOM unit identity mismatch: uss3511")
