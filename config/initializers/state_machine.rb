# state_machine does not work with Rails 4.1+, see https://github.com/pluginaweek/state_machine/issues/295

module StateMachine::Integrations::ActiveModel
  alias_method :around_validation_protected, :around_validation
  def around_validation(*args, &block)
    around_validation_protected(*args, &block)
  end
end