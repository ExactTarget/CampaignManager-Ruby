require "stories_helper"

class SiteTest < Test::Unit::TestCase  
  
  story "As a developer I want to see the homepage so I know Monk is correctly installed" do
    scenario "A visitor goes to the homepage" do
      visit "/"
      assert_contain "Hello, world!"
    end 
       
    scenario "A visitor goes to the testpage" do
      visit "/test"
      assert_contain "This is a Test, This is Only a Test"
    end  
    
    scenario "A visitor goes to the subfolder testpage" do
      visit "/folder/test"
      assert_contain "This is a Test of the Subfolder System"
    end      
    
    scenario "A visitor should see a 404 for a page that does not exist" do
      visit "/folder/testing"
      assert_contain "Sorry, the page /folder/testing could not be found"
    end
  end    

end
