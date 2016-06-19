module StripeWrapper
  class Charge
    attr_reader :error_message, :response

    def initialize(options = {})
      @response = options[:response]
      @error_message = options[:error_message]
    end

    def self.create(options = {})
      response = Stripe::Charge.create(
        amount: options[:amount],
        currency: 'cad',
        card: options[:card],
        description: options[:description]
      )
      new(response: response)
    rescue Stripe::CardError => e
      new(error_message: e.message)
    end

    def successful?
      response.present?
    end
  end
end
