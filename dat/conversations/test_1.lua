return {    
    participants = { "test" },
    condition = function(scene) return true end,
    tree = {
        { -- 1
            text = "Hello comrade bartender. Please to have drink. One of your finest vodka and one moonshot, also.",
            time = 1,
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
            time = 10,
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
                }
            }
        },
        { -- 3
            text = "Maybe I come back later, comrade. When you have more time.",
        },
        { -- 4
            text = "This is delciious drink. You are best bartender.",
        }
    },
}
