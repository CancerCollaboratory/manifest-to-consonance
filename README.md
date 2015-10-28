# manifest-to-consonance

A tool that converts from a [DCC Portal](http://dcc.icgc.org) manifest file to Docker container runs using tool images from the [Dockstore](http://www.dockstore.org).  It can run these Docker containers locally or it can send "orders" to the [Consonance](https://github.com/Consonance/consonance) system which runs them on fleets of Cloud VMs.

A use case for this tool is to search for a subset of BAM files from the ICGC PanCancer project indexed on the DCC Portal, select those for analysis with a Docker-based analysis tool from the Dockstore, and then to run the analysis on either a commercial/private cloud or on your local machine.  In this way you can do large-scale analysis with the ICGC data files.

You can contrinbute your own Docker-based tools to the Dockstore, see http://wwww.dockstore.org for more details.

## Install

This tool supports two modes, a local mode and consonance mode. The l

### 

## Usage

    perl schedule_workflow.pl --cwl sample.cwl --manifest manifest.tsv --mode local
