UnitTemplate = Import("scom/units/uel1501/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uel1501", "SCOM unit identity mismatch: uel1501")
