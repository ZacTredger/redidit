# Interface for the Faker gem
module Fake
  # Returns a random creation datetime within the last 3 months
  def self.creation_date
    rand(1..2000).hours.ago
  end

  # Create posts by calling `post_sub-name` (e.g. post_doggos)
  class PostMaker
    class << self
      private

      def method_missing(name, *args, &block)
        return super unless (poster = post_method_test(name))

        poster.new.make_post_and_comments
      end

      def respond_to_missing?(name)
        post_method_test(name) || super
      end

      def post_method_test(name)
        (md = name.match(/^post(.+)$/)) && try_to_classify(md[1])
      end

      def try_to_classify(name)
        ('fake::' << name).camelize.constantize
      rescue NameError
        false
      end

      def comment
        RandomComment.generate
      end
    end

    def make_post_and_comments
      make_post
      make_comments
    end

    def make_post
      @op = User.random_records(1).first
      @post = @op.posts.create!(title: @title, link: @link, body: @body)
    end

    def make_comments(min: 0, max: @max_comments || 15)
      User.random_records(rand(min..max))
          .each_with_index
          .inject(CommentMemmo.new(@post)) do |comments, (user, i)|
        comments.add(user, text = call_text)
        next comments unless @op_reply && rand(i) < 2

        comments.add(@op, @op_reply.call(text), parent_id: comments.last.id)
      end
    end

    private

    def call_text
      @commentate&.call || self.class.send(:comment)
    end

    def random_text(lexical_unit: :sentence, mod: Faker::Lorem)
      lexical_subunit, max_subunits, max_chars = verify_unit(lexical_unit)
      random_text =
        mod.send(lexical_unit, lexical_subunit => rand(1..max_subunits))
      return random_text if random_text.length < max_chars

      random_text[0..max_chars].sub(/\s\w*$/, '')
    end

    def random_length
      rand(1..(lexical_unit == :sentence ? 20 : 6))
    end

    # Returns array of lexical sub-unit, max sub-units, & max chars. Raises
    # if inappropriate lexical unit is passed
    def verify_unit(lexical_unit)
      case lexical_unit
      when /(sentence|question)/
        [:word_count, 20, 300]
      when :paragraph
        [:sentence_count, 9, 999]
      else
        raise ArgumentError, 'The lexical_unit must be a sentance '\
          "(the default), a question or a paragraph. not `#{lexical_unit}`"
      end
    end

    def image_link(*args)
      Faker::LoremFlickr.image(search_terms: args)
    end
  end

  # Wraps around Array containing messages. Passed as memmo in Enumerable#inject
  class CommentMemmo
    def initialize(post)
      @post = post
      @array = []
    end

    def method_missing(*args, &block)
      @array.respond_to?(args.first) ? @array.send(*args, &block) : super
    end

    def respond_to_missing?(name)
      @array.respond_to?(name) || super
    end

    # Creates a comment and pushes onto array
    def add(user, text, parent_id: random_parent_id)
      @array << @post.comments.create!(user: user, text: text,
                                       parent_id: parent_id)
      self
    end

    private

    # Takes the ID of a random comment already on the post
    def random_parent_id
      sample&.id if Faker::Boolean.boolean
    end
  end
end
