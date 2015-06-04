require_relative 'ingredient'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: "recipes")
    yield(connection)
  ensure
    connection.close
  end
end

class Recipe
  attr_reader :id, :name, :description, :instructions, :ingredients
  def initialize(id,name,description, instructions, ingredients)
    @id = id
    @name = name
    @description = description
    @instructions = instructions
    @ingredients = ingredients
  end

  def self.all
    result = db_connection do |conn|
      conn.exec("SELECT * FROM recipes")
    end
    recipes_array = []
    result.each do |recipe|
      recipes_array << Recipe.new(recipe["id"],
                                  recipe["name"],
                                  recipe["description"],
                                  recipe["instructions"],
                                  recipe["ingredients"])
    end
    recipes_array
  end

  def self.find(id)
    param_id = [id]
    result = db_connection do |conn|
      conn.exec("SELECT recipes.id, recipes.name AS recipe_name, recipes.description, recipes.instructions, ingredients.name FROM recipes                                                               
                JOIN ingredients ON recipes.id = ingredients.recipe_id                                                                                                      
                WHERE recipes.id = $1;", param_id)
            end
    ingredient_array = []
    result.each do |ingredient|
      ingredient_array << Ingredient.new(ingredient["name"])
    end 
    Recipe.new(result[0]["id"],
               result[0]["recipe_name"],
               result[0]["description"],
               result[0]["instructions"],
               ingredient_array)
  end
end


