module HasMediaHelper

  def generate_uid(*opts)
    opts = opts.first
    object = opts[:object]||nil
    context = opts[:context]||nil
    medium = opts[:medium]||nil
    if medium.nil?
      if object.nil? or object.new_record?
        "#{object.class.to_s.underscore}-#{context.to_s.underscore}"
      else
        "#{object.class.to_s.underscore}-#{context.to_s.underscore}-#{object.id}"
      end
    else
      "#{medium.class.to_s.underscore}-#{medium.id}"
    end
  end

  def add_medium_link(opts)
    link_to_function opts[:text] do |page| 
      page.insert_html :bottom, generate_uid(:object => opts[:object], :context => opts[:context]), 
        :partial => 'has_media/medium_field', 
        :locals => {
          :object => opts[:object], 
          :context => opts[:context]
        }
    end 
  end

  def remove_medium_link(opts)
    link_to opts[:text], medium_url(opts[:medium]), :remote => true, :method => :delete
  end

  def has_media_field(model, context)
    render :partial => "has_media/media_fields", :locals => {
      :object => model,
      :context => context
    }
  end

end
