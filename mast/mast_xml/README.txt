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
--	    Yago Pereiro Estevan   pereiroy@unican.es		     --
--                                                                   --
-- This program is free software; you can redistribute it and/or     --
-- modify it under the terms of the GNU General Public               --
-- License as published by the Free Software Foundation; either      --
-- version 2 of the License, or (at your option) any later version.  --
--                                                                   --
-- This program is distributed in the hope that it will be useful,   --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of    --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU  --
-- General Public License for more details.                          --
--                                                                   --
-- You should have received a copy of the GNU General Public         --
-- License along with this program; if not, write to the             --
-- Free Software Foundation, Inc., 59 Temple Place - Suite 330,      --
-- Boston, MA 02111-1307, USA.                                       --
--                                                                   --
-----------------------------------------------------------------------

                            Version 1.3.7.8

                          XML Conversion Tools
                          --------------------

TABLE OF CONTENTS
-----------------

   1. Introduction
   2. Binary Installation
   3. Source Installation   
   4. Usage of the Conversion Tools
   5. Support, Problems, and Questions

1. INTRODUCTION
---------------

The XML conversion tools provide conversions between the XML and text
formats for the description of MAST systems, and for the results
obtained by using the analysis or simulation tools.

For a description on the XML and text formats see the documentation
section in the MAST Web page:

   http://mast.unican.es/

There are two tools included in this package, provided as separate
programs:

   - mast_xml_convert: converts MAST model descriptions between the XML
                       and text formats

   - mast_xml_convert_results: converts MAST results descriptions 
                               between the XML and text formats
   

2. BINARY INSTALLATION
----------------------

The binaries come with the mast binary installations. See the general
README file. Don't forget to put the executable files in a directory
contained in your PATH.

3. SOURCE INSTALLATION
----------------------

- Requires the gnat compiler (libre.adacore.com). We have used the
  GPL2007 version of gnat in Linux, and GAP2005 version in Windows.

- Unzip and extract the source files from the mast installation.  see
  the general README file for this purpose. The sources of the XML
  conversion tools will appear in the mast_xml directory.

- Install the free-software xmlada library, which can be found at
     http://libre.adacore.com/xmlada/ 
  We have used version 2.2.0

- Compile the conversion tools:

    The tools can be compiled in Windows by invoking the following
    command in directory mast_xml

       gnatmake -g -I../mast_analysis -I../utils -aI/c:gnat/xmlada/include/xmlada mast_xml_convert -largs -L/c:/gnat/xmlada/lib  
       gnatmake -g -I../mast_analysis -I../utils -I/c:gnat/xmlada/include/xmlada mast_xml_convert_results -largs -L/c:/gnat/xmlada/lib  

     assuming that you have installed the xmlada library in c:/gnat/xmlada

    To compile in Linux, invoke the following command in directory
    mast_xml
	
       gnatmake -g -I../mast_analysis -I../utils mast_xml_convert `xmlada-config`
       gnatmake -g -I../mast_analysis -I../utils mast_xml_convert_results `xmlada-config`

- Make the executable files mast_xml_convert and
  mast_xml_convert_results available, by adding the mast_xml directory
  to the $PATH environment variable, or by creating links to these
  files from a directory already included in the PATH.


4. USAGE OF THE CONVERSION TOOLS
------------------------------

mast_xml_convert:

   Usage: mast_xml_convert input-file <output-file>

   The program converts the input-file from XML to text if its name
   ends with ".xml", and from text to XML otherwise. The <> notation
   above indicates that the output-file is optional. If not present,
   the output goes to the standard output.

mast_xml_convert_results:

   Usage: 
     mast_xml_convert_results model-infile results-infile <results-outfile>

   The program converts the results-infile file from XML to text if
   its name ends with ".xml", and from text to XML otherwise. To
   interpret the results, the file with the MAST model is required. The
   <> notation above indicates that the results-outfile is
   optional. If not present, the output goes to the standard output.

The mast tools automatically use the conversion tools. Names ending in
".xml" are interpreted as XML files.


5. SUPPORT, PROBLEMS, AND QUESTIONS
-----------------------------------

   If you have any questions, comments, or need help in using MAST, please 
   send a message to:

         mgh@unican.es

   To download the most recent version of MAST please look in:

         http://mast.unican.es/

   Thanks for your interest in MAST,


                   The MAST team.

