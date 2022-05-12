require 'json'

class KindUserAggregator
  attr_accessor :channel_names

  def initialize(channel_names)
    @channel_names = channel_names
  end

  # 実装してください
  def exec
    slack_data = channel_names.map do |channel|
      load(channel)
    end

    message_data = slack_data.flat_map do |data|
      message = data['messages']
      message_reaction = message.flat_map do |ms|
        ms['reactions']
      end
      message_reaction = message_reaction.delete_if {|md| md == nil }
      message_reaction.flat_map do |mr|
        mr['users']
      end
    end

    sum_user = message_data.group_by(&:itself).map{|k, v| [k, v.size]}.to_h
    message_reaction_data = sum_user.map do |sm|
      {
        user_id: sm.first,
        reaction_count: sm.last
      }
    end

    message_reaction_data.max_by(3) { |k| k[:reaction_count] }
  end

  def load(channel_name)
    dir = File.expand_path("../data/#{channel_name}", File.dirname(__FILE__))
    file = File.open(dir)
    JSON.load(file)
  end
end
