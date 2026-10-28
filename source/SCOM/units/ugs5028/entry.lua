UnitTemplate = Import("scom/units/ugs5028/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5028", "SCOM unit identity mismatch: ugs5028")
