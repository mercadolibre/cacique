namespace :cacique do
  namespace :history do
    desc "Fixes suite history status"
    task :update_status => :environment do
      executions = SuiteExecution.idle_executions.each { |ex| ex.calculate_status.save }
      puts "#{executions.count} executions were outdated"
    end
  end
end