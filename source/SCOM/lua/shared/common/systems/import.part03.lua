-- SCOM Field Fixes cache-only projectile folders 1.0.0
-- FilesCache indexes physical directories only, so expose every template inserted by this transaction.
local SCOFieldFixPreviousScanDir = ScanDir
local SCOFieldFixGeneratedProjectileFolders = {
    "psn001",
    "psn002",
    "psn003",
    "psn004",
    "psn005",
    "psk201",
    "psm401",
    "psu404s",
    "pst001", "pst002", "pst003", "pst004", "pst005",
    "pst006", "pst007", "pst008", "pst009",
}
function ScanDir(directory)
    local folders = SCOFieldFixPreviousScanDir(directory)
    if directory ~= "common/projectiles/projectilesTemplates/" then
        return folders
    end
    local known = {}
    for _, folder in ipairs(folders) do
        known[string.lower(folder)] = true
    end
    for _, templateId in ipairs(SCOFieldFixGeneratedProjectileFolders) do
        local folder = directory .. templateId
        local folderKey = string.lower(folder)
        if not known[folderKey] then
            table.insert(folders, folder)
            known[folderKey] = true
        end
    end
    return folders
end
-- SCOM source roster cache folders 1.0.0
local previousSourceRosterScan = ScanDir
local sourceRosterFolders = {
    ['common/units/unitsTemplates/'] = { "uca5001", "ucl5001", "ucn5001", "ucs5001", "ucs5002", "ucs5003", "ucs5004", "ucs5005", "ucs5006", "ucs5007", "ucs5008", "uea5001", "uea5002", "uea5003", "uea5004", "uea5005", "uea5006", "uea5007", "uea5008", "uea5009", "uea5010", "uea5011", "uel5001", "uel5002", "uel5003", "uel5004", "uel5005", "uel5006", "uel5007", "uel5008", "uel5009", "uel5010", "uel5011", "uen5001", "uen5002", "uen5003", "ues5001", "ues5002", "ues5003", "ues5004", "ues5005", "ues5006", "ues5007", "ues5008", "ues5009", "ues5010", "ues5011", "ues5012", "ues5013", "ues5014", "ues5015", "ues5016", "ues5017", "ues5018", "ues5019", "ues5020", "ues5021", "ues5022", "ues5023", "ues5024", "ues5025", "ues5026", "ues5027", "ues5028", "ues5029", "ues5030", "ues5031", "ues5032", "ues5033", "ues5034", "ues5035", "ues5036", "ues5037", "ues5038", "ues5039", "ues5040", "ues5042", "ues5043", "ues5044", "ues5045", "ues5046", "ues5049", "ues5050", "ues5051", "ues5052", "ues5053", "ues5054", "ues5055", "ues5056", "ues5057", "ues5058", "ues5059", "ues5060", "ues5061", "ues5062", "ues5063", "ues5064", "ues5065", "ues5066", "ues5067", "ues5068", "ues5069", "ues5070", "ues5071", "ues5072", "ues5073", "ues5074", "ues5075", "ues5076", "ues5077", "ues5078", "ues5079", "ues5080", "ues5082", "ues5085", "ues5086", "ues5087", "ues5088", "ues5090", "ues5093", "ues5094", "uga5001", "uga5002", "uga5003", "uga5004", "uga5005", "uga5006", "uga5007", "uga5008", "uga5009", "ugl5001", "ugl5002", "ugl5003", "ugl5004", "ugl5005", "ugl5006", "ugn5001", "ugn5002", "ugs5001", "ugs5002", "ugs5003", "ugs5004", "ugs5005", "ugs5006", "ugs5007", "ugs5008", "ugs5009", "ugs5010", "ugs5011", "ugs5012", "ugs5013", "ugs5014", "ugs5015", "ugs5016", "ugs5017", "ugs5018", "ugs5019", "ugs5020", "ugs5021", "ugs5022", "ugs5023", "ugs5024", "ugs5025", "ugs5026", "ugs5027", "ugs5028", "ugs5029", "ugs5030", "ugs5031", "ugs5032", "ugs5033", "ugs5034", "ugs5035", "ugs5036", "ugs5037", "ugs5038", "ugs5039", "ugs5040", "ugs5041", "ugs5042", "ugs5043", "ugs5044", "ugs5045", "ugs5046", "ugs5047", "ugs5048", "ugs5049", "ugs5050", "ugs5051", "ugs5052", "ugs5053", "ugs5054", "ugs5055", "ugs5056", "ugs5057", "ugs5058", "ugs5059", "ugs5060", "ugs5061", "ugs5062", "ugs5063", "ugs5064", "ugs5065", "ugs5066", "ugs5067", "ugs5068", "usl5002", "uss5002", "uss5003", "uss5004", "uss5005", "uss5006", "uss5007", "uss5008", "uss5009", "uss5010", "uss5011", "uss5012", "uss5013", "uss5014", "uss5015", "uss5016", "uss5017", "uss5018", "uss5019", "uss5020", "uss5021", "uss5022", "uss5023", "ucl9505" },
    ['common/projectiles/projectilesTemplates/'] = { "pbf0001", "pbf0002", "pbf0003", "pbf0004", "pbf0005", "pbf0006", "pbf0007", "pbf0008", "pbf0009", "psf0001", "psf0002", "psf0003", "psf0004", "psf0005", "psf0006", "psf0007", "psf0008", "psf0009", "psf0010", "psf0011", "psf0012", "psf0013", "psf0014", "psf0015", "psf0016", "psf0017", "psf0018", "psf0019", "psf0020", "psf0021", "psf0022", "psf0023", "psf0024", "psf0025", "psf0026", "psf0027", "psf0028", "psf0029", "psf0030", "psf0031", "psf0032", "psf0033", "psf0034", "psf0035", "psf0036", "psf0037", "psf0038", "psf0039", "psf0040", "psf0041", "psf0042", "psf0043", "psf0044", "psf0045", "psf0046", "psf0047", "psf0048", "psf0049", "psf0050", "psf0051", "psf0052", "psf0053", "psf0054", "psf0055", "psf0056", "psf0057", "psf0058", "psf0059", "psf0060", "psf0061", "psf0062", "psf0063", "psf0064", "psf0065", "psf0066", "psf0067", "psf0068", "psf0069", "psf0070", "psf0071", "psf0072", "psf0073", "psf0074", "psf0075", "psf0076", "psf0077", "psf0078", "psf0079", "psf0080", "psf0081", "psf0082", "psf0083", "psf0084", "psf0085", "psf0086", "psf0087", "psf0088", "psf0089", "psf0090", "psf0091", "psf0092", "psf0093", "psf0094", "psf0095", "psf0096", "psf0097", "psf0098", "psf0099", "psf0100", "psf0101", "psf0102", "psf0103", "psf0104", "psf0105", "psf0106", "psf0107", "psf0108", "psf0109", "psf0110", "psf0111", "psf0112", "psf0113", "psf0114", "psf0115", "psf0116", "psf0117", "psf0118", "psf0119", "psf0120", "psf0121", "psf0122", "psf0123", "psf0124", "psf0125", "psf0126", "psf0127", "psf0128", "psf0129", "psf0130", "psf0131", "psf0132", "psf0133", "psf0134", "psf0135", "psf0136", "psf0137", "psf0138", "psf0139", "psf0140", "psf0141", "psf0142", "psf0143", "psf0144", "psf0145", "psf0146", "psf0147", "psf0148", "psf0149", "psf0150", "psf0151", "psf0152", "psf0153", "psf0154", "psf0155", "psf0156", "psf0157", "psf0158", "psf0159", "psf0160", "psf0161", "psf0162", "psf0163", "psf0164", "psf0165", "psf0166", "psf0167", "psf0168", "psf0169", "psf0170", "psf0171", "psf0172", "psf0173", "psf0174", "psf0175", "psf0176", "psf0177", "psf0178", "psf0179", "psf0180", "psf0181", "psf0182", "psf0183", "psf0184", "psf0185", "psf0186", "psf0187", "psf0188", "psf0189", "psf0190", "psf0191", "psf0192", "psf0193", "psf0194", "pxd003", "psf5035" },
}
function ScanDir(directory)
    local folders = previousSourceRosterScan(directory)
    local ids = sourceRosterFolders[directory]
    if not ids then return folders end
    local known = {}
    for _, folder in ipairs(folders) do known[string.lower(folder)] = true end
    for _, id in ipairs(ids) do
        local path = directory .. id
        if not known[string.lower(path)] then folders[#folders + 1] = path; known[string.lower(path)] = true end
    end
    return folders
end
