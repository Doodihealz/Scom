UnitTemplate = Import("scom/units/ugs5049/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5049", "SCOM unit identity mismatch: ugs5049")
