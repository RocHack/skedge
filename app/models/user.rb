require 'securerandom'

class User
  include Mongoid::Document
  field :secret, type: String
  field :bookmarks, type: Array, default: []
  embeds_many :schedules


  def generate_secret
    self.secret = SecureRandom.hex
  end	  

  def skedge_json(current_skedge=nil)
    hash = {"secret" => secret, "bookmarks" => bookmarks, "schedules" => schedules.inject({}) { |h, n| h[n["rid"]] = n; h }}
    hash["current_skedge"] = current_skedge if current_skedge
    #organize the schedules by RID so js is faster/simpler
    hash.to_json
  end
end
