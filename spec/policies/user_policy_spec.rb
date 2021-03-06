require 'rails_helper'

describe UserPolicy do
  subject { UserPolicy }
    
  let(:current_user) {FactoryGirl.build_stubbed :user}
  let(:other_user) {FactoryGirl.build_stubbed :user }
  let(:admin) {FactoryGirl.build_stubbed :user, :admin }
    
  permissions :index? do
    it "denies access if not an admin" do
      expect(UserPolicy).not_to permit(current_user)
    end
    
    it "allows access for an admin" do
      expect(UserPolicy).to permit(admin)
    end
  end
  
  permissions :show? do
    it "prevents other users from seeing the profile" do
      expect(subject).not_to permit(current_user, other_user)
    end
    
    it "allows owner to see profile" do
      expect(subject).to permit(current_user, current_user)
    end
    
    it "allows an admin to see profile" do
      expect(subject).to permit(admin)
    end
  end
  
  permissions :update? do
    it "prevents updates if not an admin" do
      expect(subject).not_to permit(current_user)
    end
    
    it "allows an admin to make updates" do
      expect(subject).to permit(admin)
    end
  end
  
  permissions :destroy? do
    it "prevents deleting yourself" do
      expect(subject).not_to permit(current_user, current_user)
    end
    
    it "allows an admin to delete any user" do
      expect(subject).to permit(admin, other_user)
    end
  end
end