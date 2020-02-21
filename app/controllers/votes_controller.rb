class VotesController < ApplicationController
  belongs_to  :votable, polymorphic: true
end
