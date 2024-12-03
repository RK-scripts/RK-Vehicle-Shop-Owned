local currentCategory = nil
local currentVehicleIndex = 1
local isMainMenu = true
local rotation = 0.0

function OpenVehicleShop()
    isMainMenu = true
    DisplayCategoryMenu()
end

function DisplayCategoryMenu()
    local categories = Config.Categories
    
    SetScaleformParams()
    
    while isMainMenu do
        Wait(0)
        DrawCategories(categories)
        
        if IsMouseClicked() then
            local selectedCategory = GetSelectedCategory()
            if selectedCategory then
                currentCategory = selectedCategory
                isMainMenu = false
                DisplayVehicleList(currentCategory)
            end
        end
    end
end

function DisplayVehicleList(category)
    local vehicles = Config.Vehicles[category]
    
    while not isMainMenu do
        Wait(0)
        DrawVehicleList(vehicles, currentVehicleIndex)
        
        if IsControlPressed(0, 174) then
            rotation = rotation - 1.0
            SetEntityHeading(displayVehicle, rotation)
        elseif IsControlPressed(0, 175) then
            rotation = rotation + 1.0
            SetEntityHeading(displayVehicle, rotation)
        end
        
        if IsControlJustPressed(0, 172) then
            currentVehicleIndex = currentVehicleIndex - 1
            if currentVehicleIndex < 1 then currentVehicleIndex = #vehicles end
            UpdateDisplayVehicle(vehicles[currentVehicleIndex])
        elseif IsControlJustPressed(0, 173) then
            currentVehicleIndex = currentVehicleIndex + 1
            if currentVehicleIndex > #vehicles then currentVehicleIndex = 1 end
            UpdateDisplayVehicle(vehicles[currentVehicleIndex])
        end
        
        if IsControlJustPressed(0, 177) then
            isMainMenu = true
            currentVehicleIndex = 1
            DeleteDisplayVehicle()
            DisplayCategoryMenu()
        end
    end
end