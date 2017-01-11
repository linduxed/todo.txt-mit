module Constants
  TODAY = ENV.key?('FIXED_DATE') ? Date.parse(ENV['FIXED_DATE']) : Date.today
  MIT_DATE_REGEX = /\{(\d{4}\.\d{2}\.\d{2})\}/
  VERSION = 'v0.2.0'.freeze
end
