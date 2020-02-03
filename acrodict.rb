# ----------------------------------------------------
# AcroDict - based on AcroBot
# Chris Tusa <chris.tusa@leafscale.com>
# v 0.1
# ----------------------------------------------------

# Quit if the program runs as 'root'.
currentuser = `whoami`
if currentuser.chomp == "root"
  puts "For security reasons, this program will not run as 'root' exiting..."
  exit 100
end

$LOAD_PATH.unshift('.')

module Acrodict
  require 'yaml/store'

  datafile = "acronym_data.yaml"

  # Makes a sample dictionary file and saves it to a file, and returns the hash back to the program.
  # This method requires a single parameter:
  #   'dictfile' is the output filename to pass to save_data
  #
  def Acrodict::make_datafile(dictfile)
    datahash = { 'new' =>
                     { 'tbd' => ['To be done.','Tusa be Da-man'],
                       'fyi' => ['For your information', 'forget your insane']
                     },
                 'verified' =>
                     { 'CYA' => ['Cover yer Arse'],
                       'FBI' => ['Federal Bureau of Investigation', 'Fortune be Illin']
                     }
               }
    Acrodict::save_data(dictfile, datahash)
    return datahash
  end


  # Load the YAML Dictionary from file and return it as a Ruby Hash class object
  # This method requires one parameter:
  #   'dictfile' is the input filename
  #
  def Acrodict::load_data(dictfile)
    if File.exist?(dictfile)
      data = File.open(dictfile)  { |yf| YAML::load( yf ) }
      # => Ensure loaded data is a hash. ie: YAML load was OK
      if data.class != Hash
        raise "ERROR: Dictionary file uses asn invalid format or a parsing error occurred."
      end
    else
      data = Acrodict::make_datafile(dictfile)
    end
    return data
  end

  # Save the Ruby Hash into the YAML Dictionary File
  # This method requires two parameters:
  #   'dictfile' is the output filename
  #   'datahash' is the a valid Ruby Hash class object
  #
  def Acrodict::save_data(dictfile, datahash)
    f = File.open(dictfile, "w")
    f.puts YAML::dump(datahash)
    f.close
  end
end


# Find a value in the Dictionary by specifying the tagname and keyname,
# returns the values as an Array or NIL if not found
# This method requires two parameters:
#   'tagname' is the category or first level in the hash
#   'keyname' is the acronym key
def find_bykey(tagname,keyname)
  mydata = Acrodict::load_data('./tusa.yml')
  if mydata[tagname].has_key?(keyname)
    return mydata[tagname].fetch(keyname)
  else
    return nil
  end
end

### MAIN PROGRAM EXECUTION FOR TESTING ###

puts "Loading Data from file (tusa.yml)"
mydata = Acrodict::load_data('./tusa.yml')
puts "---[ Data File Info ] ----------------------------------------"
puts "Data Class = #{mydata.class}"
puts ""

puts "---[ Object Inspect ]-----------------------------------------"
puts mydata.inspect

puts "---[ Raw File Output ]----------------------------------------"
puts mydata.to_yaml

puts "---[ Testing Manual Search ]----------------------------------"
print "Does 'tbd' exist in 'new': "
puts mydata["new"].has_key?("tbd")
print "Does 'tbd' exist in 'verified': "
puts mydata["verified"].has_key?("tbd")

puts "---[ Testing 'find_bykey()' Search ]----------------------------------"
result = find_bykey('new','tbd')
puts result.inspect
print "Data Class = "
print result.class
