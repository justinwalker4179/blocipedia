class ChargesController < ApplicationController
  def create
  # Creates a Stripe Customer object, for associating 
  # with the charge
   
    customer = Stripe::Customer.create(
      email: params[:stripeEmail],
      card: params[:stripeToken]
    )
  # Where the real magic happens
    charge = Stripe::Charge.create(
      customer: customer.id, #Note -- this is NOT the user_id in your app
      amount: Amount.default,
      description: "BigMoney Membership - #{current_user.email}",
      currency: 'usd'
    )
  
    current_user.stripe_id = customer.id
    change_account()
    flash[:notice] = "Thanks for all the money, #{current_user.email}! Feel free to pay me again."
    redirect_to root_path # or wherever
  
  # Stripe will send back CardErrors, with friendly messages
  # when something goes wrong.
  # This 'rescue block' catches and displays those errors
  
    rescue Stripe::CardError => e
      flash[:alert] = e.message
      redirect_to new_charge_path
    
  end

  def new
    @stripe_btn_data = {
      key: "#{ Rails.configuration.stripe[:publishable_key]}",
      description: "BigMoney Membership - #{current_user.email}",
      amount: Amount.default
      }
  end

  def destroy
    customer = Stripe::Customer.retrieve(current_user.stripe_id)
    
    if customer.delete
      change_account()
      flash[:notice] =  current_user.role
      redirect_to root_path
    else
      flash[:alert] = "Something went wrong. Please try again."
      redirect_to new_charge_path
    end
  end
  
  class Amount
    @default_amount = 15_00
    def self.default
      @default_amount
    end
  end
  
  def change_account
    if current_user.role == "user"
      current_user.update(role: 1)
    else
      current_user.update(role: 0)
    end
  end
end