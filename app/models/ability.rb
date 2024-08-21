class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.admin?
      can :manage, :all
    elsif user.merchant?
      can :manage, Product, user_id: user.id
      can :manage, Order, user_id: user.id
      can :read, Order
    elsif user.customer?
      can :read, Product
      can :create, Order
      can :manage, Order, user_id: user.id
    else
      can :read, Product
    end
  end
end
