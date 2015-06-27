require 'test_helper'

class CoursesControllerTest < ActionController::TestCase
  # Dashboard tests
  
  # Course with no repository
  context 'class has no repository' do
    @course = build(:course, :homeless)
    should 'display class as homeless' do
      assert_equal(1, @homeless.count) do
        get :dashboard
      end
    end
  end
  
  # Course with a repository assigned
  context 'course has a repository' do
  
    # Course without users
    context 'course has no primary or secondary staff' do
      context 'course repository is assigned to user' do
        context 'no dates assigned' do
          should 'classify course as class to be scheduled' do
          end
        end
        context 'dates assigned' do
          should 'classify class as scheduled' do
          end
        end
      end
      context 'course repository is not assigned to user' do
        should 'not present class to user' do
        end
      end
    end

    
    # Course with user
    context 'user is primary or secondary staff' do
      context 'class has date assigned' do
        should 'classify class as claimed, scheduled' do
        end
      end
    
      context 'class has no date assigned' do
        should 'classify class as claimed, unscheduled' do
        end
      end
    
      context 'class dates are in the past' do
        should 'classify class as available to close' do
        end
      end
    
      context 'class has status <closed>' do 
        should 'classify class as closed' do
        end
      end
    end
    
    context 'user is not primary or secondary staff' do
      should 'not present class to user' do
      end
    end
  end
  

end
