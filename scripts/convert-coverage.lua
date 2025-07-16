#!/usr/bin/env lua

-- Convert luacov coverage to lcov format for Codecov
local function convert_luacov_to_lcov()
    local stats_file = io.open("luacov.stats.out", "r")
    if not stats_file then
        print("Error: luacov.stats.out not found")
        os.exit(1)
    end
    
    local lcov_file = io.open("lcov.info", "w")
    if not lcov_file then
        print("Error: Cannot create lcov.info")
        os.exit(1)
    end
    
    local current_file = nil
    local line_count = 0
    local hit_count = 0
    local line_data = {}
    
    for line in stats_file:lines() do
        if line:match("^%d+:(.+)$") then
            -- File header: "176:lua/mona/config.lua"
            current_file = line:match("^%d+:(.+)$")
            if current_file and current_file:match("%.lua$") then
                lcov_file:write(string.format("SF:%s\n", current_file))
                line_count = 0
                hit_count = 0
                line_data = {}
            end
        elseif line:match("^%s*[0-9%s]+$") and current_file then
            -- Line coverage data: "3 3 0 3 0 3 3 3..."
            local numbers = {}
            for num in line:gmatch("%d+") do
                table.insert(numbers, tonumber(num))
            end
            
            for i, hits in ipairs(numbers) do
                line_count = line_count + 1
                if hits > 0 then
                    hit_count = hit_count + 1
                end
                lcov_file:write(string.format("DA:%d,%d\n", line_count, hits))
            end
        end
    end
    
    -- Write summary for each file
    if current_file then
        lcov_file:write(string.format("LH:%d\n", hit_count))
        lcov_file:write(string.format("LF:%d\n", line_count))
        lcov_file:write("end_of_record\n")
    end
    
    stats_file:close()
    lcov_file:close()
    print("Converted luacov coverage to lcov.info")
end

convert_luacov_to_lcov() 