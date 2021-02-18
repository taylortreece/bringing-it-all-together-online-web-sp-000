class Dog

    attr_accessor :name, :breed
    attr_reader :id

    @@all=[]

    def initialize(name:, breed:, id: nil)
        @name=name
        @breed=breed
        @id=id
        @@all << self
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def save
        DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?,?)", self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(hash)
        d=self.new(name: hash[:name], breed: hash[:breed])
        d.save
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        self.new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE id= ?", id)[0])
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
            dog_data = dog[0]
            dog =self.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else
            song = self.new_from_db(dog.flatten)
            song.save
        end
    end

    def self.find_by_name(name)
        row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
        Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def update
        DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
    end
end