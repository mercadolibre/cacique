module GoogleImageExample
  
  def run_scenario(options)
    browser.open "/"
    page.location.should match(%r{http://images.google.com/})
    page.type "q", options[:search_string]
    page.click "btnG", :wait_for => :page
    page.click "rptgl"
    page.click "imgsz_l"
    page.click "imgtype_photo"
    page.click "btnG", :wait_for => :page
    page.text?(options[:search_string].split(/ /).first).should be_true
  end
  
end
