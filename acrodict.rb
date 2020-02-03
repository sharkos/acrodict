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

DATAFILE="./tusa.yml"

module Dictfile
  require 'yaml/store'

  # Makes a sample dictionary file and saves it to a file, and returns the hash back to the program.
  # This method requires a single parameter:
  #   'dictfile' is the output filename to pass to save_data
  #
  def Dictfile::make_datafile(dictfile)
    datahash = { 'new' =>
                     { 'tbd' => ['To be done.','Tusa be Da-man'],
                       'fyi' => ['For your information', 'forget your insane']
                     },
                 'verified' =>
                     { 'CYA' => ['Cover yer Arse'],
                       'FBI' => ['Federal Bureau of Investigation', 'Fortune be Illin']
                     }
               }
    Dictfile::save_data(dictfile, datahash)
    return datahash
  end


  # Load the YAML Dictionary from file and return it as a Ruby Hash class object
  # This method requires one parameter:
  #   'dictfile' is the input filename
  #
  def Dictfile::load_data(dictfile)
    if File.exist?(dictfile)
      data = File.open(dictfile)  { |yf| YAML::load( yf ) }
      # => Ensure loaded data is a hash. ie: YAML load was OK
      if data.class != Hash
        raise "ERROR: Dictionary file uses asn invalid format or a parsing error occurred."
      end
    else
      data = Dictfile::make_datafile(dictfile)
    end
    return data
  end

  # Save the Ruby Hash into the YAML Dictionary File
  # This method requires two parameters:
  #   'dictfile' is the output filename
  #   'datahash' is the a valid Ruby Hash class object
  #
  def Dictfile::save_data(dictfile, datahash)
    f = File.open(dictfile, "w")
    f.puts YAML::dump(datahash)
    f.close
  end
end


class Acronym

  def initialize
    @mydata = Dictfile::load_data(DATAFILE)
  end

  # Find a value in the Dictionary by specifying the tagname and keyname,
  # returns the values as an Array or NIL if not found
  # This method requires two parameters:
  #   'tagname' is the category or first level in the hash
  #   'keyname' is the acronym key
  def find_bykey(tagname,keyname)
    if @mydata[tagname].has_key?(keyname)
      return @mydata[tagname].fetch(keyname)
    else
      return nil
    end
  end

  # Adds a value to the Dictionary by specifying the tagname, keyname, and definition.
  # This method requires three parameters:
  #   'tagname' is the category or first level in the hash
  #   'keyname' is the acronym key
  #   'definition'   is the definition
  def add(tagname, keyname, definition)
    # See if the acronym already exists
    if @mydata[tagname].has_key?(keyname)
      original = @mydata[tagname].fetch(keyname)
      # Check for duplicate, skip if found
      if original.include?(definition)
        #puts "DUPLICATE - SKIPPING"
        return nil
      end
      definition = original.push(definition)
    else
      definition = Array.new.push(definition)
    end
    @mydata[tagname].store(keyname, definition)
    Dictfile::save_data(DATAFILE,@mydata)
  end

end


### MAIN PROGRAM EXECUTION FOR TESTING ###

ac = Acronym.new
puts ac.find_bykey("new","tbd")
ac.add("new","SNAFU","Situation Normal all Fd Up")
ac.add("new","SNAFU","Situation Normal all Fracked Up")

puts ac.find_bykey("new","SNAFU")
