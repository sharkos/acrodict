#!/usr/bin/env ruby
##
# = AcroDict
#
# ----------------------------------------------------
# AcroDict :: Acronym Dictionary
# file: libdict.rb
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

DATAFILE="./dictfile.yaml"

##
# Dictfile module handles the I/O to a dictionary database file on the filesystem
#
# AcroDict uses yaml/store to reference objects. The contents of the file are
# retrieved from disk and stored in nemory as a Ruby::Hash object.
#
module Dictfile
  require 'yaml/store'

  ##
  # Makes a sample dictionary file and saves it to a file, and returns the hash back to the program.
  # This method requires a single parameter:
  # * 'dictfile' is the output filename to pass to save_data
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


  ##
  # Load the YAML Dictionary from file and return it as a Ruby Hash class object
  # This method requires one parameter:
  # * 'dictfile' is the input filename
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

  ##
  # Save the Ruby Hash into the YAML Dictionary File
  # This method requires two parameters:
  # * 'dictfile' is the output filename
  # * 'datahash' is the a valid Ruby Hash class object
  #
  def Dictfile::save_data(dictfile, datahash)
    f = File.open(dictfile, "w")
    f.puts YAML::dump(datahash)
    f.close
  end
end


##
# Acronym class handles the methods for creating, reading, updating and deleting
# items from the Dictionary stored in Memory and commiting it back to disk.
class Acronym

  ##
  # The dictionary is loaded when calling .new
  def initialize
    @mydata = Dictfile::load_data(DATAFILE)
  end

  ##
  # Adds a value to the Dictionary by specifying the tagname, keyname, and definition.
  # This method requires three parameters:
  # * 'tagname' is the category or first level in the hash
  # * 'keyname' is the acronym key
  # * 'definition'   is the definition
  def add(tagname, keyname, definition)
    # See if the tag exists yet, if not create it and add then return
    if @mydata[tagname].nil?
      puts "Tag '#{tagname}' not found, trying to add"
      h = { keyname => Array.new.push(definition)}
      @mydata.store(tagname, h)
#      puts "Storing #{keyname} = #{definition} to #{tagname}"
#      @mydata.store[tagname](keyname, Array.new.push(definition))
      Dictfile::save_data(DATAFILE,@mydata)
      return true
    end

    # See if the acronym already exists
    if @mydata[tagname].has_key?(keyname)
      item = @mydata[tagname].fetch(keyname)
      # Check for duplicate, skip if found
      if item.include?(definition)
        return nil
      end
      # Push the new definition onto the end of array record.
      definition = item.push(definition)
    else
      # Create a new array and push definition.
      definition = Array.new.push(definition)
    end
    # Store the updated array to the hash then save it to the Dictfile
    @mydata[tagname].store(keyname, definition)
    Dictfile::save_data(DATAFILE,@mydata)
    return true
  end


  ##
  # Delete a value from the Dictionary by specifying the tagname, keyname, and array index.
  # This method requires three parameters:
  # * 'tagname' is the category or first level in the hash
  # * 'keyname' is the acronym key
  # * 'aindex'  is the array index of the specific entry.
  # *Note* : specifying aindex of -1 will delete the entire record
  #
  # If the array becomes empty, the keyname will be removed from the tag.
  #
  def del(tagname, keyname, aindex)
    # See if the acronym already exists
    if @mydata[tagname].has_key?(keyname)
     item = @mydata[tagname].fetch(keyname)
    else
      return nil # Entry does not exist, so do nothing and return nil
    end
      unless item.at(aindex).nil?
        item.delete_at(aindex)
      end
    # If we have removed all definitions or specified -1 as the index,
    # delete the acronym record from the tag
    if item.at(0).nil? or aindex == -1
      @mydata[tagname].delete(keyname)
    else
      # otherwise, write the updated item to the tag
      @mydata[tagname].store(keyname, item)
    end
    Dictfile::save_data(DATAFILE,@mydata)
    return true
  end


  ##
  # Return a list of Tags
  def tags
    return @mydata.keys
  end


  ##
  # Return an array of Acronyms by tagname
  # This method requires one parameter:
  # * 'tagname' is the category or first level in the hash
  def list_bytag(tagname)
    unless @mydata[tagname].nil?
      return @mydata[tagname].keys
    end
  end

  ##
  # Return an array of definitions by tagname
  # This method requires two parameters:
  # * 'tagname' is the category or first level in the hash
  # *  'keyname' is the acronym key
  def getdef(tagname, keyname)
    return @mydata[tagname].fetch(keyname)
  end


  ##
  # Find a value in the Dictionary by specifying the tagname and keyname,
  # returns the values as an Array or NIL if not found
  # This method requires two parameters:
  # * 'tagname' is the category or first level in the hash
  # * 'keyname' is the acronym key
  #
  def find_key_bytag(tagname,keyname)
    if @mydata[tagname].has_key?(keyname)
      return @mydata[tagname].fetch(keyname)
    else
      return nil
    end
  end

  ##
  # Find a value in the Dictionary in all tags by keyname,
  # returns the values as an map with the tagname as the 
  # key and values as an array    or NIL if not found.
  # This method requires one parameters:
  # * 'keyname' is the acronym key
  #
  def find_key(keyname)
    result = {}
    taglist = self.tags
    taglist.each do |t|
      r = self.find_key_bytag(t, keyname)
      result.store(t,r)
    end
    return result
  end


end


### MAIN PROGRAM EXECUTION FOR USAGE EXAMPLES ###

# ac = Acronym.new
# puts ac.find_bykey("new","tbd")
# ac.add("new","SNAFU","Situation Normal all Fd Up")
# ac.add("new","SNAFU","Situation Normal all Fracked Up")
# puts ac.find_bykey("new","SNAFU")
