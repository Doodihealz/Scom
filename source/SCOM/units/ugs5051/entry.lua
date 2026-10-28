UnitTemplate = Import("scom/units/ugs5051/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5051", "SCOM unit identity mismatch: ugs5051")
