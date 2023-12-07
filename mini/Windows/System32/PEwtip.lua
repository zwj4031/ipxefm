-- 获取系统驱动器
systemdrive = os.getenv("systemdrive")

-- 执行ipconfig /all命令并获取输出
local exitcode, text = winapi.execute("ipconfig /all")
text = text:gsub("\r\n", "\n")

-- 定义获取网卡名称的函数
function getcardname(netcard)
    -- 定义网卡名称关键词和结束关键词
    local netcardsname = {"以太网适配器 以太网", "以太网适配器 Ethernet"} 
    local end_pattern = "TCPIP 上的 NetBIOS"
    local netcard = ""
    local recording = false
    -- 遍历输出的每一行
    for line in text:gmatch("[^\r\n]+") do
        -- 检查是否包含网卡名称关键词
        for _, start_pattern in ipairs(netcardsname) do
            if line:find(start_pattern) then
                recording = true
                break
            end
        end
        -- 如果包含关键词，则记录该行
        if recording then
            netcard = netcard .. line .. "\n"
        end
        -- 如果包含结束关键词，则停止记录
        if line:find(end_pattern) then
            recording = false
        end
    end
    return netcard
	
end

-- 定义获取环境变量的函数
function get_myenv()
    -- 获取网卡信息
    netcard = getcardname()
    -- 提取IP、子网掩码、默认网关和适配器名称
	adapter = string.match(netcard, "以太网适配器%s*(.-):")
    myip = netcard:match("IPv4 地址 .-: (%d+%.%d+%.%d+%.%d+)")
    mymask = netcard:match("子网掩码 .-: (%d+%.%d+%.%d+%.%d+)")
    mygw = string.match(netcard, "默认网关.-%s*(%d+%.%d+%.%d+%.%d+)%s*DHCP 服务器")
    if mygw == nil then mygw = netcard:match("默认网关. . . . . . . . . . . . . : (%d+%.%d+%.%d+%.%d+)") end
   	return myip,mymask,mygw,adapter
end

-- 定义设置IP的函数
function wtip()
    get_myenv()
    -- 如果系统驱动器为X:，则使用pecmd.exe设置IP
    if systemdrive == "X:" then
        exec("pecmd.exe PCIP " .. myip .. "," .. mymask .. "," .. mygw .. "," .. mygw .. ";223.5.5.5,0")
    else
        -- 否则，使用netsh命令设置IP和DNS
        local cmd_wtip = string.format('netsh interface ip set address "' .. adapter .. '" static %s %s %s', myip, mymask, mygw)
        exec("/hide",cmd_wtip)
        exec("/hide",'netsh interface ip add dns "' .. adapter .. '" ' .. mygw .. ' index=1')
        exec("/hide",'netsh interface ip add dns "' .. adapter .. '" 223.5.5.5 index=2')
    end
end

-- 调用设置IP的函数
wtip()

 


