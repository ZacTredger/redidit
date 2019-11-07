require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = User.new(attributes_for(:user))
  end

  test 'user is valid' do
    assert @user.valid?
  end

  test 'user without username is invalid' do
    @user.username = ''
    assert @user.invalid?
  end

  test 'usernames containing disallowed characters are rejected' do
    %W[\s \n + . ? ! &].each do |bad_char|
      @user.username.insert(9, bad_char)
      assert @user.invalid?, "Disallowed character `#{bad_char}` accepted in "\
      "username `#{@user.username}`"
    end
  end

  test 'user without email is invalid' do
    @user.email = ' '
    assert @user.invalid?
  end

  test 'users with improperly formed emails are invalid' do
    INVALID_EMAILS = %w[ex@ample exam.ple example ex@am...ple @am.ple ex@mp.
                        ex@am+p.le].freeze
    INVALID_EMAILS.each do |invalid_email|
      @user.email = invalid_email
      assert @user.invalid?, "Invalid email `#{invalid_email}` accepted"
    end
  end

  test 'users with properly formed emails are valid' do
    VALID_EMAILS = %w[ex@am.ple ex+a@mp.le ex@am.p.le ex.a@mp.le].freeze
    VALID_EMAILS.each do |invalid_email|
      @user.email = invalid_email
      assert @user.valid?, "Valid email #{invalid_email} rejected"
    end
  end

  test 'email already in db is rejected' do
    assert @user.save, 'User did not save to DB'
    refute @user.dup.update(username: 'different_name')
  end

  test 'username already in db is rejected' do
    assert @user.save, 'User did not save to DB'
    refute @user.dup.update(email: 'different@email.com')
  end

  test 'email is converted to lower case when saved' do
    @user.email.upcase!
    @user.save
    setup
    assert_equal @user.email, User.last.email
  end

  test 'user without password is not valid' do
    @user.password = @user.password_confirmation = ' '
    assert @user.invalid?
  end

  test 'rejects too short password' do
    @user.password = @user.password_confirmation = 'Foobar'
    assert @user.invalid?
  end

  test 'user with non-matching password and confirmation is invalid' do
    @user.password_confirmation = 'Foobarbaz2'
    assert @user.invalid?
  end
end
