UnitTemplate = Import("scom/units/ues1001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues1001", "SCOM unit identity mismatch: ues1001")
