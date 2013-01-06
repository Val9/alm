class ErrorMessagesController < ActionController::Base
  layout APP_CONFIG['layout']
  
  respond_to :html, :xml, :json
  
  # Modified from http://geekmonkey.org/articles/29-error_message-applications-in-rails-3-2

  def create
    # From https://github.com/rails/rails/blob/master/actionpack/lib/action_dispatch/middleware/public_exceptions.rb and
    # http://www.sharagoz.com/posts/1-rolling-your-own-exception-handler-in-rails-3
    exception    = env["action_dispatch.exception"]
    request      = ActionDispatch::Request.new(env)
    content_type = request.formats.first.to_s
    
    class_name   = exception.class.to_s
    message      = exception.to_s
    trace        = exception.backtrace.join("\n")
    status       = env["PATH_INFO"][1..-1]
    target_url   = request.original_url
    referer_url  = request.referer
    user_agent   = request.user_agent

    @error_message = ErrorMessage.new(:class_name => class_name,
                                      :message => message,
                                      :trace => trace,
                                      :status => status,
                                      :target_url => target_url,
                                      :referer_url => referer_url,
                                      :user_agent => user_agent,
                                      :content_type  => content_type)
    @error_message.save
    
    respond_with(@error_message) do |format|
      format.json { render json: { error: @error_message.public_message }, status: @error_message.status }
      format.xml  { render xml: @error_message.public_message, root: "error", status: @error_message.status }
      format.html { render :show, status: @error_message.status, layout: !request.xhr? }
    end
  end

end