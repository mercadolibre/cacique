require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe "Paris" do
  include GoogleImageExample
  
  it "Has museums" do
    run_scenario :search_string => "Louvre"
  end

  it "Has bridges" do
    run_scenario :search_string => "Pont Neuf"
  end

  it "Has magnific cathedrals" do
    run_scenario :search_string => "Notre Dame de Paris"
  end

  it "Has magnificent Castles" do
    run_scenario :search_string => "Versailles"
  end

  it "Has a gorgeous river" do
    run_scenario :search_string => "Seine by Night"
  end

  it "Has weird towers" do
    run_scenario :search_string => "Tour Eiffel"
  end

  it "Has avenues" do
    run_scenario :search_string => "Avenue des Champs Elysees"
  end

end
