#!/usr/bin/env ruby

require 'rexml/document'
require 'rexml/xpath'

feed = File.read("./feed.xml")
doc = REXML::Document.new(feed)

REXML::XPath.match(doc, "rss/channel/item").each do |episode|
  title = episode.elements["title"].text

  # ignore special episodes and FGAGs
  next unless title.match(/^GAG[0-9]+/)

  # remove references to books which often contain years
  description = episode.elements["description"].text
  lines = description.lines.take_while { |l| !l.match(/^\/\/Literatur/) }
  lines = lines.filter { |l| !l.match(/erwähnt/i) }

  puts "---#{title}---"
  puts lines.join
end
