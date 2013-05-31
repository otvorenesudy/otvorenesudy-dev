module TagHelper
  def square_tag(type, body, options = {})
    content_tag :span, body, options.merge(class: "label label-#{type.to_s}")
  end

  def round_tag(type, body, options = {})
    content_tag :span, body, options.merge(class: "badge badge-#{type.to_s}")
  end

  def icon_tag(type, options = {})
    icon  = content_tag :i, nil, class: "icon-#{type.to_s}"
    label = options.delete(:label)

    unless label.blank?
      space = content_tag :i, '&nbsp;'.html_safe, class: :'icon-space'
      body  = [icon, space, label.to_s]
      body.reverse! if options.delete(:join) == :append
      icon = content_tag :span, body.join.html_safe, options
    end

    icon
  end

  def icon_link_to(type, body, url, options = {})
    link_to icon_tag(type, label: body, join: options.delete(:join)), url, options
  end

  def icon_mail_to(type, body, url = nil, options = {})
    url = body if url.blank?

    mail_to url, icon_tag(type, label: body, join: options.delete(:join)), options
  end

  def navbar_logo_tag(title)
    classes = [:capital]
    classes << :active if current_page? root_path

    content_tag :li, link_to(title, root_path, class: :brand), class: classes 
  end

  def navbar_li_tag(type, body, url, options = {})
    options.merge!(class: :active) if request.fullpath.start_with? url

    content_tag :li, icon_link_to(type, body, url), options
  end

  def popover_tag(body, content, options = {})
    options.merge! rel: :popover, title: options.delete(:title)
    options.merge! data placement: options.delete(:placement) || :top, trigger: options.delete(:trigger) || :click
    options.merge! data content: content, html: true

    link_to body, '#', options
  end

  def tooltip_tag(body, title, options = {})
    options.merge! rel: :tooltip, title: title
    options.merge! data placement: options.delete(:placement) || :top, trigger: options.delete(:trigger) || :hover

    link_to body, '#', options
  end

  def button_group_tag(values, options = {})
    options.merge! class: 'btn-group' 
    options.merge! data toggle: 'buttons-radio'

    content_tag :div, button_tags(values).join.html_safe, options
  end

  def button_tags(values)
    options = { class: 'btn', type: 'button' }

    values.map { |value| button_tag value, options.merge(data value: value) }
  end

  def sortable_table_tag(options = {}, &block)
    options.merge! :'data-sortable' => true

    content_tag :table, options, &block
  end

  def sortable_th_tag(title = nil, options = {}, &block)
    options.merge! :'data-sorter' => :text

    return content_tag :th, options, &block if block_given?

    content_tag :th, title, options
  end

  def link_to_with_count(title, href, count, options = {})
    count = content_tag :span, "&nbsp;(#{number_with_delimiter(count)})".html_safe, class: :muted

    link_to title.concat(count).html_safe, href, options
  end

  def tab_link_to_with_count(title, href, count, options = {})
    options.merge! :'data-toggle' => :tab

    link_to_with_count(title, href, count, options)
  end

  def external_link_to(body, url, options = {})
    options.merge! target: :_blank

    icon_link_to :'external-link', body, url, options.merge(join: :append)
  end

  private

  def data(options = {})
    options.inject({}) { |o, (k, v)| o["data-#{k}"] = v; o }
  end 
end