require_relative "../config/environment.rb"

class Student
  attr_accessor :grade, :name
  attr_reader :id

  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql =<<-SQL
    CREATE TABLE IF NOT EXISTS
    students
    (id INTEGER PRIMARY KEY, name TEXT, grade INTEGER)
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql =<<-SQL
    DROP TABLE IF EXISTS students
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql=<<-SQL
    INSERT INTO students(name, grade)
    VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    stu = Student.new(name, grade)
    stu.save
    stu
  end

  def self.new_from_db(stu)
    new_stu = Student.new(stu[0], stu[1],stu[2])
    new_stu
  end

  def self.find_by_name(name)
    sql =<<-SQL
    SELECT *
    FROM students
    WHERE name = ?
    SQL
    DB[:conn].execute(sql, name).map{|stu| self.new_from_db(stu)}.first
  end

  def update
    sql =<<-SQL
    UPDATE students
    SET name = ?, grade = ?
    WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
end
