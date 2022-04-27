require 'json'

class HighMotivationUserAggregator
  attr_accessor :channel_names

  def initialize(channel_names)
    @channel_names = channel_names
  end

  # 実装してください
  def exec
    best_channel = []
    channel_names.each.with_index(1) do |channel, i|
      slack_data = load(channel)
      tmp_hash = { channel: channel, message_count: slack_data['messages'].size}
      best_channel << tmp_hash
    end
    # メッセージ数の降順で並び替え
    best_channel.sort_by!{ |k| -k[:message_count] }
    # 上位3つを取得
    best_channel.slice(0, 3)
  end

  def load(channel_name)
    dir = File.expand_path("../data/#{channel_name}", File.dirname(__FILE__))
    file = File.open(dir)
    JSON.load(file)
  end
end
