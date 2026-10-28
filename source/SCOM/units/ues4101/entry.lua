UnitTemplate = Import("scom/units/ues4101/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues4101", "SCOM unit identity mismatch: ues4101")
