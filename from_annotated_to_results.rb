#!/usr/bin/env ruby

require 'csv'
require 'rexml/document'
require 'rexml/xpath'


def prepare_text(file)
  text = File.read(file)
  text.gsub!(/<\?xml[^>]*>/, "")
  text.gsub!(/<!DOCTYPE[^>]*>/, "")
  text.gsub!(/<\/?TimeML[^>]*>/, "")
  text.gsub!(/&/, "&amp;")
  text
end

$unhandled_timex = []

def parse_timex(elem)
  # ignore most relative timexes, especially month names
  # which are often false positives and/or badly dereferenced
  return [] unless elem.text.match?(/[0-9]/)

  value = elem['value']

  is_bc = false
  if value.start_with? "BC"
    is_bc = true
    value.gsub!(/^BC/, "")
  end

  years = []
  case value
  when /^[0-9]{4}-?/  # single years or more specific
    years.push value.slice(0, 4).to_i
  when /^[0-9]{3}$/  # decades
    years.push (value.slice(0, 3) + '0').to_i
    years.push (value.slice(0, 3) + '9').to_i
  when /^[0-9]{2}$/  # centuries
    years.push (value.slice(0, 2) + '00').to_i
    years.push (value.slice(0, 2) + '99').to_i
  when /(PRESENT_REF|FUTURE_REF)/
  else
    $unhandled_timex.push(value)
  end

  years.map { |year| is_bc ? year * -1 : year }
end

def parse_timexinterval(elem)
  results = [
    ((elem['earliestBegin'].to_i + elem['latestBegin'].to_i )/ 2).to_i,
    ((elem['earliestEnd'].to_i + elem['latestEnd'].to_i) / 2).to_i,
  ]
  results.any? {|i| !(i in -15000..2050)} ? [] : results  # exclude geological times, probably FP
end


CSV.open("results.csv", "w") do |csv|
  csv << %w[title min max center mean all_years used_expressions ignored_expressions text]

  text = prepare_text("./feed_annotated.timeml")
  text.split(/^---/).each do |section|
    title = section.lines[0].gsub(/---/, "")
    title.gsub!(/<[^>]*>/, "")

    doc = REXML::Document.new("<root>#{section}</root>")
    years = []
    used = []
    ignored = []

    REXML::XPath.match(doc, "root/TIMEX3[@type='DATE']").each do |timex|
      timex_years = parse_timex(timex)
      years += timex_years
      (timex_years.empty? ? ignored : used).push(timex.text)
    end

    if years.empty?  # Use temponyms as a backup only
      REXML::XPath.match(doc, "//TIMEX3INTERVAL[TIMEX3[@type='TEMPONYM']]").each do |elem|
        elem_years = parse_timexinterval(elem)
        years += elem_years
        (elem_years.empty? ? ignored : used).push(elem.get_elements('TIMEX3').first.text)
      end
    end

    csv << [
      title,
      years.empty? ? "" : years.min,
      years.empty? ? "" : years.max,
      years.empty? ? "" : ((years.min + years.max) / 2).to_i,
      years.empty? ? "" : (years.sum / years.size).to_i,
      years.to_s,
      used.to_s,
      ignored.to_s,
      REXML::XPath.match(doc, './/text()').join
    ]
  end
end

if $unhandled_timex.size > 0
  puts "Warning unhandled timex values: #{$unhandled_timex.uniq.join(',')}"
end
