require 'time'
require 'tzinfo'

class Timer
  include DataMapper::Resource

  property :id, Serial
  property :duration, Integer
  property :created_at, Time
  property :offset, String, :default => '0'
  property :type, Discriminator

  belongs_to :session

  validates_present :duration, :session_id

  before :valid? do
    self.created_at = Time.now.utc if new?
  end

  def self.label
    name.gsub(/([a-z])([A-Z])/,'\1 \2')
  end

  def self.nick
    label.split(/\s/).first.downcase
  end

  def self.recent
    all(:order => [:created_at.desc], :limit => 8)
  end

  def created_at
    zone.local_to_utc(attribute_get(:created_at))
  end

  def created_today?
    created_at.day == Time.now.utc.day
  end

  def display_time
    time = if created_today?
      created_at.strftime('%l:%M%p')
    else
      created_at.strftime('%l:%M%p on %m/%d')
    end
    time.gsub!(/^\s+/,'')
    offset == '0' ? time.gsub!(/(AM|PM)/,'\1 UTC') : time
  end

  def expiry
    created_at + duration
  end

  def expired?
    expiry.to_i < now.to_i
  end

  def label
    self.class.label
  end

  def offset=(offset)
    attribute_set(:offset, offset.to_i.to_s.gsub(/^([1-9][0-2]?)$/,'+\1'))
  end

  def to_js
    a = expiry.to_a[0..5].reverse
    a[1] = a[1] - 1 # JavaScript wants months to be 0 based
    a
  end

  def zone
    TZInfo::Timezone.get(offset ? "Etc/GMT#{offset}" : 'UTC')
  end

  private

  def now
    zone.local_to_utc(Time.now.utc)
  end
end

