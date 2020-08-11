module ApplicationHelper
  # Appends ' | Redidit' to title, or returns homepage title
  def full_title(title)
    site_name = 'Redidit'
    return site_name if title.blank?

    title + ' | ' + site_name
  end

  def document_grid(view)
    DocumentGrid.new(view)
  end

  # Encapsulates logic for structure of content div including grid areas & items
  class DocumentGrid
    def initialize(view)
      @view = view
      @aside_markup = content_for(:aside)
    end

    def content(&block)
      focus = content_tag :div, block.call, class: focus_class
      content_inner = safe_join(contents.append(focus))
      content_tag :div, content_inner, class: content_class
    end

    private

    attr_reader :view, :aside_markup
    delegate :safe_join, :content_tag, :content_for, :content_for?, to: :view

    def contents
      return [] unless aside_markup

      [content_tag(:aside, aside_markup)]
    end

    def content_class
      content_classes.join(' ')
    end

    def focus_class
      focus_classes.join(' ')
    end

    def content_classes
      classes = ['content', aside_markup ? 'with-aside' : 'without-aside']
      return classes unless content_for?(:content_class)

      classes << content_for(:content_class)
    end

    def focus_classes
      classes = ['focus']
      return classes unless content_for?(:focus_class)

      classes << content_for(:focus_class)
    end
  end
end
