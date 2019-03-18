function typeGraph(myType::DataType)
    if supertype(myType) != Any
        typeGraph(supertype(myType))
        print(" --> ")
        print(myType)

    else
        print("Any")
    end
end
