class PopularMessageAggregator
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
        next if ms.select {|k,v| k == 'reactions' } == {}
        {
          text: ms['text'],
          reaction_count: ms['reactions'][0]['count']
        }
      end.flatten
    end.flatten

    mssage_reaction = message_data.delete_if {|md| md == nil }

    mssage_reaction.max_by(1){|k| k[:reaction_count]}
  end

  def load(channel_name)
    dir = File.expand_path("../data/#{channel_name}", File.dirname(__FILE__))
    file = File.open(dir)
    JSON.load(file)
  end
end
