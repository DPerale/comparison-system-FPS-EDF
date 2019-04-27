-----------------------------------------------------------------------
--                              Mast                                 --
--     Modeling and Analysis Suite for Real-Time Applications        --
--                                                                   --
--                       Copyright (C) 2000-2008                     --
--                 Universidad de Cantabria, SPAIN                   --
--                                                                   --
--                                                                   --
--                    URL: http://mast.unican.es/                    --
--                                                                   --
-- Authors: Michael Gonzalez       mgh@unican.es                     --
--          Jose Javier Gutierrez  gutierjj@unican.es                --
--          Jose Carlos Palencia   palencij@unican.es                --
--          Jose Maria Drake       drakej@unican.es                  --
--          Julio Medina           medinajl@unican.es                --
--          Patricia Lopez         lopezpa@unican.es                 --
--          Ola Redell                                               --
--          Yago Pereiro                                             --
--          Pilar del Rio                                            --
--                                                                   --
-- This program is free software; you can redistribute it and/or     --
-- modify it under the terms of the GNU General Public               --
-- License as published by the Free Software Foundation; either      --
-- version 2 of the License, or (at your option) any later version.  --
--                                                                   --
-- This program is distributed in the hope that it will be useful,   --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of    --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU --
-- General Public License for more details.                          --
--                                                                   --
-- You should have received a copy of the GNU General Public         --
-- License along with this program; if not, write to the             --
-- Free Software Foundation, Inc., 59 Temple Place - Suite 330,      --
-- Boston, MA 02111-1307, USA.                                       --
--                                                                   --
-----------------------------------------------------------------------

                            Version 1.3.7.8

TABLE OF CONTENTS
-----------------

   1. Analysis Tools Defined in the Mast Suite
   2. Binary Installation
   3. Source Installation   
   4. Usage of the Analysis Tools
   5. Priority Assignment Tools
   6. Support, Problems, and Questions

1. ANALYSIS TOOLS DEFINED IN THE MAST SUITE
-------------------------------------------

   Worst-case schedulability analysis:
      mast_analysis holistic
      mast_analysis offset_based
      mast_analysis offset_based_optimized
      mast_analysis classic_rm
      mast_analysis edf_monoprocessor
      mast_analysis edf_within_priorities
      mast_analysis varying_priorities
     *mast_analysis multiple_event

* Not yet available

2. BINARY INSTALLATION
----------------------

    Windows: 
      - unzip the file mast-bin-win-1-3-7-x.zip into a directory of your
        choice.
      - This causes the following files and directories to appear:
            mast_analysis.exe     : executable analysis tool
            gmast.bat             : script for invoking the graphical driver
            gmast_analysis.exe    : graphical driver for analysis tools
            gmastresults.exe      : graphical driver for viewing results
            gmasteditor.exe       : graphical editor for MAST models (alpha)
            mast_xml_convert.exe  : converter of MAST models between XML
                                    and text formats
            mast_xml_convert_results.exe : converter of MAST results between
                                           XML and text formats
            *.dll                 : dll's for gtk GUI
            docs                  : directory containing the MAST documents
            examples              : directory with examples
            README.txt            : this file
            mast-status.txt       : description of the current status
      - put the MAST directory in the PATH, so that you can access the
        tools; you may create a link (shortcut) to the gmast.bat
        script in the desktop or another comfortable place.
         
    Linux (tested on Ubuntu Draper):
      - requires a pdf reader for the documentation, and libgtk2
        (available in the Ubuntu distribution) for the GUI.
      - unzip and extract the files in mast-bin-linux-1-3-7-x.tar.gz into
        the directory of your choice:
            tar zxvf mast-bin-linux-1-3-7-x.tar.gz
      - This causes the following files to appear:
            mast_analysis         : executable tool
            gmast                 : script for invoking the graphical driver
            gmast_analysis        : graphical driver for analysis tools
            gmastresults          : graphical driver for viewing results
            gmasteditor           : graphical editor for MAST models (alpha)
            mast_xml_convert      : converter of MAST models between XML
                                    and text formats
            mast_xml_convert_results : converter of MAST results between XML
                                       and text formats
            docs                  : directory containing the MAST documents
            examples              : directory with examples
            README.txt            : this file
            mast-status.txt       : description of the current status
            lib                   : directory containing dynamic libraries
      - put the MAST directory in the PATH, so that you can access the tools
        For example, if mast is in /usr/local/mast:
            export PATH=/usr/local/mast:$PATH
      - put the MAST/lib directory in the LD_LIBRARY_PATH, so that the
        libraries can be accessed when executing the programs
        For example, if mast is in /usr/local/mast:
            export LD_LIBRARY_PATH=/usr/local/mast/lib:$LD_LIBRARY_PATH

3. SOURCE INSTALLATION
----------------------

      - Requires the gnat compiler (libre.adacore.com). We have used
        the GPL2007 version of gnat in Linux, and GAP2005 version in
        Windows.

      - Unzip and extract the source files from mast-src-1-3-7-x.tar.gz 
        or from mast-src-1-3-7-x.zip into the directory of your choice. 
        This creates the following directories and files:
            mast_analysis   : directory containing the analysis tools
            utils           : directory containing sources for common modules
            gmast           : directory containing the graphical driver
            gmastresults    : directory with the graphical results viewer
            mast_xml        : directory with the XML converters
            gmasteditor     : directory with the graphical editor (beta)
            docs            : directory containing the MAST documents
            examples        : directory containing some examples
            README.txt      : this file
            mast-status.txt : description of the current status

        A script called compile can be called to compile all the mast programs.

        Alternatively, The tools can be compiled invoking the following 
        command in the mast_analysis directory:

             gnatmake -g -gnato -I../utils mast_analysis

      - For compiling the graphical driver, the graphical results
        viewer and the graphical editor you need GtkAda (available
        from http://libre.adacore.com/GtkAda/). We have used version
        2.8.0 in Linux, and version 2.4.0 in Windows.

      - To compile in Linux, invoke the following commands in the
        gmast/src, the gmastresults/src and the gmasteditor/src
        directories, respectively:

             gnatmake -I../../mast_analysis -I../../utils gmast_analysis `gtkada-config`
             gnatmake -I../../mast_analysis -I../../utils gmastresults `gtkada-config`
             gnatmake -I../../mast_analysis -I../../utils -I../../gmast/src -I../../gmastresults/src gmastresults `gtkada-config`

        Then set the appropriate PATH, or create links to the executable
        files somewhere in your search PATH.

        To compile in Windows, use the command:

             gnatmake -Ic:/Gtkada/include/gtkada -I../../mast_analysis -I../../utils gmast_analysis 
             gnatmake -Ic:/Gtkada/include/gtkada -I../../mast_analysis -I../../utils gmastresults
             gnatmake -Ic:/Gtkada/include/gtkada -I../../mast_analysis -I../../gmast/src -I../../utils -I../../gmastresults/src gmastresults

        assuming that GtkAda is installed in directory c:\Gtkada. 
        Then, set the appropriate PATH, or move the executable program
        to a directory in the search PATH.

      - For compiling the XML conversion tools see the README.txt file
        in the mast_xml directory.

      - If you wish to add or change anything in the file format, you
        need the aflex and ayacc tools (available from the MAST Web
        page) to re-generate the mast file parser or the mast results
        parser. You can install the tools by unzipping and extracting the
        files from:
            aflex-ayacc-gnat.tar.gz
        this will create the directories
            ayacc
            aflex
        these are modified versions of ayacc and aflex with the
        following changes:
            - adapted for gnat
            - can accept input files with international characters (8
              bit characters)
        you need to compile the tools:
            - in the ayacc/src directory: gnatmake ayacc
            - in the aflex/src directory: gnatmake aflex
        and put the corresponding directories in the PATH, or create links
        to the executable files somewhere in your search PATH, or move the
        executable files to a directory that is in the PATH.

        The mast file parser description is in file
        "mast_parser.y". The lexical analyzer description for the mast
        file is in file "mast_lex.l". To regenerate the parser and the
        tools use the "generate" script.

        The parser for the results file has its description in file
        "mast_results_parser.y", and its lexical analyzer description
        in "mast_results_lex.l". To regenerate the results parser
        use the "generate_results" script.


4. USAGE OF THE ANALYSIS TOOLS
------------------------------

   graphical driver
   ----------------

      gmast

         The graphical driver displays the information about the
         tools, files and options available. After setting all the
         desired fields, pressing the "GO" button will produce a
         script, in a file named "mast_command" that invokes the
         mast_analysis tool with the appropriate arguments.

         If a results file has been defined, then it is possible to
         set the "View Results" option. In that case, after the
         analysis the graphical results viewer is invoked.

         The "Help" button in the graphical driver provides additional
         help.
         

   command format:
   ---------------

      mast_analysis -h
      mast_analysis -help 
            do not make the analysis, just print help information

      mast_analysis tool_name [options] input_file [output_file]
            execute the tool as described below.

   tool description:
   -----------------
     
      The tool parses the input file. If it finds errors it reports
      them and stops. The list of errors can be found in the file
      "mast_parser.lis". If there are no errors, the real-time system
      description is transformed according to the options specified,
      the analysis is performed, and the results are output to the
      output file, if specified, or else to the standard output.

      The mast tools automatically use the conversion tools. Names
      ending in ".xml" are interpreted as XML files.

      tool_name  : is one of the following (more to come)
      ---------       
           parse                  : does not make the analysis
           classic_rm             : classic response time analysis for
                                    arbitrary deadlines
           varying_priorities     : varying priorities analysis for
                                    linear monoprocessor systems
           edf_monoprocessor      : response time analysis for EDF systems
           edf_within_priorities  : response time analysis for single 
                                    processor systems with hierarchical 
                                    scheduling: EDF on top of fixed
                                    priorities
           holistic               : holistic linear analysis
           offset_based_optimized : offset-based linear analysis
                                    optimized to take advantage of the 
                                    priority in the precedence relations
           offset_based           : offset-based linear analysis

      input_file : needs to be defined using the Mast file format
      ----------   (see the Mast file format definition)

      output_file: will contain the results of the analysis
      -----------  if not specified, then output goes to the standard
                   output
  
      options: the following options are defined:
      -------

        -v, -verbose:
              enable the verbose option

        -c, -ceilings
              calculate ceilings for priority ceiling resources and
              preemption levels for the stack resource policy before
              the analysis

        -p, -priorities
              make an optimum priority or scheduling parameters
              assignment before the analysis, using the specified
              assignment technique; this option always implies
              automatic calculation of the ceilings of priority
              ceiling resources, as if the -c option had been
              specified

        -t name, -technique name
              this option specifies the priority or scheduling
              parameters assignment technique named with "name"; it
              can be one of the following:
                   hopa          (default for multiprocessors)
                   annealing
                   deadline_distribution
                   monoprocessor (default for monoprocessors)

        -a filename, -assignment_parameters filename
              if this option is specified, the parameters used for
              assigning priorities with the hopa or annealing
              techniques are read from the specified filename; if the
              option is not specified, a default filename of
              "priority_assignment_parameters.txt" is assumed; if that
              file does not exist, default parameters are used

        -d filename, -description filename
               if this option is specified, after parsing the file
               and, if required, calculating the ceilings, levels,
               priorities, and scheduling parameters, a description of
               the system is written to the filename specified in the
               option.

        -s, -slack
               if this option is specified, the analysis is iterated
               to obtain the system slack, the transaction
               slack for each transaction, and the processing resource
               slack for each processing resource.

        -os name, -operation_slack name
               if this option is specified, the analysis is iterated
               to obtain the operation slack for the operation named
               as "name".
               
   graphical results viewer
   ------------------------

      It is invoked directly from the gmast driver, if the
      corresponding option is selected.

      It can also be invoked directly from the command line:

         gmastresults model_file results_file

      where model_file is the file containing the mast system
      description, and results_file is the file containing the results
      of the analysis tools on that model_file


5. PRIORITY AND SCHEDULING PARAMETERS ASSIGNMENT TOOLS
------------------------------------------------------

Priority assignment parameters
------------------------------

    The priority assignment parameters allow the configuration of the
    priority assignment tools in order to determine two main aspects:

       a) bounding the number of iterations performed by the algorithm to
	  reach a priority assignment that makes the system schedulable

       b) bounding the number of iterations to optimize, which are used
	  after a feasible solution has been obtained to optimize and try
	  reaching a better assignment.

    The priority assignment algorithm for single processors does not need
    any parameter, but the simulated annealing and HOPA algorithms work
    according to the values of several parameters that define their
    performance.

    The priority assignment parameters are found in the file
    priority_assignment_parameters.txt, in the working directory.

Simulated annealing parameters:
-------------------------------

 - Max_Iterations: maximum number of iterations to be performed by
   the algorithm.

 - Iterations_To_Optimize: maximum number of iterations to be
   performed by the algorithm after the first feasible solution has
   been reached.


HOPA parameters:
----------------

The maximum number of iterations for this algorithm is not explicit,
and depends on the size of the List of K-pairs and the values for the
number of iterations declared in the iterations list.

 - List of K-pairs: K values are heuristic constants used to modify
   the internal deadlines that are the basis of the algorithm. Normal
   values for these constant are between 1.0 and 3.0, and the usual
   number of different values that HOPA may attempt is between 3 and 5.

    - Size_Of_K_List: number of K-pairs

    - Ka_List: list of constants for varying the priorities according
      to the response times of the activities in a transaction

    - Kr_List: list of constants for varying the priorities according
      to the response times of the activities in a processing resource

 - List of number of iterations to perform for each K-pair:
   Usually, this is a list with increasing values, starting for
   example with 10. Each value represents an attempt to find better 
   solutions for all values of the list of K-pairs.

    - Size_Of_Iterations_List: size of the iterations list

    - Iterations_List: list with the numbers of iterations to be
      performed by the algorithm for each K-pair

 - Iterations_To_Optimize: maximum number of iterations to be
   performed by the algorithm after the first feasible solution has
   been reached. 


6. SUPPORT, PROBLEMS, AND QUESTIONS
-----------------------------------

   If you have any questions, comments, or need help in using MAST, please 
   send a message to:

         mgh@unican.es

   To download the most recent version of MAST please look in:

         http://mast.unican.es/

   Thanks for your interest in MAST,


                   The MAST team.

