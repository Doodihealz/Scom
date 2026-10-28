UnitTemplate = Import("scom/units/ues5049/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5049", "SCOM unit identity mismatch: ues5049")
