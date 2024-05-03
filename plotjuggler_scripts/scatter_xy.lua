--- https://slides.com/davidefaconti/plotjuggler-reactive-scripts
--- https://github.com/facontidavide/PlotJuggler/blob/main/plotjuggler_base/include/PlotJuggler/reactive_function.h
--- https://github.com/facontidavide/PlotJuggler/blob/main/plotjuggler_base/src/reactive_function.cpp

--- NOTE: ros_version is a global variable that must be set before calling this script
ros_version = 0

function print_series_names()
    local series_names = GetSeriesNames()
    for i, name in ipairs(GetSeriesNames()) do
        print("Series name " .. i .. ": " .. name)
    end
end

--- create series for scatter plot
function create_series(series, x_str, y_str, size_str, prefix)
    if (ros_version ~= 1 and ros_version ~= 2) then
        print("ros_version is not set correctly")
        return
    end

    series:clear()

    local size = nil
    if (size_str ~= nil) then
        if (prefix ~= nil) then
            size_str = string.format("%s/%s", prefix, size_str)
        end
        size = TimeseriesView.find(size_str):atTime(tracker_time)
    end

    local i = 0
    while (true) do
        if (size ~= nil and i >= size) then
            break
        end

        local name_x, name_y
        if (prefix == nil) then
            if (ros_version == 1) then
                name_x = string.format("%s.%d", x_str, i)
                name_y = string.format("%s.%d", y_str, i)
            else
                name_x = string.format("%s[%d]", x_str, i)
                name_y = string.format("%s[%d]", y_str, i)
            end
        else
            if (ros_version == 1) then
                name_x = string.format("%s/%s.%d", prefix, x_str, i)
                name_y = string.format("%s/%s.%d", prefix, y_str, i)
            else
                name_x = string.format("%s/%s[%d]", prefix, x_str, i)
                name_y = string.format("%s/%s[%d]", prefix, y_str, i)
            end
        end

        local series_x = TimeseriesView.find(name_x)
        if (series_x == nil) then
            print("series_x is nil")
            break
        end
        local x = series_x:atTime(tracker_time)
        if (x == nil) then
            print("x is nil")
            break
        end

        local series_y = TimeseriesView.find(name_y)
        if (series_y == nil) then
            print("series_y is nil")
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

scatters = {}
function add_scatter(name, x_str, y_str, size_str, prefix)
    if (prefix ~= nil) then
        name = string.format("%s/%s", prefix, name)
    end
    name = string.format("Array/%s", name)

    scatters[name] = ScatterXY.new(name)
    create_series(scatters[name], x_str, y_str, size_str, prefix)
end

------------------------------------------------------------
--- My personal usage below
------------------------------------------------------------
function plot(prefix)
    add_scatter("optimal_xy", "optimal_x/data", "optimal_y/data", "N/data", prefix)
end
