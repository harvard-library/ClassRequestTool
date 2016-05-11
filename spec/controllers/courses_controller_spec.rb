require 'rails_helper'

describe CoursesController, :type => :controller do
  
  # Dashboard tests  
  describe "#dashboard" do
   
    before (:each) do
      login_with create(:user, :staff)
    end
    
    it 'has a current user' do
      expect(subject.current_user).to_not be_nil
    end
      
    # Course with no repository    
    context 'homeless course' do
      it 'is displayed as homeless' do
        @course = create(:course, :homeless)
        get :dashboard
        expect(response.status).to eq(200)
        expect(assigns(:homeless).count).to eq(1)
        expect(assigns(:closed).count).to eq(0)
        expect(assigns(:to_close).count).to eq(0)
        expect(assigns(:unclaimed_unscheduled).count).to eq(0)
        expect(assigns(:unclaimed_unscheduled).count).to eq(0)
        expect(assigns(:unclaimed_scheduled).count).to eq(0)
        expect(assigns(:claimed_unscheduled).count).to eq(0)
        expect(assigns(:claimed_scheduled).count).to eq(0)
      end
    end
  
    # Course with a repository assigned
    context 'course with repository' do

      # Course without staff
      context '& without primary or secondary staff' do
        
        context '& current user is not on repo staff' do
          context '& unscheduled course' do
            it 'is not displayed'  do
              @course = create(:course, :unscheduled)
              get :dashboard
              expect(response.status).to eq(200)
              expect(assigns(:homeless).count).to eq(0)
              expect(assigns(:closed).count).to eq(0)
              expect(assigns(:to_close).count).to eq(0)
              expect(assigns(:unclaimed_unscheduled).count).to eq(0)
              expect(assigns(:unclaimed_scheduled).count).to eq(0)
              expect(assigns(:claimed_unscheduled).count).to eq(0)
              expect(assigns(:claimed_scheduled).count).to eq(0)
            end
          end
          context '& scheduled course' do
            it 'is not displayed' do
              @course = create(:course, :scheduled)
              get :dashboard
              expect(response.status).to eq(200)
              expect(assigns(:homeless).count).to eq(0)
              expect(assigns(:closed).count).to eq(0)
              expect(assigns(:to_close).count).to eq(0)
              expect(assigns(:unclaimed_unscheduled).count).to eq(0)
              expect(assigns(:unclaimed_scheduled).count).to eq(0)
              expect(assigns(:claimed_unscheduled).count).to eq(0)
              expect(assigns(:claimed_scheduled).count).to eq(0)
            end
          end
        end
        
        context '& current user is on repo staff' do
          context '& unscheduled course' do
            it 'is unclaimed and unscheduled' do
              @course = create(:course, :unscheduled)
              @course.repository.users = [ subject.current_user ]
              @course.update_stats   # Call after_save callback to update
              get :dashboard 
              expect(response.status).to eq(200)
              expect(assigns(:homeless).count).to eq(0)
              expect(assigns(:closed).count).to eq(0)
              expect(assigns(:to_close).count).to eq(0)
              expect(assigns(:unclaimed_unscheduled).count).to eq(1)
              expect(assigns(:unclaimed_scheduled).count).to eq(0)
              expect(assigns(:claimed_unscheduled).count).to eq(0)
              expect(assigns(:claimed_scheduled).count).to eq(0)
            end
          end
          context '& scheduled course' do
            it 'is unclaimed and scheduled' do
              @course = create(:course, :scheduled)
              @course.repository.users = [ subject.current_user ]
              @course.update_stats   # Call after_save callback to update
              get :dashboard
              expect(response.status).to eq(200)
              expect(assigns(:homeless).count).to eq(0)
              expect(assigns(:closed).count).to eq(0)
              expect(assigns(:to_close).count).to eq(0)
              expect(assigns(:unclaimed_unscheduled).count).to eq(0)
              expect(assigns(:unclaimed_scheduled).count).to eq(1)
              expect(assigns(:claimed_unscheduled).count).to eq(0)
              expect(assigns(:claimed_scheduled).count).to eq(0)
            end
          end
        end
      end
    
      
      # Current user is primary contact or secondary contact
      ['primary', 'secondary'].each do |contact|
        context "& current user is #{contact} contact" do
           
          context '& unscheduled course' do
            it 'is claimed and unscheduled' do
              case contact
              when 'primary'
                @course = create(:course, :unscheduled, :primary_contact => subject.current_user)
              when 'secondary'
                @course = create(:course, :unscheduled, :with_staff)
                @course.users << subject.current_user
              end
              @course.sections = [ create(:section) ]
              get :dashboard
              expect(response.status).to eq(200)
              expect(assigns(:homeless).count).to eq(0)
              expect(assigns(:closed).count).to eq(0)
              expect(assigns(:to_close).count).to eq(0)
              expect(assigns(:unclaimed_unscheduled).count).to eq(0)
              expect(assigns(:unclaimed_scheduled).count).to eq(0)
              expect(assigns(:claimed_unscheduled).count).to eq(1)
              expect(assigns(:claimed_scheduled).count).to eq(0)
            
            end
          end
          
          context '& scheduled in the future' do
            it 'is claimed and scheduled' do
              case contact
              when 'primary'
                @course = create(:course, :with_future_section, :primary_contact => subject.current_user)
              when 'secondary'
                @course = create(:course, :with_future_section, :with_staff)
                @course.users << subject.current_user
              end
              @course.update_stats   # Call after_save callback to update
              get :dashboard
              expect(response.status).to eq(200)
              expect(assigns(:homeless).count).to eq(0)
              expect(assigns(:closed).count).to eq(0)
              expect(assigns(:to_close).count).to eq(0)
              expect(assigns(:unclaimed_unscheduled).count).to eq(0)
              expect(assigns(:unclaimed_scheduled).count).to eq(0)
              expect(assigns(:claimed_unscheduled).count).to eq(0)
              expect(assigns(:claimed_scheduled).count).to eq(1)              
            end
          end
          
          context '& all sections are past' do           
            it 'is "To Close"' do
              case contact
              when 'primary'
                @course = create(:course, :with_past_section, :primary_contact => subject.current_user)
              when 'secondary'
                @course = create(:course, :with_past_section,  :with_staff)
                @course.users << subject.current_user
              end
              @course.update_stats   # Call after_save callback to update
              get :dashboard
              expect(response.status).to eq(200)
              expect(assigns(:homeless).count).to eq(0)
              expect(assigns(:closed).count).to eq(0)
              expect(assigns(:to_close).count).to eq(1)
              expect(assigns(:unclaimed_unscheduled).count).to eq(0)
              expect(assigns(:unclaimed_scheduled).count).to eq(0)
              expect(assigns(:claimed_unscheduled).count).to eq(0)
              expect(assigns(:claimed_scheduled).count).to eq(0)              
            end
          end
          context '& course has been closed' do
            it 'is "Closed"' do
              case contact
              when 'primary'
                @course = create(:course, :with_past_section,  :status => 'Closed', :primary_contact => subject.current_user)
              when 'secondary'
                @course = create(:course, :with_past_section,  :status => 'Closed', :users => [subject.current_user])
              end
              
              get :dashboard
              expect(response.status).to eq(200)
              expect(assigns(:homeless).count).to eq(0)
              expect(assigns(:closed).count).to eq(1)
              expect(assigns(:to_close).count).to eq(0)
              expect(assigns(:unclaimed_unscheduled).count).to eq(0)
              expect(assigns(:unclaimed_scheduled).count).to eq(0)
              expect(assigns(:claimed_unscheduled).count).to eq(0)
              expect(assigns(:claimed_scheduled).count).to eq(0)              
            end
          end
       end
      end
    end  
  end
end
