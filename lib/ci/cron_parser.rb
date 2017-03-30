module Ci
  class CronParser
    def initialize(cron, cron_time_zone = 'UTC')
      @cron = cron
      @cron_time_zone = cron_time_zone
    end

    def next_time_from_now
      cronLine = try_parse_cron(@cron, @cron_time_zone)
      return nil unless cronLine.present?
      cronLine.next_time
    end

    def validation
      VALID_SYNTAX_TIME_ZONE = 'Europe/Istanbul'
      VALID_SYNTAX_CRON = '* * * * *'
      is_valid_cron = try_parse_cron(@cron, VALID_SYNTAX_TIME_ZONE).present?
      is_valid_cron_time_zone = try_parse_cron(VALID_SYNTAX_CRON, @cron_time_zone).present?
      return is_valid_cron, is_valid_cron_time_zone
    end

    private

    def try_parse_cron(cron, cron_time_zone)
      begin
        Rufus::Scheduler.parse("#{cron} #{cron_time_zone}")
      rescue
        nil
      end
    end
  end
end
