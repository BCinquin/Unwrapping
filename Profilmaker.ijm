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



//Reslice
getVoxelSize(width, height, depth, unit);
pxl_width = width; pxl_height = height; pxl_depth = depth;
getDimensions(width, height, channels, slices, frames);
Numpxls_width = width; Numpxls_height = height; 
print(pxl_width,pxl_height,pxl_depth,Numpxls_width,Numpxls_height);
selectWindow("Actin");
run("Reslice [/]...", "output="+pxl_depth+" start=Top avoid");
NewHeight = slices*pxl_depth*pxl_height;
print(NewHeight);



//Binarization //To Improve...//
run("Subtract Background...", "rolling=30 stack");
run("Remove Outliers...", "radius=5 threshold=0 which=Bright stack");
run("Convert to Mask", "method=Huang background=Dark calculate black");



//SetScale
run("Size...", "width="+Numpxls_width+" height="+ NewHeight+" depth="+Numpxls_height+" interpolation=None");
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
run("Set Scale...", "distance="+NewHeight +" known="+depth*slices+" unit=microns");
rename("Reslice");
//Post rescaling cleanup
run("Erode", "stack"); //Erosion prior seems too brutal...
run("Remove Outliers...", "radius=5 threshold=0 which=Bright stack");

//This Step works nicely  with the file "Longest shortest paths.tif"
Smooth_Pow=2;
Img_Name="Reslice";
getDimensions(width, height, channels, slices, frames);
newImage("CleanedProfile", "8-bit color-mode", width, height, channels, slices, frames);
ProfileSlice = newArray(width);
BottomProfileVal_A = newArray(width);
setBatchMode(true);
for (j = 1; j <= nSlices; j++) {
	selectWindow(Img_Name);
	setSlice(j);
	for (i = 0; i < width; i++) {
		getDimensions(width, height, channels, slices, frames);
		makeLine(i, 1, i, height);
		
		Profile = getProfile();//Array.show(Profile);
		TopProfile = Array.findMinima(Profile, 1);//Array.show(TopProfile);
		BottomProfile = Array.findMaxima(Profile, 1);//Array.show(BottomProfile); // Find 1st Max 
		TopProfileVal = height; //init
		BottomProfileVal = height; //init
		
		if (TopProfile.length != 0) { 
			//TopProfileVal = TopProfile[0];
			TopProfileVal = BottomProfile[0];
			BottomProfileVal = BottomProfile[0];
			print(TopProfileVal,TopProfile[0],BottomProfileVal, BottomProfile[0]);
		}
		ProfileSlice[i]= (TopProfileVal+BottomProfileVal)/2;
		//BottomProfileVal_A[i] = Profile[BottomProfile[0]];
		BottomProfileVal_A[i] = 255;
	}
	selectWindow("CleanedProfile");
	setSlice(j);
	for (i = 1; i < width-1; i++) {
		if(ProfileSlice[i]==0){
			ProfileSlice[i]=height-(ProfileSlice[i-1]+ProfileSlice[i+1])/2;
		}
	}
	//Smoothing
	for (Smooth_Pow = 0; Smooth_Pow < 3; Smooth_Pow++) { // k is the factor of smoothing
		for (i = 1; i < width-1; i++) {
			ProfileSlice[i]=(ProfileSlice[i-1]+ProfileSlice[i+1])/2;
		}
	}
	for (i = 0; i < width; i++) {
	setPixel(i, ProfileSlice[i], BottomProfileVal_A[i]);
	}
}
setBatchMode(false);


//From Profile transform into a line

//Skeletonisation 

//Take Longest shortest paths output
//Widen the line
run("Dilate", "stack");
run("Dilate", "stack");
run("Erode", "stack");
//Threshold
setAutoThreshold("Default dark");
//Make Selection
for (i = 1; i < nSlices; i++) {
	setSlice(i);
	run("Create Selection");
	run("Area to Line");
	roiManager("add");
}

//Transform Area into line...