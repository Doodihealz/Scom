UnitTemplate = Import("scom/units/ugs5030/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5030", "SCOM unit identity mismatch: ugs5030")
