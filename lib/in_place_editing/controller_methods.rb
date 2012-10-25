module InPlaceEditing
  def self.included(base)
    base.extend(ClassMethods)
  end

  # Example:
  #
  #   # Controller
  #   class BlogController < ApplicationController
  #     in_place_edit_for :post, :title
  #   end
  #
  #   # View
  #   <%= in_place_editor_field :post, 'title' %>
  #
  module ClassMethods
    def in_place_edit_for(object, attribute, options = {})
      define_method("set_#{object}_#{attribute}") do
        unless request.post? or request.put? then
          return render(:text => 'Method not allowed', :status => 405)
        end
        @item = object.to_s.camelize.constantize.find(params[:id])
        @item.update_attribute(attribute, params[:value])
        blank_value = options[:blank_value] || "(click to add a #{attribute})"
        value = @item.send(attribute).to_s
        value = blank_value if value.blank?
        render :text => CGI::escapeHTML(value)
      end
      define_method("get_#{object}_#{attribute}") do
        item = object.to_s.camelize.constantize.find(params[:id])
        value = item.send(attribute).to_s
        render :text => CGI::escapeHTML(value)
      end
    end
  end
end
