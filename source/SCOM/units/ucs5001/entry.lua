UnitTemplate = Import("scom/units/ucs5001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs5001", "SCOM unit identity mismatch: ucs5001")
