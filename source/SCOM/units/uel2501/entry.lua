UnitTemplate = Import("scom/units/uel2501/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uel2501", "SCOM unit identity mismatch: uel2501")
