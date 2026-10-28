UnitTemplate = Import("scom/units/uss5022/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss5022", "SCOM unit identity mismatch: uss5022")
