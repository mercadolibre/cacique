class SuitesTaskProgram < ActiveRecord::Base
  belongs_to :task_program
  belongs_to :suite
end
