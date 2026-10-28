UnitTemplate = Import("scom/units/ues5022/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5022", "SCOM unit identity mismatch: ues5022")
