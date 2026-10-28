UnitTemplate = Import("scom/units/uel3501/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uel3501", "SCOM unit identity mismatch: uel3501")
