# EzSecurity Thrift Definitions

## Generating the thrift code
Our build servers aren't set up to generate thrift, so we have to check it in. Run with the "gen-thrift" profile to generate the code:

    mvn generate-resources -P gen-thrift

## Generating NAR and JAR packages
Run with:

    mvn clean install
