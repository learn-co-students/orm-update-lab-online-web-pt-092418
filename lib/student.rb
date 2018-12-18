require_relative "../config/environment.rb"

class Student
attr_accessor :name, :grade, :id

  def initialize(name, grade)
    @id = nil
    @name = name
    @grade = grade
  end

  def self.create_table
    sql =<<SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY, 
      name TEXT, 
      grade TEXT
    )
SQL
      DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def save
    if self.id 
      sql=<<SQL
      UPDATE students
      set name= ?,
      grade = ?
      WHERE id =?
SQL
      DB[:conn].execute(sql, self.name, self.grade, self.id)
    else
      sql=<<SQL
    INSERT INTO students(name, grade)
    VALUES (?,?)
SQL
    DB[:conn].execute(sql, self.name, self.grade)
    all_results = DB[:conn].execute("SELECT id, name, grade FROM students")
    first_row = all_results[0]
    @id = first_row[0]
    end
  end

  def self.create(name, grade)
      student = self.new(name, grade)
      student.save
      student
  end

  def self.new_from_db(row)
    new_student = self.new(row[1], row[2])
    new_student.id = row[0]
    new_student.name = row[1]
    new_student.grade = row[2]
    new_student
  end

  def self.find_by_name(name)
    sql =<<SQL
    SELECT *
    FROM students
    WHERE name =?
SQL
    result = DB[:conn].execute(sql, name)
    self.new_from_db(result[0])
    
  end

def update
  sql =<<SQL
  UPDATE students
  SET name = ?,
  GRADE = ?
SQL
  DB[:conn].execute(sql, self.name, self.grade)
end

end
