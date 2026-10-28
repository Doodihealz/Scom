UnitTemplate = Import("scom/units/ues5001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5001", "SCOM unit identity mismatch: ues5001")
