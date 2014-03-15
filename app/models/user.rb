require 'securerandom'

class User
  include Mongoid::Document
  field :secret, type: String
  embeds_many :schedules

  def generate_secret
    self.secret = SecureRandom.hex
  end	  

  def skedge_json(current_skedge=nil)
    hash = self.attributes
    hash["current_skedge"] = current_skedge if current_skedge
    #organize the schedules by RID so js is faster/simpler
    hash["schedules"] = hash["schedules"].inject({}) { |h, n| h[n["rid"]] = n; h } if hash["schedules"]
    hash.to_json
  end
end
