require 'test_helper'
%w[post_maker redidits].each { |f| require_relative "../../db/#{f}.rb" }

class FakeHelpersTest < ActionDispatch::IntegrationTest
  test 'by default, Fake creates random dates within default range' do
    assert_with_extreme_seeds do
      assert Fake.creation_date.between?(3.months.ago, 1.hour.ago),
             'produces date outside default range'
    end
  end

  test 'Fake creates random dates within suplied range' do
    time_units = %i[seconds minutes hours days weeks months years]
    assert_with_extreme_seeds do
      time_units.each do |time_unit|
        from = 2.send(time_unit).ago
        to = 1.send(time_unit).ago
        assert Fake.creation_date(from: from, to: to).between?(from, to),
               'produces date outside supplied range'
      end
    end
  end

  test 'Fake creates dates after the creation dates of all given records' do
    records = User.take(3) + Post.take(3)
    hour_ago = 1.hour.ago
    assert_with_extreme_seeds do
      generated_date = Fake.creation_date_after(*records)
      records.each do |record|
        assert_operator generated_date, :>=, record.created_at,
                        "#{generated_date} is before #{record.created_at}"
        assert_operator generated_date, :<=, hour_ago,
                        "#{generated_date} is after #{hour_ago}"
      end
    end
  end

  private

  # Seeds rand with numbers known to produce results at the beginning and end,
  # respectively, of whatever range is given to rand.
  def assert_with_extreme_seeds(&block)
    [98204483234904284074684844911259531319,
      328263832952336006694516452247578800771].each do |seed|
        srand seed
        block.call
      end
  end
end
