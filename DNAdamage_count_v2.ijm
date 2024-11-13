// the script is for the quantification of  foci number in the each nuclus, Liu Mei Omaha 10/14/2024
// get dapi file to analyze
DAPIFile=File.openDialog("Choose DAPI tif file to analyze.");
run("Bio-Formats Importer", "open=["+DAPIFile+"] color_mode=Default");
rename("DAPIImage");
run("Enhance Contrast", "saturated=0.35");
run("Fire");
// threshold 
selectWindow("DAPIImage");
run("Median...", "radius=1");
setAutoThreshold("Li dark no-reset");
setOption("BlackBackground", true);
run("Convert to Mask");

// cleaning of regions
run("Fill Holes");
run("Options...", "iterations=3 count=4 black edm=8-bit do=Open");
run("Watershed");

// get rid of small particles
run("Analyze Particles...", "size=100-Infinity show=Masks add in_situ");
//
fociFile=replace(DAPIFile,"ch01.","ch00.");
run("Bio-Formats Importer", "open=["+fociFile+"] color_mode=Default ");
rename("fociImage");
run("Enhance Contrast", "saturated=0.35");
run("Fire");

// subtract background
setForegroundColor(0, 0, 0);

makeRectangle(0, 0, 2048, 1);
run("Fill", "slice");
makeRectangle(0, 0, 1, 2048);
run("Fill", "slice");
makeRectangle(2047, 0, 1, 2048);
run("Fill", "slice");
makeRectangle(0, 2047, 2048, 1);
run("Fill", "slice");

selectWindow("fociImage");
run("Select None");
run("Duplicate...", "title=bck");
run("Median...", "radius=10");
run("Subtract Background...", "rolling=500 create");
imageCalculator("Subtract", "fociImage","bck");
selectWindow("bck");
close();
run("Set Measurements...", "area mean standard modal centroid redirect=None decimal=3");
//Count foci
selectWindow("fociImage");
roiManager("Select All");
n = roiManager("Count");
data = ("cell number_maxima Count")
for (i = 0; i < n; i++) {
	roiManager("Select", i);
	run("Find Maxima...", "prominence=30 output=Count");// prominence should be adjusted based on your own images
	count = getResult("Count");
	
	data += (i+1)+"," + count + "\n";
	print(" Cell ", i+1, ": Maxima Count = ", count);	
}

saveAs("Results", replace(DAPIFile,"ch01.tif",".csv"));

//Clean up 
roiManager("Deselect");
roiManager("Delete")


