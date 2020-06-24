# AcroDict

AcroDict is a rewrite of AcroBot, an IRC Bot for reading and storing Acronym definitions. This version separates the data layer from the presentation layer, and makes better use of YAML syntax such as "Array" types for being able to have duplicate entries across the entire dataset. The api used in this code makes it possible to add additional data backends in the future, such as using an SQL, JSON, or other datasource by expanding or overriding the Acronym class model. 

## Getting Started

Clone the repository, edit 'acrodict.conf' to suit your needs. It is a YAML formatted file. Then run 
```
ruby acrodict.rb
```

Check your IRC channel and issue 
```
!help
```

You can get a list of tags by asking the bot:
```
!@tags
```

Query a tag for a list of keys:
```
!@tagname
```

Query the entire dataset for a key:
```
!keyname
```

Add a new item to the dataset:
```
!keyname=Some Description @tagname
```



### Prerequisites

Ruby >= 2.5

Only the *cinch* gem is required.  You can install it by hand or run **bundler**
```
gem install cinch
```

### Sample Data

```yaml
---
tag1:
  keya:
  - value1-keya-tag1
  - value2-keya-tag1
  keyb:
  - value1-keyb-tag1
  - value2-keyb-tag1
tag2:
  keya:
  - value1-keya-tag2
  - value2-keya-tag2
  keyb:
  - value1-keyb-tag2
  - value2-keyb-tag2
new:
  fyi:
  - For your information
  - forget your insane
  bork:
  - Bad Old Rolling Kart
  knob:
  - Killer Not On Board
verified:
  bork:
  - Broken On Read Keyboard
```


## Built With

* Ruby
* cinch


## Authors

* **Chris Tusa** 
* **David O'Brien**

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* AcroBot code and original authors for inspiration.