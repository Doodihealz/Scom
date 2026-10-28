UnitTemplate = Import("scom/units/ues2513/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues2513", "SCOM unit identity mismatch: ues2513")
