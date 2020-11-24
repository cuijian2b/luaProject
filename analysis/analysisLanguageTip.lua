local lfs = require("lfs")

-- 缺失翻译标识
local missingTip = "CUIJIAN"
local rightSquareTip = "CUIrightSquareJIAN"
local lessTipFile = "./lessTip.txt"

local function readTxtToTable(infile, tip)
    -- 读取文件数据
    local hFile     = io.open(infile, "r")
    local readStr   = hFile:read("*a")
    hFile:close()

    -- 将]替换成替换标识
    local tableStr = (string.gsub(readStr, "%]", rightSquareTip))
    -- 将字符传为table结构
    tableStr = (string.gsub(tableStr, "{\"", "= [["))
    tableStr = (string.gsub(tableStr, "\"}", "]],"))
    tableStr = (string.gsub(tableStr, "string", "msg = "))
    tableStr = tableStr..";"

    local tableInfo = (loadstring(tableStr))

    return tableInfo().msg
end

local function writeTableToTxt(outfile, tip, tableInfo)
    -- 排序标识
    local sordKeys = {}
    for k, v in pairs(tableInfo) do
        table.insert(sordKeys, k)
    end
    table.sort(sordKeys, function (a, b)
        return a < b
    end)

    -- 转为目标格式字符
    local tableStr = tip.."{\n    string {\n"
    for i, key in ipairs(sordKeys) do
        tableStr = tableStr.."        "..key.." {\""..tableInfo[key].."\"}\n"
    end
    tableStr = tableStr.."    }\n}"
    -- 还原]
    tableStr = (string.gsub(tableStr, rightSquareTip, "%]"))

    -- 写入数据
    local hFile = assert(io.open(outfile, "w"))
    if hFile then
        if hFile:write(tableStr) == nil then
            return
        end
        io.close(hFile)
    end
end

local function compareLanguageTips()
    local srcFile, srcTip = "./zh_CN.txt", "zh_CN"
    local fpath, ftype = "./Before", ".txt"
    -- 比对的文件
    local srcMsgTips = readTxtToTable(srcFile, srcTip)
    -- 缺失信息
    local missingMsg = ""

    -- 遍历目标文件
    for _, fileName in pairs(lfs.dir(fpath)) do
        -- 是否为目标类型
        if string.find(fileName, ftype) then
            local fileTip = (string.gsub(fileName, ftype, ""))
            -- 将文本信息转为table
            local upTips = readTxtToTable(fpath.."/"..fileName, fileTip)
            -- 保存缺失信息
            missingMsg = missingMsg.."\n\n"..fileTip.."\n"
            local outTips = {}
            -- 与比较对象比较
            for key, value in pairs(srcMsgTips) do
                if upTips[key] then
                    outTips[key] = upTips[key]
                else
                    outTips[key] = missingTip
                    missingMsg = missingMsg..key..":"..value.."\n"
                end
            end
            -- 保存翻译到新文件
            writeTableToTxt("./"..fileName, upTips, outTips)
        end
    end

    -- 保存缺失翻译到文件
    -- 写入数据
    local hFile = assert(io.open(lessTipFile, "w"))
    if hFile then
        if hFile:write(missingMsg) == nil then
            return
        end
        io.close(hFile)
    end
    
end

compareLanguageTips()