//Todo
//connect Surface fit with slope....



//Open Image$
Scale = 10;
PathImage= File.openDialog("Choose your image");
DirSource=File.getParent(PathImage);
Dir1 = getDirectory("Choose a Directory to save images");
open(PathImage);
run("Duplicate...", "duplicate channels=2");
rename("Src_Img");
run("Z Project...", "projection=[Max Intensity]");
rename("Max_Src_Img");
ImageNameNoExt = File.nameWithoutExtension;
// Create Surface

run("Polynomial Surface Fit", "order=3 order_0=3");
rename("Surface");
getPixelSize(unit, pixelWidth, pixelHeight);
Newpixelsize = pixelWidth/Scale;

getDimensions(width, height, channels, slices, frames);
xSlope = newArray(width);
xInt = newArray(width);
ySlope = newArray(width);
yInt = newArray(width);
for (i = 1; i <= height; i++) {
	setBatchMode(true);

	//get X and Y Profile info Slope and Measured Intensity 
	ProfileInfoX("Surface",width,height,xSlope,i);
	ProfileInfoX("Max_Src_Img",width,height,xInt,i);
	ProfileInfoY("Surface",width,height,ySlope,i);
	ProfileInfoY("Max_Src_Img",width,height,yInt,i);
	setBatchMode(false);		
	//Compute new needed space
	//?? How many pixel ?
	XTotalNum_Pix = newArray(width);
	for (j = 0; j < width; j++) {
		Length = abs(xSlope[j])*pixelWidth;
		XTotalNum_Pix[i-1] = XTotalNum_Pix[i-1]+Length;
	}
	YTotalNum_Pix = newArray(height);
	for (j = 0; j < height; j++) {
		Length = abs(ySlope[j])*pixelHeight;
		YTotalNum_Pix[i-1] = YTotalNum_Pix[i-1]+Length;
	}
	//find maximum length needed 
	
}

	XMaxLength = Array.findMaxima(XTotalNum_Pix, 0);
	YMaxLength = Array.findMaxima(YTotalNum_Pix, 0);
	print(XMaxLength[0], YMaxLength[0]);
	//Create accurate new image
	
function ProfileInfoX(ImageName,width,height,GetArray,index) {
	
	selectWindow(ImageName);
	makeLine(index, 1, index, width);
	run("Plot Profile");
	Plot.getValues(x, GetArray);
	run("Close");
}
function ProfileInfoY(ImageName,width,height,GetArray,index) {
	selectWindow(ImageName);
	makeLine(1, index, height, index);
	run("Plot Profile");
	Plot.getValues(x, GetArray);
	run("Close");
}


waitForUser("pasue");
roiManager("add");
roiManager("Select",0)
roiManager("rename","Profile");
Scale = 5;

//get Intensity

//Projection...()
//initialization
	selectWindow("Src_Img");
	setSlice(42);
	run("Duplicate...", "title=Slice_"+42);
	selectWindow("Slice_"+42);
	roiManager("Select",0);
	getSelectionCoordinates( xprofile, yprofile );
	NumberOfPixel = 0;
	//Calculate Projected dx
	dx = xprofile[2]-xprofile[1];
	dy = newArray(xprofile.length);
	dxproj =newArray(xprofile.length);
	for (i = 0; i < yprofile.length-1; i++) {
			dy[i]=(yprofile[i+1]-yprofile[i])/dx;
			dxproj[i] = sqrt(dy[i]*dy[i]+dx*dx); //Length of projected pixel
			// Total length with subpixel of a 10th
			Newpixelsize = dx/Scale;		
			NumberOfPixel = NumberOfPixel+dxproj[i]*Scale;
	}
	print("NumberOfPixel is ",NumberOfPixel);
	newImage("NewProjectedImaged", "8-bits", NumberOfPixel, 44, 1);
	//Dilatation

	//Measure yInt
	
	
	
for (k = 1; k <= nSlices; k++) {
	selectWindow("Original");
	setSlice(k); print("Analysing Slice "+k+"...");
	run("Duplicate...", "title=Slice_"+k);
	selectWindow("Slice_"+k);
	roiManager("Select",0);
	run("Plot Profile");
	Plot.getValues(x, yInt); // Intensity Profile
	IndexpixeltoWrite = 0;
	setBatchMode(true);
	for (i = 0; i < dxproj.length; i++) {
		for (j = 0; j <= dxproj[i]/dx*Scale; j++) {
			//print(floor(IndexpixeltoWrite+j), yInt[i]);
			selectWindow("NewProjectedImaged");
			setPixel(floor(IndexpixeltoWrite+j), k, yInt[i]);
		}
		IndexpixeltoWrite = IndexpixeltoWrite+dxproj[i]/dx*Scale;
	}
	setBatchMode(false);
	selectWindow("Slice_"+k); run("Close");
selectWindow("Plot of Slice_"+k); run("Close");
	selectWindow("Original");
	print("Analysing Slice "+k+"...done");
}

//Create Masks from Selection
setBatchMode(true);
for (i = 1; i <= nSlices; i++) {
	selectWindow("Original");
	setSlice(i);
	roiManager("select", 0);
	run("Create Mask");
	selectWindow("Mask");rename("Mask_"+i);
	selectWindow("Original");
}
setBatchMode(false);

