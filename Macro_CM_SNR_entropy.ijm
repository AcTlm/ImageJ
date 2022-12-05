/* Macro DM_Analyse d'image 
* Master2 AMI2B - AIB 
* Author: AcTlm
*/

run("Close All");
waitForUser("Please open image")
open();
rename("The_image");
rename("Image_Noised");
dir_out=getDirectory("Please select a repository"); 


// Observer la présence de bruit 
	//selectWindow("Image_Noised");
	//run("Duplicate...", " ");
	//rename("Duplicate_1");
	//selectWindow("Duplicate_1");
	//makeRectangle(3, 4, 709, 71);
	//run("Subtract Background...", "rolling=1");
	//run("Plot Profile");

	selectWindow("Image_Noised");

// Choisir le filtre 
filter = newArray("Convolve", "Median", "Minimum", "Maximum", "Variance", "Unsharp_Mask","Top hat");
Dialog.create(" Choose a filter and fixe parameters:");
Dialog.addChoice("Choose a filter in a list:",filter);
Dialog.addNumber("Radius Minimum:", 1);
Dialog.addNumber("Radius Maximum:", 5);
Dialog.addNumber("Radius step:", 1);
Dialog.show() ;

filter = Dialog.getChoice();
rad_min = parseFloat(Dialog.getNumber());
rad_max = parseFloat(Dialog.getNumber());
rad_step = parseFloat(Dialog.getNumber());

// objets necessaires  pour constuire le graph 
nb_points= (rad_max-rad_min)/rad_step;
liste_CM= newArray(nb_points);
liste_SNR = newArray(nb_points);
liste_Entropy = newArray(nb_points);
liste_X = newArray(nb_points);


function calcul_entropy( area,histogram)
	{
  	var val;
 	val = 0;
 	 for (i = 0; i < histogram.length; i++)
		{
   		 if (histogram[i] > 0)
			{
     			 val += ((histogram[i]/area) * (Math.log(histogram[i]/area)/Math.log(2)));
   			 }
 		 }
 	 return val;
	}

step_plot = 0;
for (i = rad_min ; i<= rad_max; i+= rad_step)
	{
	selectWindow("Image_Noised");
	run("Duplicate..."," ");

	if (filter == "Convolve")
		{run("Convolve...", "radius=i ");}
	if (filter == "Median")
		{run("Median...", "radius=i");}
	 if (filter == "Minimum")
 		{run("Minimum...", "radius=i");}
	if (filter == "Maximum")
		{run("Maximum...", "radius=i");}
	if (filter == "Variance")
		{run("Variance...", "radius=i");}
	if (filter == "Unsharp Mask")
		{run("VUnsharp Mask...", "radius=i");}
	if (filter == "Top hat");
		 {run("Top Hat...", "radius=i");}


	// Parameters required to calculate SNR, CM, Entropy 
	getStatistics(area, mean, min_2, max_2, std, histogram);
	
	// Calculate CM
	CM=(max_2-min_2)/(max_2+min_2); 
	liste_CM[step_plot] += CM ;

	// Calcul SNR 
	if (std != 0) {
		SNR = 10 * Math.log(((mean/std)^2))/Math.log(10); }
	else {SNR = 0}
	
	liste_SNR[step_plot] += SNR ;

	// Calcul Entropy 
	liste_Entropy[step_plot] = calcul_entropy(area,histogram);  
	
	//Axe X plot
	liste_X[step_plot] += i;

	// Enregistrer l'image  and incrementer la boucle
	//saveAs("Tiff",dir_out+i);
	i+= rad_step;
	step_plot++;

	} // fin boucle 

run("Close All");

// PLOT 
Plot.create("Plot CM SNR Entropy ", "radius", "mesure");
Plot.setLimits(rad_min, rad_max, 0, 10 );
Plot.setFrameSize(600, 300);
Plot.setColor("blue");
Plot.add("line", liste_X, liste_CM,"Cm");
Plot.setColor("red");
Plot.add("line", liste_X, liste_SNR,"SNR");
Plot.setColor("green");
Plot.add("line", liste_X, liste_Entropy,"Entropy");
Plot.setLegend("", "top-right");
Plot.show();








