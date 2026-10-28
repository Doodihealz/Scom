UnitTemplate = Import("scom/units/ues5064/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5064", "SCOM unit identity mismatch: ues5064")
