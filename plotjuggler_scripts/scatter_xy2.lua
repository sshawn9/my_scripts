--- https://slides.com/davidefaconti/plotjuggler-reactive-scripts
--- https://github.com/facontidavide/PlotJuggler/blob/main/plotjuggler_base/include/PlotJuggler/reactive_function.h
--- https://github.com/facontidavide/PlotJuggler/blob/main/plotjuggler_base/src/reactive_function.cpp

--- NOTE: ros_version is a global variable that must be set before calling this script

ros_version = 2

function sphere_single(prefix, title_str, x_str, y_str, size_str)
    local title = slash_str(prefix, title_str)
    local x = slash_str(prefix, x_str)
    local y = slash_str(prefix, y_str)
    local size = nil
    if size_str ~= nil then
        size = slash_str(prefix, size_str)
    end
    create_series(title, x, y, size)
end

function sphere_one(prefix, parent, title_str, x_str, y_str, size_str)
    local title = slash_str(parent, title_str)
    local x = slash_str(parent, x_str)
    local y = slash_str(parent, y_str)
    local size = nil
    if size_str ~= nil then
        size = slash_str(parent, size_str)
    end
    sphere_single(prefix, title, x, y, size)
end

function sphere_raw(prefix)
    sphere_one(prefix, "LocalPath/global_en", "xy", "x/data", "y/data", "size/data")
    sphere_one(prefix, "LocalPath/global_en", "k_s", "s/data", "k/data", "size/data")
end

function sphere_solve(prefix)
    sphere_one(prefix, "pm_input/local_xy", "xy", "x/data", "y/data", "size/data")
    sphere_one(prefix, "pm_input/local_xy", "h_s", "s/data", "h/data", "size/data")
    sphere_one(prefix, "pm_input/local_xy", "k_s", "s/data", "k/data", "size/data")
    sphere_one(prefix, "pm_input/local_en", "xy", "x/data", "y/data", "size/data")
    sphere_one(prefix, "pm_input/local_en", "h_s", "s/data", "h/data", "size/data")
    sphere_one(prefix, "pm_input/local_en", "k_s", "s/data", "k/data", "size/data")
    sphere_one(prefix, "pm_input/global_en", "xy", "x/data", "y/data", "size/data")
    sphere_one(prefix, "pm_input/global_en", "h_s", "s/data", "h/data", "size/data")
    sphere_one(prefix, "pm_input/global_en", "k_s", "s/data", "k/data", "size/data")

    sphere_one(prefix, "pm_result/local_xy", "xy", "x/data", "y/data", "size/data")
    sphere_one(prefix, "pm_result/local_xy", "h_s", "s/data", "h/data", "size/data")
    sphere_one(prefix, "pm_result/local_xy", "k_s", "s/data", "k/data", "size/data")
    sphere_one(prefix, "pm_result/local_en", "xy", "x/data", "y/data", "size/data")
    sphere_one(prefix, "pm_result/local_en", "h_s", "s/data", "h/data", "size/data")
    sphere_one(prefix, "pm_result/local_en", "k_s", "s/data", "k/data", "size/data")
    sphere_one(prefix, "pm_result/global_en", "xy", "x/data", "y/data", "size/data")
    sphere_one(prefix, "pm_result/global_en", "h_s", "s/data", "h/data", "size/data")
    sphere_one(prefix, "pm_result/global_en", "k_s", "s/data", "k/data", "size/data")

    sphere_one(prefix, "render_control/local_xy", "xy", "x/data", "y/data", "size/data")
    sphere_one(prefix, "render_control/local_xy", "h_s", "s/data", "h/data", "size/data")
    sphere_one(prefix, "render_control/local_xy", "k_s", "s/data", "k/data", "size/data")
    sphere_one(prefix, "render_control/local_en", "xy", "x/data", "y/data", "size/data")
    sphere_one(prefix, "render_control/local_en", "h_s", "s/data", "h/data", "size/data")
    sphere_one(prefix, "render_control/local_en", "k_s", "s/data", "k/data", "size/data")
    sphere_one(prefix, "render_control/global_en", "xy", "x/data", "y/data", "size/data")
    sphere_one(prefix, "render_control/global_en", "h_s", "s/data", "h/data", "size/data")
    sphere_one(prefix, "render_control/global_en", "k_s", "s/data", "k/data", "size/data")

    sphere_one(prefix, "render_lateral/local_xy", "xy", "x/data", "y/data", "size/data")
    sphere_one(prefix, "render_lateral/local_xy", "h_s", "s/data", "h/data", "size/data")
    sphere_one(prefix, "render_lateral/local_xy", "k_s", "s/data", "k/data", "size/data")
    sphere_one(prefix, "render_lateral/local_en", "xy", "x/data", "y/data", "size/data")
    sphere_one(prefix, "render_lateral/local_en", "h_s", "s/data", "h/data", "size/data")
    sphere_one(prefix, "render_lateral/local_en", "k_s", "s/data", "k/data", "size/data")
    sphere_one(prefix, "render_lateral/global_en", "xy", "x/data", "y/data", "size/data")
    sphere_one(prefix, "render_lateral/global_en", "h_s", "s/data", "h/data", "size/data")
    sphere_one(prefix, "render_lateral/global_en", "k_s", "s/data", "k/data", "size/data")

    sphere_one(prefix, "solve_result", "optimal_k_s", "s/data", "optimal_k/data", "size/data")
    sphere_one(prefix, "solve_result", "optimal_h_s", "s/data", "optimal_h/data", "size/data")
    sphere_one(prefix, "solve_result", "optimal_d_s", "s/data", "optimal_d/data", "size/data")
    sphere_one(prefix, "solve_result", "optimal_kv_s", "s/data", "optimal_kv/data", "size/data")
    sphere_one(prefix, "solve_result", "optimal_ka_s", "s/data", "optimal_ka/data", "size/data")
    sphere_one(prefix, "solve_result", "optimal_he_s", "s/data", "optimal_he/data", "size/data")
    sphere_one(prefix, "solve_result", "hr_s", "s/data", "hr/data", "size/data")
end

function sphere()
    if not init() then
        return
    end
    sphere_single("ref_path", "xy", "x/data", "y/data", "size/data")
    sphere_single("ref_path", "h_s", "s/data", "h/data", "size/data")
    sphere_single("ref_path", "k_s", "s/data", "k/data", "size/data")
    for prefix, _ in pairs(raw_prefixes) do
        sphere_raw(prefix)
    end
    for prefix, _ in pairs(solve_prefixes) do
        sphere_solve(prefix)
    end
end

function init()
    if not initialized then
        print("Initializing the scatter xy plot...")
        if (ros_version ~= 1 and ros_version ~= 2) then
            print("ros_version is not set correctly")
            return initialized
        end
        scatters = {}
        raw_prefixes = get_prefix_names("raw")
        solve_prefixes = get_prefix_names("solve")
        initialized = true
    end
    return initialized
end

function get_prefix_names(pattern)
    local series_names = GetSeriesNames()
    local names = {}
    for key, value in pairs(series_names) do
        local _, pattern_pos = string.find(value, pattern)
        if pattern_pos then
            local slash_pos = string.find(value, "/", pattern_pos + 1)
            if slash_pos then
                names[string.sub(value, 1, slash_pos)] = true
            end
        end
    end
    return names
end

function slash_str(str1, str2)
    if (str1 == nil or str1 == "") then
        return str2
    end
    if (str2 == nil or str2 == "") then
        return str1
    end
    local result = string.format("%s/%s", str1, str2)
    result = string.gsub(result, "/+", "/")
    result = string.gsub(result, "^/|/$", "")
    return result
end

function create_series(name, x_str, y_str, size_str)
    scatters[name] = ScatterXY.new(name)
    local series = scatters[name]
    series:clear()

    local size = nil
    if (size_str ~= nil) then
        size = TimeseriesView.find(size_str):atTime(tracker_time)
    end

    local i = 0
    while (true) do
        if (size ~= nil and i >= size) then
            break
        end

        local name_x, name_y
        if (ros_version == 1) then
            name_x = string.format("%s.%d", x_str, i)
            name_y = string.format("%s.%d", y_str, i)
        else
            name_x = string.format("%s[%d]", x_str, i)
            name_y = string.format("%s[%d]", y_str, i)
        end

        local series_x = TimeseriesView.find(name_x)
        if (series_x == nil) then
            --- print("series_x is nil")
            break
        end
        local x = series_x:atTime(tracker_time)
        if (x == nil) then
            print("x is nil")
            break
        end

        local series_y = TimeseriesView.find(name_y)
        if (series_y == nil) then
            --- print("series_y is nil")
            break
        end
        local y = series_y:atTime(tracker_time)
        if (y == nil) then
            print("y is nil")
            break
        end

        series:push_back(x, y)

        i = i + 1
    end
end

sphere()
