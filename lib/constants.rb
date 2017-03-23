module Constants
  TODAY = ENV.key?('FIXED_DATE') ? Date.parse(ENV['FIXED_DATE']) : Date.today
  MIT_DATE_REGEX = /\{(\d{4}\.\d{2}\.\d{2})\}/
  VERSION = 'v1.0.2'.freeze
end
