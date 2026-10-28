UnitTemplate = Import("scom/units/uss3402/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss3402", "SCOM unit identity mismatch: uss3402")
