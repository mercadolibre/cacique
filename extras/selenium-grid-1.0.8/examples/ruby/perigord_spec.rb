require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe "Perigord" do
  include GoogleImageExample
  
  it "Has magnific cro-magnon paintings" do
    run_scenario :search_string => "lascaux hall of the bull"
  end

  it "Has magnific cities" do
    run_scenario :search_string => "Sarlat"
  end

  it "Has magnific cathedrals" do
    run_scenario :search_string => "Cathedral in Périgueux"
  end

  it "Has great wines" do
    run_scenario :search_string => "Montbazillac"
  end

end
