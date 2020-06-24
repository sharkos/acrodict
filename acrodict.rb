#!/usr/bin/env ruby
##
# = AcroDict
#
# ----------------------------------------------------
# AcroDict :: Acronym Dictionary
# file: acrodict.rb
# Chris Tusa <chris.tusa@leafscale.com>
# v 0.1
# ---
#

# Quit if the program runs as 'root'.
currentuser = `whoami`
if currentuser.chomp == "root"
  puts "For security reasons, this program will not run as 'root' exiting..."
  exit 100
end


$LOAD_PATH.unshift('.')

require 'cinch'
require 'libdict.rb'
require 'yaml'


# Load the configuration from then config file (yaml)
def load_settings
  home_dir = File.expand_path '~/.config'
  install_dir = File.expand_path File.dirname(__FILE__)
  cfg_file = 'acrodict.conf'
  return YAML::load_file("#{home_dir}/#{cfg_file}") if File.exists? "#{home_dir}/#{cfg_file}"
  return YAML::load_file("#{install_dir}/#{cfg_file}")
end

# Start the Chat Bot using Cinch
bot = Cinch::Bot.new do
    # Load program configuration as 'settings'
    settings = load_settings
!
    # Create an instance of the Acronym dictionary as 'db'
    db = Acronym.new

    # Configure the IRC client based on the config file
    configure do |c|
     c.nick = settings['nick']         # "acrobot"
     c.realname = settings['realname'] # "IRC Acronym and Abbreviation Expander Bot. '!help' for help"
     c.user = settings['user']         # "acrobot" (user name when connecting)
     c.server = settings['server']     # "irc.freenode.net"
     c.channels = settings['channels'] # ["#openshift","#satellite6","#zanata","#theforeman","#ansible"]
     c.prefix = settings['prefix']     # /^!/
     c.sasl.username = settings['sasl_username'] unless settings['sasl_username'].nil?
     c.sasl.password = ENV['SASL_PASSWORD'] unless ENV['SASL_PASSWORD'].nil?
    end
  
    ## Add an Acronym
    on :message, /^!([\w\-\_\+\&\/]+)\=(.+)/ do |m, abbrev, meaning|
      nick = m.channel? ? m.user.nick+": " : ""
      # Extract the TAG and Description from the message
      tag  = meaning.split('@')[1].downcase
      desc = meaning.split('@')[0]
      # If the user did not specify the tag, add it the the "new" category
      if tag.nil?
        tag = 'new'
      end  
      db.add(tag,abbrev,desc)
      nick = m.channel? ? m.user.nick+"":""
      m.reply("#{nick} Thanks! [#{abbrev}=#{desc}] added to @#{tag}")
    end
  !

    ## Get Help
    on :message, /^!help/i do |m|
      nick = m.channel? ? m.user.nick+": " : ""
      m.reply("To expand an acronym, type (e.g.), !ftp")
      m.reply("To add a new acronym, type (e.g.), !FTP=File Transfer Protocol")
      m.reply("To associate a tag with an acronym, type (e.g.), !IP=Internet Protocol @networking")
      m.reply("To list abbreviations associated with a tag, type eg. !@kernel")
      m.reply("To list all tags, type !@tags")
      m.reply("AcroBot uses initcaps for expansions by default. Your own style guides may vary.")
    end


    ## Search tags
    on :message, /^!@([\w\-\_\+\&\/]+)$/ do |m, tag|
        tag = tag.strip
        if tag == "tags"  # List all tags
            output = String.new
            nick = m.channel? ? m.user.nick+": " : ""
            m.reply("Avaiable tags: ")
            db.tags.each do |t|
              output = t + ", " + output
            end
            m.reply("#{output}") 
        elsif tag == "refreshdb"  # Refresh the db
            db.refreshdata
            m.reply("Refreshed database")    
        else # return tag
            match_abbrevs = db.list_bytag(tag)
            nick = m.channel? ? m.user.nick+": " : ""
            if match_abbrevs.nil?
                m.reply("#{nick} Sorry, no such tag. To list all tags, type !@tags")
            else
                m.reply("#{nick}#{match_abbrevs.join(', ')}")
            end
        end
    end
  

    ## Definition Lookup
    on :message, /^!([\w\-\_\+\&\/]+)$/ do |m, item|
      item = item.strip
      reply_str = String.new
      unless item =~ /^help$/i or item =~ /^!@tags/i 
        nick_str = m.channel? ? "#{m.user.nick}:" : ""        
        reply_str.concat(nick_str)
        result = db.find_key(item)

        # iterate over the results from multiple tags
        result.each do |k,v|
            # Fix github issue#1 "Remove empty set response from output in the channel"
            unless v.nil?
              reply_str.concat("@", Cinch::Formatting.format(:bold, k), " : ",Cinch::Formatting.format(:bold, v.to_s), "\n")
            end
        end
         m.reply(reply_str)          
      end
    end
 

  end #/bot do
  
bot.start