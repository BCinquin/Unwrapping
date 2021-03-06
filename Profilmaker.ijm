//Open Raw Image
PathImage= File.openDialog("Choose your image");
DirSource=File.getParent(PathImage);
open(PathImage);
//SelectChannel to fit surface
Dialog.create("Analysis Choices");
Dialog.addNumber("Actin Channel Number", 2);
Dialog.addNumber("Smoothing Factor",2);
Dialog.show();
Actin_Channel = Dialog.getNumber();
Smooth_Pow = Dialog.getNumber();
run("Duplicate...", "duplicate channels="+Actin_Channel);
rename("Actin");

//Option Draw the Profile


//Reslice
getVoxelSize(width, height, depth, unit);
pxl_width = width; pxl_height = height; pxl_depth = depth;
getDimensions(width, height, channels, slices, frames);
Numpxls_width = width; Numpxls_height = height; 
print(pxl_width,pxl_height,pxl_depth,Numpxls_width,Numpxls_height);
selectWindow("Actin");
run("Reslice [/]...", "output="+pxl_depth+" start=Top avoid");
NewHeight = slices*pxl_depth;
//NewHeight = slices*pxl_depth*pxl_height;
print(NewHeight);


//Binarization //To Improve...//
run("Subtract Background...", "rolling=30 stack");
//run("Remove Outliers...", "radius=5 threshold=0 which=Bright stack");
//run("Convert to Mask", "method=Huang background=Dark calculate black");



//SetScale
run("Size...", "width="+Numpxls_width+" height="+ NewHeight+" depth="+Numpxls_height+" interpolation=None");

waitForUser("Pause");
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
run("Set Scale...", "distance="+NewHeight +" known="+depth*slices+" unit=microns");
rename("Reslice");
//Post rescaling cleanup
//run("Erode", "stack"); //Erosion prior seems too brutal...
//run("Remove Outliers...", "radius=5 threshold=0 which=Bright stack");

//This Step works nicely  with the file "Longest shortest paths.tif"
//Smooth_Pow=2;
Img_Name="Reslice";
getDimensions(width, height, channels, slices, frames);
newImage("CleanedProfile", "8-bit color-mode", width, height, channels, slices, frames);
newImage("ProfileWithInt", "8-bit color-mode", width, height, channels, slices, frames);
ProfileSlice = newArray(width);
BottomProfileVal_A = newArray(width);
BottomProfileInt_A = newArray(width);
Table.create("Intensity_Slice");
Table.rename("Intensity_Slice", "Results");
setBatchMode(true);
for (j = 1; j <= nSlices; j++) {
	selectWindow(Img_Name);
	setSlice(j);
	for (i = 0; i < width; i++) {
		getDimensions(width, height, channels, slices, frames);
		makeLine(i, 1, i, height);
		Profile = getProfile();//Array.show(Profile);
		TopProfile = Array.findMinima(Profile, 0);//Array.show(TopProfile);waitForUser("Pause");
		BottomProfile = Array.findMaxima(Profile, 0);//Array.show(BottomProfile); // Find 1st Max 
		TopProfileVal = height; //init
		BottomProfileVal = height; //init
		if (TopProfile.length != 0) { 
			TopProfileVal = TopProfile[0];
			BottomProfileVal = BottomProfile[0];
			//print(TopProfileVal,TopProfile[0],BottomProfileVal, BottomProfile[0]);
			//ProfileSlice[i]=BottomProfileVal;
			ProfileSlice[i]= BottomProfileVal;
			ValueforProfile = 0;
			if (BottomProfile[0] <=3 || height-BottomProfile[0] <=3){
					ValueforProfile = BottomProfile[0]*5;
				}
			else {
				for (k = 0; k < 5; k++) {
					Index = BottomProfile[0]+k-2;
					ValueforProfile = ValueforProfile+Profile[Index];
				}
			}
			BottomProfileInt_A[i] = ValueforProfile/5;
			BottomProfileVal_A[i] = 255;
		}	
		if (TopProfile.length == 0) { 
			TopProfileVal = height;
			BottomProfileVal = height;
			print("Empty Array");
			//ProfileSlice[i]=BottomProfileVal;
			ProfileSlice[i]= (TopProfileVal+BottomProfileVal)/2;
			BottomProfileInt_A[i] = 0;
			BottomProfileVal_A[i] = 255;
		}		
		
	}
//	 Table.showArrays("Profiles", BottomProfileInt_A, BottomProfileVal_A);
//	selectWindow("CleanedProfile");
//	setSlice(j);
	for (i = 1; i < width-1; i++) {
		if(ProfileSlice[i]==0){
			ProfileSlice[i]=height-(ProfileSlice[i-1]+ProfileSlice[i+1])/2;
		}
	}
	//Smoothing
	for (k = 0; k < Smooth_Pow; k++) { // k is the factor of smoothing
		for (i = 1; i < width-1; i++) {
			ProfileSlice[i]=(ProfileSlice[i-1]+ProfileSlice[i+1])/2;
		}
	}
	selectWindow("CleanedProfile");setSlice(j);
	for (i = 0; i < width; i++) {
		setPixel(i, ProfileSlice[i], BottomProfileVal_A[0]);
	}
	selectWindow("ProfileWithInt");setSlice(j);
	for (i = 0; i < width; i++) {	
		setPixel(i, ProfileSlice[i], BottomProfileInt_A[i]);
	}
	Table.setColumn("Height_Info_Slice_"+j, ProfileSlice);
	Table.setColumn("Intensity_Info_Slice_"+j, BottomProfileInt_A);
}
Table.rename("Results","Intensity_Slice");
setBatchMode(false);


/*//Projection Initialisation 
	Scale = 10
	selectWindow("CleanedProfile");
	setSlice(386);
	run("Duplicate...", "title=Slice_"+386);
	selectWindow("Slice_"+386);
	roiManager("Select",0);
	getSelectionCoordinates( xprofile, yprofile );
	Array.show("title", xprofile, yprofile);
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
	newImage("NewProjectedImaged", "8-bits", NumberOfPixel, 772, 1);
*/
//PrepSpace
Table.rename("Intensity_Slice","Results");
Scale = 5;
NumberOfPixel = newArray(nSlices); //Init
//Projection dxproj will be dy/dx
dx = 1; //Need to convert in µm at the end
dy = newArray(nResults);
dxproj = newArray(nResults);

for (k = 0; k < nSlices; k++) { //for each slice
	for (i = 0; i < nResults-1 ; i++) {   //Compute Slope 
		dy[i] = getResult("Height_Info_Slice_"+k+1, i+1)-getResult("Height_Info_Slice_"+k+1, i);
		dxproj[i] = sqrt(dy[i]*dy[i]+dx*dx); //Length of projected pixel
		NumberOfPixel[k] = NumberOfPixel[k]+dxproj[i]; 
	}
}

//Profil length are different ==> Scale need to be adapted
 Array.getStatistics(NumberOfPixel, min, max, mean, stdDev);
 Scale_A = newArray(nSlices);
 for (k=0; k< nSlices ; k++){
 	Scale_A[k] = max/NumberOfPixel[k]*Scale;
 }
 Array.show(NumberOfPixel,Scale_A);
 TotalHeight = nSlices;
 newImage("Projection","8-bit black",max*Scale,nSlices,1);

//Projection

Intensity_Profile_A = newArray(nResults);

for (k = 1; k < TotalHeight; k++) {
	IndexOfPixeltoWrite = 0;
	for (i = 0; i < nResults-1; i++) {
		Intensity_Profile_A[i] = getResult("Intensity_Info_Slice_"+k+1, i);
		dy[i] = getResult("Height_Info_Slice_"+k+1, i+1)-getResult("Height_Info_Slice_"+k+1, i);
		NumberOfPixelToWrite = sqrt(dy[i]*dy[i]+dx*dx)*Scale_A[k]; //Number of pixel to write
		selectWindow("Projection");
		for (j = 0; j<NumberOfPixelToWrite; j++){
			setPixel(floor(IndexOfPixeltoWrite+j), k-1, Intensity_Profile_A[i]);
			//print(floor(IndexOfPixeltoWrite+j), k-1, Intensity_Profile_A[i]);
		}
		IndexOfPixeltoWrite = IndexOfPixeltoWrite+NumberOfPixelToWrite;	
		
	}
	print("line "+k+" on "+TotalHeight+" lines done");
}
	
	