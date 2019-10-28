module Fake
  # Links random doge pic with dog-related meme as title. Limits comments
  # because they aren't domain specific
  class Doggos < PostMaker
    def initialize
      @title = Faker::Creature::Dog.meme_phrase
      @link = image_link('dog')
      @max_comments = 7
    end
  end

  # Links random cat pic and constructs possessive cat title. Limits comments
  # because they aren't domain specific
  class Cats < PostMaker
    def initialize
      cat = Faker::Creature::Cat
      @title = "#{cat.name}, my #{cat.breed.sub(/\w+, or /, '')}"
      @link = image_link('cat')
      @max_comments = 7
    end
  end

  # Generates quote & attributes it to a random philosopher with link to their
  # wiki page. Limits comments because they aren't domain specific
  class Philosophy < PostMaker
    def initialize
      philosophers = Faker::GreekPhilosophers
      name = philosophers.name
      @title = "#{name} - #{philosophers.quote}"
      @link = "https://en.wikipedia.org/wiki/#{name}"
      @max_comments = 7
    end
  end

  # Title, body and comments are random strings of hipster words. Bodies are
  # long. Limits comments because they aren't domain specific
  class AskHipster < PostMaker
    def initialize
      hipster = Faker::Hipster
      @title = random_text(mod: hipster)
      @body = random_text(lexical_unit: :paragraph, mod: hipster)
      @commentate = -> { random_text(lexical_unit: :paragraph, mod: hipster) }
      @max_comments = 7
    end
  end

  # Uses lorem ipsum for title, body and comments. Limits comments because
  # they aren't domain specific
  class AskRediditInLatin < PostMaker
    def initialize
      @title = random_text(lexical_unit: :question)
      @body = random_text(lexical_unit: :paragraph)
      @commentate = -> { random_text(lexical_unit: :paragraph) }
      @op_reply = ->(_p) { 'Ego dissentio' }
      @max_comments = 7
    end
  end

  # Asks for help with some techno-babble. Replies suggest something (also
  # babble), and if the OP replies, they say they tried it already
  class HackerHelp < PostMaker
    def initialize
      hacker = Faker::Hacker
      @title = "How do I #{hacker.verb} the #{hacker.adjective} #{hacker.noun}?"
      @body = 'Sorry for the noob question.'
      @commentate = -> { hacker.say_something_smart }
      @op_reply = lambda do |parent|
        "I tried that, but my #{parent.slice(/\w+(?=\!$)/)} "\
          "isn't #{hacker.ingverb}"
      end
    end
  end

  # Makes dubious medical claim about a weed strain. Comments make counterclaim.
  # OP may reply dismissively because he's baked
  class Trees < PostMaker
    ENTISH = %w[Dude Woah Bro Dank Totally 420].freeze
    def initialize
      @title = cannabis_claim
      @body = entish
      @commentate = -> { "#{entish}. #{cannabis_claim} though." }
      @op_reply =
        ->(_p) { "#{entish}, I'm at like a #{rand(4..10)} right now..." }
    end

    def cannabis_claim
      Faker::Cannabis.strain + ' ' + Faker::Cannabis.health_benefit
    end

    private

    def entish
      ENTISH.sample
    end
  end

  # Announces release of tech from Silicon Valley; links to a site made for show
  class Technology < PostMaker
    def initialize
      silly_valley = Faker::TvShows::SiliconValley
      @title = "#{silly_valley.company} releases #{silly_valley.app}"
      @link = silly_valley.url
      @body = silly_valley.motto
      @commentate = -> { silly_valley.quote }
    end
  end

  # OP and commenters give random personal details. OP may PM them ;)
  class Dating < PostMaker
    def initialize
      @title = personal_spec
      @body = 'No smokers please'
      @commentate = -> { personal_spec(signoff: '... interested?') }
      @op_reply = ->(_p) { 'PM me' }
    end

    def personal_spec(signoff: 'looking for love')
      demo = Faker::Demographic
      [
        demo.marital_status.downcase,
        "#{demo.race.sub(/ or .*/, '').downcase} #{demo.sex.downcase}",
        "with #{demo.educational_attainment.downcase.sub(/ or .*/, '')
                    .sub('Grade', 'grades')}",
        signoff
      ].inject(demo.height(unit: :imperial)) { |spec, part| "#{spec}, #{part}" }
    end
  end

  # Picks a random quote from a movie or TV show
  class RandomComment
    class << self
      TV = Faker::TvShows
      MOVIES = Faker::Movies

      def generate
        send(protected_methods(false).sample)
      end

      protected

      def hitchikers_guide
        MOVIES::HitchhikersGuideToTheGalaxy.quote
      end

      def marvin
        MOVIES::HitchhikersGuideToTheGalaxy.marvin_quote
      end

      def michael_scott
        TV::MichaelScott.quote
      end

      def princess_bride
        MOVIES::PrincessBride.quote
      end

      def rick_and_morty
        TV::RickAndMorty.quote
      end

      def seinfeld
        TV::Seinfeld.quote
      end
    end
  end
end
