class Admin::SourcesController < Admin::ApplicationController

  load_and_authorize_resource Source 
  
  def show
    @source = Source.find_by_name(params[:id])
    respond_with do |format|
      format.html do
        if request.xhr?  
          render :partial => "show"       
        else
          render :show
        end
      end
      format.json do
        status = [{ "name" => "queued", "value" => @source.retrieval_statuses.queued.size },
                 { "name" => "stale ", "value" => @source.retrieval_statuses.stale.size },
                 { "name" => "refreshed", "value" => Article.count - (@source.retrieval_statuses.stale.size + @source.retrieval_statuses.queued.size) }]
        events = [{ "name" => "with events ", 
                           "day" => @source.retrieval_statuses.with_events(1).size,
                           "month" => @source.retrieval_statuses.with_events(31).size },
                         { "name" => "without events", 
                           "day" => @source.retrieval_statuses.without_events(1).size,
                           "month" => @source.retrieval_statuses.without_events(31).size },
                         { "name" => "not updated", 
                           "day" => Article.count - (@source.retrieval_statuses.with_events(1).size + @source.retrieval_statuses.without_events(1).size),
                           "month" => Article.count - (@source.retrieval_statuses.with_events(31).size + @source.retrieval_statuses.without_events(31).size) }]
        render :json => { "status" => status, "events" => events }
      end
    end 
  end
  
  def index
    @groups = Group.includes(:sources).order("groups.id, sources.display_name")
    respond_with @groups
  end

  def edit
    @source = Source.find_by_name(params[:id])
    respond_with(@source) do |format|  
      format.js { render :show }
    end
  end


  def update
    @source = Source.find_by_name(params[:id])
    @source.update_attributes(params[:source])   
    respond_with(@source) do |format|  
      format.js { render :show }
    end
  end
end