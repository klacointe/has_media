module HasMediaHelper

  ## 
  # Generate a unique uid used in forms
  #
  # @param [Hash]   available keys :
  #   - context: the context to link medium
  #   - object : the medium related object
  #   - medium : the medium object
  #
  # @return [String]
  #
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

  ##
  # Create a link to add medium file field with ajax
  #
  # @params [Hash]    available keys :
  #   - object : the meduim related object (mandatory)
  #   - context: the context to link medium (mandatory)
  #   - text: link test label (optional)
  #
  # @return [String]
  #
  def add_medium_link(opts)
    unless opts.keys.include?(:object) || 
      opts.keys.include?(:context)
      raise "Must give object and context" 
    end
    klass = opts[:object].class.to_s.underscore
    opts[:text]||= I18n.t('add_link', 
      :medium_label => I18n.t(opts[:context], :scope => [:activerecord, :attributes, klass]),
      :scope => [:has_media, :form])
    link_to_function opts[:text] do |page| 
      page.insert_html :bottom, generate_uid(
        :object => opts[:object], 
        :context => opts[:context]
      ), 
      :partial => 'has_media/medium_field', 
      :locals => {
        :object => opts[:object], 
        :context => opts[:context]
      }
    end 
  end

  ##
  # Create a remove medium link using Ajax
  # Compatible with jQuery and Prototype
  #
  # @param [Hash]   available keys :
  #   - medium : the medium to destroy
  #   - text : link text label (optional)
  #
  # @return [String]
  #
  def remove_medium_link(opts)
    opts[:text] ||= I18n.t('remove_link', :scope => [:has_media, :form])
    link_to opts[:text], medium_url(opts[:medium]), :remote => true, :method => :delete
  end

  ##
  # Create a file field for a medium
  #
  # @param [Medium]   model, A medium object
  # @param [String]   context, the context to link medium
  #
  # @return [String]
  #
  def has_media_field(model, context)
    render :partial => "has_media/media_fields", :locals => {
      :object => model,
      :context => context
    }
  end

end
