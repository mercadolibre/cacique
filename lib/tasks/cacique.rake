namespace :cacique do
  namespace :history do
    desc "Fixes suite history status (for executions than runned yesterday)"
    task :update_status => :environment do
      executions = SuiteExecution.last_idle_executions.each { |ex| ex.calculate_status.save }
      puts "#{executions.count} executions were outdated"
    end

    desc "Fixes suite history status (full scan)"
    task :update_status_complete => :environment do
      executions =  Execution.update_all_idle_executions
      suites = SuiteExecution.update_all_idle_executions
      puts "#{executions} executions and #{suites} suite executions were updated"
    end
  end
end