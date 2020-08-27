class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize (id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      )
    SQL
        
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end
  
  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      end
    self
  end
  
  def self.create(hash)
        dog = self.new(name: hash[:name], breed: hash[:breed]).tap{|d| d.save}
  end
  
  def self.new_from_db(array)
        dog = self.new(id: array[0], name: array[1], breed: array[2])
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL
    
    dog = self.new_from_db(DB[:conn].execute(sql, id).first)
  end

  def self.find_or_create_by(name:, breed:)
    if dog = self.find_by_name_breed(name, breed)
      self.new(id: dog[0], name: dog[1], breed: dog[2])
    else
      self.create(name: name, breed: breed)
    end
  end

    def self.find_by_name_breed(name, breed)
      sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ? AND breed = ?
      SQL
      
      dog = DB[:conn].execute(sql, name, breed).first
    end

    def self.find_by_name(name)
      sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        LIMIT 1
      SQL
      
      dog = DB[:conn].execute(sql, name).first
      self.new(id: dog[0], name: dog[1], breed: dog[2])
    end
    
  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end

#if its right but not passing, look at SPECs for formatting hints. Sometimes they want it written a specific way and in a specific order 