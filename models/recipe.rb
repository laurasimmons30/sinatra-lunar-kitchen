def db_connection
  begin
    connection = PG.connect(dbname: "recipes")
    yield(connection)
  ensure
    connection.close
  end
end

class Recipe
  attr_reader :id, :name, :description, :instructions
  def initialize(id,name,description, instructions)
    @id = id
    @name = name
    @description = description
    @instructions = instructions
  end

  def self.all
    result = db_connection do |conn|
      conn.exec("SELECT * FROM recipes")
    end
    recipes_array = []
    result.each do |recipe|
      recipes_array << Recipe.new(recipe["id"],recipe["name"], recipe["description"], recipe["instructions"])
    end
    recipes_array
  end

  def self.find(id)
    param_id = [id]
    result = db_connection do |conn|
      conn.exec("SELECT * FROM recipes WHERE id = $1", param_id)
    end
    Recipe.new(result[0]["id"], result[0]["name"], result[0]["description"], result[0]["instructions"])
  end
end


