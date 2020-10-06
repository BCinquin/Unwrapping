Img_Name="ResliceProfilBinary.tif";
getDimensions(width, height, channels, slices, frames);
newImage("CleanedProfile", "8-bit color-mode", width, height, channels, slices, frames);
ProfileSlice = newArray(width);

setBatchMode(true);
for (j = 1; j <= nSlices; j++) {
	selectWindow(Img_Name);
	setSlice(j);
	for (i = 0; i < width; i++) {
		getDimensions(width, height, channels, slices, frames);
		makeLine(i, 1, i, height);
		
		Profile = getProfile();//Array.show(Profile);
		TopProfile = Array.findMinima(Profile, 1);//Array.show(TopProfile);
		BottomProfile = Array.findMaxima(Profile, 1);//Array.show(BottomProfile);
		TopProfileVal = height;
		BottomProfileVal = height;
		
		if (TopProfile.length != 0) { 
			TopProfileVal = TopProfile[0];
			BottomProfileVal = BottomProfile[0];
			print(TopProfileVal,TopProfile[0],BottomProfileVal, BottomProfile[0]);
		}
		ProfileSlice[i]= (TopProfileVal+BottomProfileVal)/2;
	}
	selectWindow("CleanedProfile");
	setSlice(j);
	for (i = 1; i < width-1; i++) {
		if(ProfileSlice[i]==0){
			ProfileSlice[i]=height-(ProfileSlice[i-1]+ProfileSlice[i+1])/2;
		}
	}
	//Smoothing
	for (k = 0; k < 1; k++) {
		for (i = 1; i < width-1; i++) {
			ProfileSlice[i]=(ProfileSlice[i-1]+ProfileSlice[i+1])/2;
		}
	}
	for (i = 0; i < width; i++) {
	setPixel(i, ProfileSlice[i], 255);
	}
}
setBatchMode(false);