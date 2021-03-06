# manifest-to-consonance

A tool that converts from a [DCC Portal](http://dcc.icgc.org) manifest file to Docker container runs using tool images from the [Dockstore](http://www.dockstore.org).  It can run these Docker containers locally or it can send "orders" to the [Consonance](https://github.com/Consonance/consonance) system which runs them on fleets of Cloud VMs.

A use case for this tool is to search for a subset of BAM files from the ICGC PanCancer project indexed on the DCC Portal, select those for analysis with a Docker-based analysis tool from the Dockstore, and then to run the analysis on either a commercial/private cloud or on your local machine.  In this way you can do large-scale analysis with the ICGC data files.

You can contrinbute your own Docker-based tools to the Dockstore, see http://www.dockstore.org for more details.

## Install

This tool supports two modes, a local mode and a Consonance mode. They each have their own depedencies although the following will need to be setup for any type of run:

* Perl
** `sudo cpanm install YAML::Perl`
** `sudo apt-get install libjson-pp-perl libconfig-yaml-perl libwww-perl libyaml-perl cpanminus python-pip make libcurl4-openssl-dev python-dev` and the same command above since there is no package for YAML::Perl
* Docker (on Linux) or Boot2Docker (Mac)
* Java, make sure you have Java 1.8, we have tested 1.8.0_66

### Local Mode

You need to have the:

* Jar file for the tool Launcher available from [here] (https://github.com/CancerCollaboratory/dockstore-descriptor).
  * use 1.0.4 release for the Launcher
  * build with `mvn clean install` in the `launcher` directory
  * I also checked in a copy into `lib`
* credentials for clouds like AWS depending on where your inputs or outputs are
* the `cwltool` command, see [here](https://github.com/CancerCollaboratory/dockstore-descriptor/blob/develop/README.md) for how to install in detail
  * `pip install cwl-runner`

### Consonance Mode

You need to have the:

* the consonance command line from [here](https://github.com/Consonance/consonance)
* credentials for clouds like AWS, for both inputs/outputs and also launching worker VMs

### Collaboratory/AWS Data Download Tool

The ICGC PanCancer data is located on AWS (in S3) and the Collaboratory at OICR.
A special tool is required in order to download data from these two sources.
You need to download the following to the deps directory.

    wget -O deps/dcc-storage-client-0.0.43-dist.tar.gz https://seqwaremaven.oicr.on.ca/artifactory/simple/dcc-release/org/icgc/dcc/dcc-storage-client/0.0.43/dcc-storage-client-0.0.43-dist.tar.gz

And then unzip it.You will also fill in the config file for this tool in `deps/dcc-storage-client-0.0.43/conf/application-amazon.properties`, make sure you fill
in your token:

```
logging.level.org.icgc.dcc.storage.client=DEBUG
logging.level.org.springframework.web.client.RestTemplate=DEBUG
client.upload.serviceHostname=storage.cancercollaboratory.org
client.ssl.trustStore=classpath:client.jks
accessToken=<your token here>
```

You then should update the `config/launcher.ini` file, correct the path below for your system:

    [dcc_storage]
    client=<path>/deps/dcc-storage-client-0.0.43/bin/dcc-storage-client


## Data Location

* pulling data from S3 requires this tool to run in an AWS VM in Virginia
* pulling data from Collaboratory requires this tool to run in th Collaboratory OpenStack at OICR

## Usage

### Note About Shells

The perl script will execute the various commands in a shell started with `bash -l -c '<command>'` .
This means you need to have the following defined in your `~/.bash_profile` file:

```
export JAVA_HOME=<path to JDK 1.8>
export AWS_ACCESS_KEY=<your key>
export AWS_SECRET_KEY=<your secret key>
```

### Local

The tool is called `collab` since it's for the Collaboratory project.

This will run the BAMStats tool on a collection of BAM files available

    perl collab --container-id quay.io/briandoconnor/dockstore-tool-bamstats --manifest manifest.tsv --mode local

### Consonance

    perl collab --container-id quay.io/briandoconnor/dockstore-tool-bamstats --manifest manifest.tsv --mode consonance

## TODO

* the URL for the dockstore server is hard-coded
* the downloads are hard-coded to use a 1000 genomes BAM, need to switch to either S3 or Collaboratory-based BAMs
* the uploads go to an OICR bucket in S3, need to also support (show an example of) upload to Swift provided by Collaboratory
