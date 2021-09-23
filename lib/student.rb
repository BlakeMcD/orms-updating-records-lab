require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  @@all = []

  attr_accessor :name, :grade
  attr_reader :id

  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  #CREATE TABLE
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students
      (
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        grade INTEGER
      )
    SQL
    DB[:conn].execute(sql)
  end

  #DROP TABLE
  def self.drop_table
    sql = <<-SQL
      DROP TABLE students
    SQL

    DB[:conn].execute(sql)
  end

  #SAVE INSTANCE
  def save

    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students(name, grade) VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  #CREATE INSTANCE
  def self.create(name, grade)
    new_student = Student.new(name, grade)
    new_student.save
  end

  #NEW_FROM_DB
  def self.new_from_db(row)
      student_id = row[0]
      student_name = row[1]
      student_grade = row[2]
      Student.new(student_id, student_name, student_grade)
  end

  #FIND BY NAME
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE name = ? LIMIT 1
    SQL

    DB[:conn].execute(sql,name).map do |row|
      Student.new_from_db(row)
    end.first


  end

  #UDPATE INSTANCE
  def update
    sql = <<-SQL
      UPDATE students SET name = ?, grade = ? WHERE ID = ?
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)

  end

end
