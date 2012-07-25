Instructions on setting up a local ITIS database:

1. Download the latest copy of the "MySQL by table" ITIS database 
   from http://www.itis.gov/downloads/index.html.
2. Use dwca-hunter (see https://github.com/GlobalNamesArchitecture/dwca-hunter) 
   to convert this into a DwC-A file. Right now, this will require
   fiddling with the dwca-hunter source code so that it outputs only
   the ITIS output.
3. Unzip the resulting dwca.tar.gz, and rename 'taxa.txt' as 'names.csv'.
   Move 'names.csv' into this directory.
4. Run either itis.pl or `perl tests.t`; the first time this is run, it
   will generate an SQLite database named 'names.sqlite3' from 'names.csv'.
5. Once the 'names.sqlite3' file is generated, run `prove tests.t` or
   `perl tests.t` to put this code through its paces.
