UnitTemplate = Import("scom/units/uss3501/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss3501", "SCOM unit identity mismatch: uss3501")
