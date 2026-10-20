class ApplicationController < ActionController::Base
  protect_from_forgery
  # Allow the iOS client (and other JSON API consumers) to mutate without a CSRF token.
  skip_before_filter :verify_authenticity_token, :if => :json_request?

  private

  def json_request?
    request.format.json?
  end
end
