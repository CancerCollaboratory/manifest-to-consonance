# manifest-to-consonance

A tool that converts from a [DCC Portal](http://dcc.icgc.org) manifest file to Docker container runs using tool images from the [Dockstore](http://www.dockstore.org).  It can run these Docker containers locally or it can send "orders" to the [Consonance](https://github.com/Consonance/consonance) system which runs them on fleets of Cloud VMs.

A use case for this tool is to search for a subset of BAM files from the ICGC PanCancer project indexed on the DCC Portal, select those for analysis with a Docker-based analysis tool from the Dockstore, and then to run the analysis on either a commercial/private cloud or on your local machine.  In this way you can do large-scale analysis with the ICGC data files.

You can contrinbute your own Docker-based tools to the Dockstore, see http://www.dockstore.org for more details.

## Install

This tool supports two modes, a local mode and a Consonance mode. They each have their own depedencies although the following will need to be setup for any type of run:

* Perl
** `sudo cpanm install YAML::Perl`
* Docker (on Linux) or Boot2Docker (Mac)

### Local Mode

You need to have the:

* Jar file for the tool Launcher available from [here] (https://github.com/CancerCollaboratory/dockstore-descriptor).
* credentials for clouds like AWS depending on where your inputs or outputs are

### Consonance Mode

You need to have the:

* the consonance command line from [here](https://github.com/Consonance/consonance)
* credentials for clouds like AWS, for both inputs/outputs and also launching worker VMs

## Data Location

* pulling data from S3 requires this tool to run in an AWS VM in Virginia
* pulling data from Collaboratory requires this tool to run in th Collaboratory OpenStack at OICR

## Usage

### Local

This will run the BAMStats tool on a collection of BAM files available

    perl schedule_workflow.pl --container-id quay.io/briandoconnor/dockstore-tool-bamstats --manifest manifest.tsv --mode local

### Consonance

    perl schedule_workflow.pl --container-id quay.io/briandoconnor/dockstore-tool-bamstats --manifest manifest.tsv --mode consonance
