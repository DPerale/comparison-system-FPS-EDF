cd mast_analysis
gnatmake -gnato -I../utils mast_analysis
cd ..

cd gmast
cd src
gnatmake -Ic:/GtkAda/include/gtkada -I../../mast_analysis -I../../utils gmast_analysis
cd ..
cd ..

cd gmastresults
cd src
gnatmake -Ic:/GtkAda/include/gtkada -I../../mast_analysis -I../../utils gmastresults
cd ..
cd ..

cd mast_xml
gnatmake -I../mast_analysis -I../utils -aIc:/gnat/xmlada/include/xmlada mast_xml_convert -largs -Lc:/gnat/xmlada/lib
gnatmake -I../mast_analysis -I../utils -aIc:/gnat/xmlada/include/xmlada mast_xml_convert_results -largs -Lc:/gnat/xmlada/lib
cd ..

cd gmasteditor
cd src
gnatmake -Ic:/GtkAda/include/gtkada -I../../mast_analysis -I../../utils -I../../gmast/src -I../../gmastresults/src gmasteditor
cd ..
cd ..

