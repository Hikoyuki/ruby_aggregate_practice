require 'json'

class KindUserAggregator
  attr_accessor :channel_names

  def initialize(channel_names)
    @channel_names = channel_names
  end

  # 実装してください
  def exec
    slack_data = channel_names.map do |channel|
      data = load(channel)
    end

    message_data = slack_data.map do |data|
      message = data['messages']
      message.map do |ms|
        ms.select {|k,v| k == 'reactions' }
      end.flatten
    end.flatten

    mssage_reaction = message_data.delete_if {|md| md == {} }

    mssage_reaction_data = mssage_reaction.map do |mr|
      {
        user_id: mr['reactions'][0]['users'],
        reaction_count: mr['reactions'][0]['count']
      }
    end

    mssage_reaction_data.max_by(3) { |k| k[:reaction_count] }
  end

  def load(channel_name)
    dir = File.expand_path("../data/#{channel_name}", File.dirname(__FILE__))
    file = File.open(dir)
    JSON.load(file)
  end
end
