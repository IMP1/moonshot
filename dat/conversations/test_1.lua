return {    
    participants = { "test" },
    condition = function(scene) return true end,
    tree = {
        { -- 1
            text = "Hello comrade bartender.\nPlease to have drink.\nOne of your finest vodka.\nAlso one moonshot.",
            speaker = "test",
            time = 10,
            timeout = 3,
            responses = {
                {
                    text = "Of course, coming right up.",
                    action = function(scene) 
                        scene:addDrinkRequest("test", "vodka")
                        scene:addDrinkRequest("test", "moonshot")
                    end,
                    next = 2,
                },
            },
        },
        { -- 2
            text = "Thank you comrade. Take your time.",
            speaker = "test",
            time = 60,
            timeout = 3,
            responses = {
                {
                    condition = function(scene)
                        return scene:drinksReady("vodka", "moonshot") 
                    end,
                    text = "Here you go. [1 vodka, 1 moonshot]",
                    action = function(scene)
                        scene:giveDrink("test", "vodka")
                        scene:giveDrink("test", "moonshot")
                    end,
                    next = 4,
                },
            },
        },
        { -- 3
            text = "Maybe I come back later, comrade. When you have more time.",
            speaker = "test",
            time = 3,
            timeout = 0,
            responses = {},
        },
        { -- 4
            text = "This is delciious drink. You are best bartender.",
            speaker = "test",
            time = 3,
            timeout = 0,
            responses = {},
        },
    },
}
