/* Fingerpult
 * Programm zur Erzeugung eines Pultes mit Fingerpassung durch Lasercutter
 * Mathis Garrandt 2019
 * Basierend auf:
 * Fingerbox
 * Programm zur Erzeugung einer Box mit Fingerpassung durch Lasercutter
 * in 2D zum Export als DXF-Datei,
 * alle Angaben in Millimeter,
 * Laserstrahldicke wird berücksichtigt!
 * mit Passnocke!!
 * Stefan Abel 2016
 */
 
//Definition von Variablen
Laenge = 180;   //in X-Richtung
Breite = 210;   //in Y-Richtung
Hoehe = 20;    //in Z-Richtung
HoeheVorne = 40;
HoeheHinten = 80;

FB = 8;        //Fingerbreite
MD = 3;        //Materialdicke

Abstand = 2;   // für die Ausgabe

PN = 0.10;   //Passnockenhoehe zur besseren Passung
             //HDF 5mm: 0.05
             //HDF 3mm: 0.08 (0.10 bei lockerer Passung)
LD = 0.20;   //Laserstrahldicke
             //HDF 5mm: 0.10 (19mm/s;60/58%)
             //HDF 3mm: 0.15 (33mm/s;60/58%) (0.20 lockere Passung)
            
LDH = LD*0.5;


//Hauptprogramm

//Bauteil (Xdim,Ydim,FB,MD,SO,SU,SL,SR)
// SO,SU,SR,SL sind Schalter für Fingerpassung
// für die Kanten oben, unten, rechts, links
// 0:glatte Kante
// 1:Nuten
// 2:Nuten mit Passnocke (siehe Mass für PN)
// 3:glatte Finger
// 4:Finger mit Passnocke (siehe Mass für PN)

// functionen und module
function DrX (x,y,wi) = x*cos(wi)+y*sin(wi);
function DrY (x,y,wi) = -x*sin(wi)+y*cos(wi);
function Hypo (a,b) = sqrt( pow(a,2) + pow(b,2));
function FiZ (S,F) = floor ((S-4*MD)/(2*F));
// Ergänzungen für Pultform, Pythagoras lässt grüßen
// Berechnung der Laenge des Deckels auf der schraegen Oberseite
LaengeDeckel = Hypo(Laenge, abs(HoeheHinten-HoeheVorne));
WinkelDeckel = atan(abs(HoeheHinten-HoeheVorne)/Laenge);
VorneKuerzen = tan(WinkelDeckel)*MD;
echo("LaengeDeckel:",LaengeDeckel);
echo("WinkelDeckel:",WinkelDeckel);
echo("VorneKuerzen:",VorneKuerzen);

//Bodenplatte
color("Black",0.8) offset(delta = LDH) Bodenplatte (Laenge,Breite,FB,MD,3,3,2,2);

//Deckel für Pult
color("Black",0.4) translate ([0,-Breite-Abstand,0]) offset(delta = LDH) BauteilDeckel (LaengeDeckel,Breite,FB,MD,0,0,1,1);

//Längsseitenteile (beide gleich)
color("Indigo",0.8) translate ([0,Breite+Abstand,0]) offset(delta = LDH) BauteilSeite (Laenge,HoeheVorne,HoeheHinten,FB,MD,0,2,2,2);
color("Indigo",0.4) translate ([Laenge,Breite+ HoeheHinten+ HoeheVorne+2*Abstand,0]) rotate(180) offset(delta = LDH) BauteilSeite (Laenge,HoeheVorne,HoeheHinten,FB,MD,0,2,2,2);
//color("Indigo",0.4) translate ([0,Breite+Abstand,0]) offset(delta = LDH) Bauteil (Laenge,Hoehe,FB,MD,1,2,1,1);
//color("Indigo",0.4) translate ([0,Breite+Hoehe+2*Abstand,0]) offset(delta = LDH) Bauteil (Laenge,Hoehe,FB,MD,1,2,1,1);

//Breitseitenteile (unterschiedlich hoch)
color("Cyan",0.8) translate ([-HoeheVorne-Abstand,0,0]) offset(delta = LDH) 
    difference(){
    BauteilVorne (HoeheVorne,Breite,FB,MD,4,4,3,4);
    polygon(points=[[0,0],[0,Breite],[VorneKuerzen, Breite],[VorneKuerzen,0]]);
    }
color("Cyan",0.4) translate ([-HoeheHinten-Abstand,-Breite-Abstand,0]) offset(delta = LDH) Bauteil (HoeheHinten,Breite,FB,MD,4,4,3,4);


//Visualisierung der Box in 3D
//color("Gold",0.8) translate ([0,-Breite,0]) cube([Laenge,Breite,Hoehe], false);


//Unterprogramm als Module

module Bodenplatte (Xdim,Ydim,FB,MD,SO,SU,SL,SR){ 
difference()
{
    echo (Xdim,Ydim,FB,MD,SO,SU,SR,SL);
    FZx = round ((Xdim-FB)/(2*FB)-2);
    echo (FZx);
    Ax = (Xdim-(2*FZx*FB+FB))/2;
    echo (Ax);
    
    echo (Xdim,Ydim,FB,MD,SO,SU,SR,SL);
    FZy = round ((Ydim-FB)/(2*FB)-2);
    echo (FZy);
    Ay = (Ydim-(2*FZy*FB+FB))/2;
    echo (Ay);
    
    //Grundfläche
    polygon(points=[[0,Ydim],[Xdim,Ydim],[Xdim,0],[0,0]]);
    
    //von der Grundfläche werden Finger/Nuten entfernt
    
    //Entfernungen oben und unten
    for (x = [Ax:FB*2:Xdim-Ax])
      {
      
      //Nuten oben und unten   
      if (SO==1)
         polygon(points=[[x+0,Ydim],[x+FB,Ydim],[x+FB,Ydim-MD],[x+0,Ydim-MD]]);
     
      if (SU==1)
         polygon(points=[[x+0,MD],[x+FB,MD],[x+FB,0],[x+0,0]]);
      
      if (SO==2)
         polygon(points=[[x+0,Ydim],[x+FB,Ydim],[x+FB,Ydim-0.2*MD],[x+FB-PN,Ydim-0.4*MD],[x+FB-PN,Ydim-0.6*MD],[x+FB,Ydim-0.8*MD],[x+FB,Ydim-MD],[x+0,Ydim-MD],[x+0,Ydim-MD+0.2*MD],[x+0+PN,Ydim-MD+0.4*MD],[x+0+PN,Ydim-MD+0.6*MD],[x+0,Ydim-MD+0.8*MD], ]);
      
      if (SU==2)
         polygon(points=[[x+0,MD],[x+FB,MD],[x+FB,MD-0.2*MD],[x+FB-PN,MD-0.4*MD],[x+FB-PN,MD-0.6*MD],[x+FB,MD-0.8*MD],[x+FB,0],[x+0,0],[x,0+0.2*MD],[x+PN,0+0.4*MD],[x+PN,0+0.6*MD],[x,0+0.8*MD]]);
      
      
      //Finger oben und unten     
      if (SO==3)
         {
         polygon(points=[[0,Ydim],[Ax,Ydim],[Ax,Ydim-MD],[0,Ydim-MD]]);
         polygon(points=[[Xdim-Ax,Ydim],[Xdim,Ydim],[Xdim,Ydim-MD],[Xdim-Ax,Ydim-MD]]);
         polygon(points=[[x-FB,Ydim],[x,Ydim],[x,Ydim-MD],[x-FB,Ydim-MD]]);
         }   
      
      if (SU==3)
         {
         polygon(points=[[0,MD],[Ax,MD],[Ax,0],[0,0]]);
         polygon(points=[[Xdim-Ax,MD],[Xdim,MD],[Xdim,0],[Xdim-Ax,0]]);
         polygon(points=[[x-FB,MD],[x,MD],[x,0],[x-FB,0]]);
         }
 
      if (SO==4)
         {
         polygon(points=[[0,Ydim],[Ax,Ydim],[Ax,Ydim-0.2*MD],[Ax-PN,Ydim-0.4*MD],[Ax-PN,Ydim-0.6*MD],[Ax,Ydim-0.8*MD],[Ax,Ydim-MD],[0,Ydim-MD]]);
         polygon(points=[[Xdim-Ax,Ydim],[Xdim,Ydim],[Xdim,Ydim-MD],[Xdim-Ax,Ydim-MD],[Xdim-Ax,Ydim-MD+0.2*MD],[Xdim-Ax+PN,Ydim-MD+0.4*MD],[Xdim-Ax+PN,Ydim-MD+0.6*MD],[Xdim-Ax,Ydim-MD+0.8*MD]]);
         polygon(points=[[x+FB,Ydim],[x+FB,Ydim-0.2*MD],[x+FB+PN,Ydim-0.4*MD],[x+FB+PN,Ydim-0.6*MD],[x+FB,Ydim-0.8*MD],[x+FB,Ydim-1.0*MD],[x+2*FB,Ydim-1.0*MD],[x+2*FB,Ydim-0.8*MD],[x+2*FB-PN,Ydim-0.6*MD],[x+2*FB-PN,Ydim-0.4*MD],[x+2*FB,Ydim-0.2*MD],[x+2*FB,Ydim]]);
         }
        
      if (SU==4)
         {
         polygon(points=[[0,MD],[Ax,MD],[Ax,MD-0.2*MD],[Ax-PN,MD-0.4*MD],[Ax-PN,MD-0.6*MD],[Ax,MD-0.8*MD],[Ax,0],[0,0]]);
         polygon(points=[[Xdim-Ax,MD],[Xdim,MD],[Xdim,0],[Xdim-Ax,0],[Xdim-Ax,0.2*MD],[Xdim-Ax+PN,0.4*MD],[Xdim-Ax+PN,0.6*MD],[Xdim-Ax,0.8*MD],[Xdim-Ax,MD]]);
         polygon(points=[[x+FB,MD],[x+FB,MD-0.2*MD],[x+FB+PN,MD-0.4*MD],[x+FB+PN,MD-0.6*MD],[x+FB,MD-0.8*MD],[x+FB,MD-1.0*MD],[x+2*FB,MD-1.0*MD],[x+2*FB,MD-0.8*MD],[x+2*FB-PN,MD-0.6*MD],[x+2*FB-PN,MD-0.4*MD],[x+2*FB,MD-0.2*MD],[x+2*FB,MD]]);
         }
      }
    
    
    //Entfernungen links und rechts
    for (y = [Ay:FB*2:Ydim-Ay])  
      {
      
      //Nuten links und rechts 
      if (SL==1)
         polygon(points=[[0,y+FB],[MD,y+FB],[MD,y],[0,y]]);
      
      if (SR==1)
         polygon(points=[[Xdim-MD,y+FB],[Xdim,y+FB],[Xdim,y],[Xdim-MD,y]]);
      
      if (SL==2)
         polygon(points=[[0,y+FB],[0.2*MD,y+FB],[0.4*MD,y+FB-PN],[0.6*MD,y+FB-PN],[0.8*MD,y+FB],[MD,y+FB],[MD,y],[0.2*MD,y],[0.4*MD,y+PN],[0.6*MD,y+PN],[0.8*MD,y],[0,y]]);
      
      if (SR==2)
         polygon(points=[[Xdim-MD,y+FB],[Xdim-MD+0.2*MD,y+FB],[Xdim-MD+0.4*MD,y+FB-PN],[Xdim-MD+0.6*MD,y+FB-PN],[Xdim-MD+0.8*MD,y+FB],[Xdim,y+FB],[Xdim,y],[Xdim-MD+0.2*MD,y],[Xdim-MD+0.4*MD,y+PN],[Xdim-MD+0.6*MD,y+PN],[Xdim-MD+0.8*MD,y],[Xdim-MD,y]]);
           
      
      //Finger links und rechts
      if (SL==3)
         {
         polygon(points=[[0,Ydim],[MD,Ydim],[MD,Ydim-Ay],[0,Ydim-Ay]]);
         polygon(points=[[0,Ay],[MD,Ay],[MD,0],[0,0]]);
         polygon(points=[[0,y+2*FB],[MD,y+2*FB],[MD,y+FB],[0,y+FB]]);
         }
         
      if (SR==3)
         {
         polygon(points=[[Xdim-MD,Ydim],[Xdim,Ydim],[Xdim,Ydim-Ay],[Xdim-MD,Ydim-Ay]]);
         polygon(points=[[Xdim-MD,Ay],[Xdim,Ay],[Xdim,0],[Xdim-MD,0]]);
         polygon(points=[[Xdim-MD,y+2*FB],[Xdim,y+2*FB],[Xdim,y+FB],[Xdim-MD,y+FB]]);
         }
         
      if (SL==4)
         {
         polygon(points=[[0,Ydim],[MD,Ydim],[MD,Ydim-Ay],[0.8*MD,Ydim-Ay],[0.6*MD,Ydim-Ay+PN],[0.4*MD,Ydim-Ay+PN],[0.2*MD,Ydim-Ay],[0,Ydim-Ay]]);
         polygon(points=[[0,Ay],[0.2*MD,Ay],[0.4*MD,Ay-PN],[0.6*MD,Ay-PN],[0.8*MD,Ay],[MD,Ay],[MD,0],[0,0]]);
         polygon(points=[[0,y+2*FB],[0.2*MD,y+2*FB],[0.4*MD,y+2*FB-PN],[0.6*MD,y+2*FB-PN],[0.8*MD,y+2*FB],[1.0*MD,y+2*FB],[1.0*MD,y+FB],[0.8*MD,y+FB],[0.6*MD,y+FB+PN],[0.4*MD,y+FB+PN],[0.2*MD,y+FB],[0,y+FB]]);
         }
        
      if (SR==4)
         {
         polygon(points=[[Xdim-MD,Ydim],[Xdim,Ydim],[Xdim,Ydim-Ay],[Xdim-0.2*MD,Ydim-Ay],[Xdim-0.4*MD,Ydim-Ay+PN],[Xdim-0.6*MD,Ydim-Ay+PN],[Xdim-0.8*MD,Ydim-Ay],[Xdim-MD,Ydim-Ay]]);
         polygon(points=[[Xdim-MD,Ay],[Xdim-MD+0.2*MD,Ay],[Xdim-MD+0.4*MD,Ay-PN],[Xdim-MD+0.6*MD,Ay-PN],[Xdim-MD+0.8*MD,Ay],[Xdim,Ay],[Xdim,0],[Xdim-MD,0]]);
         polygon(points=[[Xdim-MD,y+2*FB],[Xdim-MD+0.2*MD,y+2*FB],[Xdim-MD+0.4*MD,y+2*FB-PN],[Xdim-MD+0.6*MD,y+2*FB-PN],[Xdim-MD+0.8*MD,y+2*FB],[Xdim-MD+1.0*MD,y+2*FB],[Xdim-MD+1.0*MD,y+FB],[Xdim-MD+0.8*MD,y+FB],[Xdim-MD+0.6*MD,y+FB+PN],[Xdim-MD+0.4*MD,y+FB+PN],[Xdim-MD+0.2*MD,y+FB],[Xdim-MD,y+FB]]);     
         }
      }  
}
}


module BauteilSeite (Xdim,Ydim1,Ydim2,FB,MD,SO,SU,SL,SR){ 
difference()
{
    echo ("SeiteX:",Xdim,Ydim1,FB,MD,SO,SU,SR,SL);
    FZx = round ((Xdim-FB)/(2*FB)-2);
    echo (FZx);
    Ax = (Xdim-(2*FZx*FB+FB))/2;
    echo (Ax);
    
    echo ("SeiteY1:",Xdim,Ydim1,FB,MD,SO,SU,SR,SL);
    FZy1 = round ((Ydim1-FB)/(2*FB)-2);
    echo (FZy1);
    Ay1 = (Ydim1-(2*FZy1*FB+FB))/2;
    echo ("Ay1:",Ay1);
    
    echo ("SeiteY2:",Xdim,Ydim2,FB,MD,SO,SU,SR,SL);
    FZy2 = round ((Ydim2-FB)/(2*FB)-2);
    echo (FZy2);
    Ay2 = (Ydim2-(2*FZy2*FB+FB))/2;
    echo ("Ay2:",Ay2);
    
    //Grundfläche
    //Hoehe der Seitenteile um MD verkuerzen, damit Deckel mit glatter Kante aufliegen kann
    polygon(points=[[0,Ydim1-MD],[Xdim,Ydim2-MD],[Xdim,0],[0,0]]);
    
    
    //von der Grundfläche werden Finger/Nuten entfernt
    
    //Entfernungen oben und unten
    for (x = [Ax:FB*2:Xdim-Ax])
      {
      
      //Nuten oben und unten   
//      if (SO==1)
//         polygon(points=[[x+0,Ydim],[x+FB,Ydim],[x+FB,Ydim-MD],[x+0,Ydim-MD]]);
     
      if (SU==1)
         polygon(points=[[x+0,MD],[x+FB,MD],[x+FB,0],[x+0,0]]);
      
//      if (SO==2)
//         polygon(points=[[x+0,Ydim],[x+FB,Ydim],[x+FB,Ydim-0.2*MD],[x+FB-PN,Ydim-0.4*MD],[x+FB-PN,Ydim-0.6*MD],[x+FB,Ydim-0.8*MD],[x+FB,Ydim-MD],[x+0,Ydim-MD],[x+0,Ydim-MD+0.2*MD],[x+0+PN,Ydim-MD+0.4*MD],[x+0+PN,Ydim-MD+0.6*MD],[x+0,Ydim-MD+0.8*MD], ]);
      
      if (SU==2)
         polygon(points=[[x+0,MD],[x+FB,MD],[x+FB,MD-0.2*MD],[x+FB-PN,MD-0.4*MD],[x+FB-PN,MD-0.6*MD],[x+FB,MD-0.8*MD],[x+FB,0],[x+0,0],[x,0+0.2*MD],[x+PN,0+0.4*MD],[x+PN,0+0.6*MD],[x,0+0.8*MD]]);
      
      
      //Finger oben und unten     
//      if (SO==3)
//         {
//         polygon(points=[[0,Ydim],[Ax,Ydim],[Ax,Ydim-MD],[0,Ydim-MD]]);
//         polygon(points=[[Xdim-Ax,Ydim],[Xdim,Ydim],[Xdim,Ydim-MD],[Xdim-Ax,Ydim-MD]]);
//         polygon(points=[[x-FB,Ydim],[x,Ydim],[x,Ydim-MD],[x-FB,Ydim-MD]]);
//         }   
      
      if (SU==3)
         {
         polygon(points=[[0,MD],[Ax,MD],[Ax,0],[0,0]]);
         polygon(points=[[Xdim-Ax,MD],[Xdim,MD],[Xdim,0],[Xdim-Ax,0]]);
         polygon(points=[[x-FB,MD],[x,MD],[x,0],[x-FB,0]]);
         }
 
//      if (SO==4)
//         {
//         polygon(points=[[0,Ydim],[Ax,Ydim],[Ax,Ydim-0.2*MD],[Ax-PN,Ydim-0.4*MD],[Ax-PN,Ydim-0.6*MD],[Ax,Ydim-0.8*MD],[Ax,Ydim-MD],[0,Ydim-MD]]);
//         polygon(points=[[Xdim-Ax,Ydim],[Xdim,Ydim],[Xdim,Ydim-MD],[Xdim-Ax,Ydim-MD],[Xdim-Ax,Ydim-MD+0.2*MD],[Xdim-Ax+PN,Ydim-MD+0.4*MD],[Xdim-Ax+PN,Ydim-MD+0.6*MD],[Xdim-Ax,Ydim-MD+0.8*MD]]);
//         polygon(points=[[x+FB,Ydim],[x+FB,Ydim-0.2*MD],[x+FB+PN,Ydim-0.4*MD],[x+FB+PN,Ydim-0.6*MD],[x+FB,Ydim-0.8*MD],[x+FB,Ydim-1.0*MD],[x+2*FB,Ydim-1.0*MD],[x+2*FB,Ydim-0.8*MD],[x+2*FB-PN,Ydim-0.6*MD],[x+2*FB-PN,Ydim-0.4*MD],[x+2*FB,Ydim-0.2*MD],[x+2*FB,Ydim]]);
//         }
        
      if (SU==4)
         {
         polygon(points=[[0,MD],[Ax,MD],[Ax,MD-0.2*MD],[Ax-PN,MD-0.4*MD],[Ax-PN,MD-0.6*MD],[Ax,MD-0.8*MD],[Ax,0],[0,0]]);
         polygon(points=[[Xdim-Ax,MD],[Xdim,MD],[Xdim,0],[Xdim-Ax,0],[Xdim-Ax,0.2*MD],[Xdim-Ax+PN,0.4*MD],[Xdim-Ax+PN,0.6*MD],[Xdim-Ax,0.8*MD],[Xdim-Ax,MD]]);
         polygon(points=[[x+FB,MD],[x+FB,MD-0.2*MD],[x+FB+PN,MD-0.4*MD],[x+FB+PN,MD-0.6*MD],[x+FB,MD-0.8*MD],[x+FB,MD-1.0*MD],[x+2*FB,MD-1.0*MD],[x+2*FB,MD-0.8*MD],[x+2*FB-PN,MD-0.6*MD],[x+2*FB-PN,MD-0.4*MD],[x+2*FB,MD-0.2*MD],[x+2*FB,MD]]);
         }
      }
         //Entfernungen Ydim1
    for (y = [Ay1:FB*2:Ydim1-Ay1]){
      
      //Nuten links
      if (SL==1)
         polygon(points=[[0,y+FB],[MD,y+FB],[MD,y],[0,y]]);
            
      if (SL==2)
         polygon(points=[[0,y+FB],[0.2*MD,y+FB],[0.4*MD,y+FB-PN],[0.6*MD,y+FB-PN],[0.8*MD,y+FB],[MD,y+FB],[MD,y],[0.2*MD,y],[0.4*MD,y+PN],[0.6*MD,y+PN],[0.8*MD,y],[0,y]]);   
      
      //Finger links und rechts
      if (SL==3)
         {
         polygon(points=[[0,Ydim1],[MD,Ydim1],[MD,Ydim1-Ay1],[0,Ydim1-Ay1]]);
         polygon(points=[[0,Ay1],[MD,Ay1],[MD,0],[0,0]]);
         polygon(points=[[0,y+2*FB],[MD,y+2*FB],[MD,y+FB],[0,y+FB]]);
         }

      if (SL==4)
         {
         polygon(points=[[0,Ydim1],[MD,Ydim1],[MD,Ydim1-Ay1],[0.8*MD,Ydim1-Ay1],[0.6*MD,Ydim1-Ay1+PN],[0.4*MD,Ydim1-Ay1+PN],[0.2*MD,Ydim1-Ay1],[0,Ydim1-Ay1]]);
         polygon(points=[[0,Ay1],[0.2*MD,Ay1],[0.4*MD,Ay1-PN],[0.6*MD,Ay1-PN],[0.8*MD,Ay1],[MD,Ay1],[MD,0],[0,0]]);
         polygon(points=[[0,y+2*FB],[0.2*MD,y+2*FB],[0.4*MD,y+2*FB-PN],[0.6*MD,y+2*FB-PN],[0.8*MD,y+2*FB],[1.0*MD,y+2*FB],[1.0*MD,y+FB],[0.8*MD,y+FB],[0.6*MD,y+FB+PN],[0.4*MD,y+FB+PN],[0.2*MD,y+FB],[0,y+FB]]);
         }
        
      }  


 for (y = [Ay2:FB*2:Ydim2-Ay2]){
      
      //Nuten rechts       
      if (SR==1)
         polygon(points=[[Xdim-MD,y+FB],[Xdim,y+FB],[Xdim,y],[Xdim-MD,y]]);
      
      if (SR==2)
         polygon(points=[[Xdim-MD,y+FB],[Xdim-MD+0.2*MD,y+FB],[Xdim-MD+0.4*MD,y+FB-PN],[Xdim-MD+0.6*MD,y+FB-PN],[Xdim-MD+0.8*MD,y+FB],[Xdim,y+FB],[Xdim,y],[Xdim-MD+0.2*MD,y],[Xdim-MD+0.4*MD,y+PN],[Xdim-MD+0.6*MD,y+PN],[Xdim-MD+0.8*MD,y],[Xdim-MD,y]]);         
      
      //Finger rechts

      if (SR==3)
         {
         polygon(points=[[Xdim-MD,Ydim2],[Xdim,Ydim2],[Xdim,Ydim2-Ay2],[Xdim-MD,Ydim2-Ay2]]);
         polygon(points=[[Xdim-MD,Ay2],[Xdim,Ay2],[Xdim,0],[Xdim-MD,0]]);
         polygon(points=[[Xdim-MD,y+2*FB],[Xdim,y+2*FB],[Xdim,y+FB],[Xdim-MD,y+FB]]);
         }
        
      if (SR==4)
         {
         polygon(points=[[Xdim-MD,Ydim2],[Xdim,Ydim2],[Xdim,Ydim2-Ay2],[Xdim-0.2*MD,Ydim2-Ay2],[Xdim-0.4*MD,Ydim2-Ay2+PN],[Xdim-0.6*MD,Ydim2-Ay2+PN],[Xdim-0.8*MD,Ydim2-Ay2],[Xdim-MD,Ydim2-Ay2]]);
         polygon(points=[[Xdim-MD,Ay2],[Xdim-MD+0.2*MD,Ay2],[Xdim-MD+0.4*MD,Ay2-PN],[Xdim-MD+0.6*MD,Ay2-PN],[Xdim-MD+0.8*MD,Ay2],[Xdim,Ay2],[Xdim,0],[Xdim-MD,0]]);
         polygon(points=[[Xdim-MD,y+2*FB],[Xdim-MD+0.2*MD,y+2*FB],[Xdim-MD+0.4*MD,y+2*FB-PN],[Xdim-MD+0.6*MD,y+2*FB-PN],[Xdim-MD+0.8*MD,y+2*FB],[Xdim-MD+1.0*MD,y+2*FB],[Xdim-MD+1.0*MD,y+FB],[Xdim-MD+0.8*MD,y+FB],[Xdim-MD+0.6*MD,y+FB+PN],[Xdim-MD+0.4*MD,y+FB+PN],[Xdim-MD+0.2*MD,y+FB],[Xdim-MD,y+FB]]);     
         }
	} 
}
       

}
module Bauteil (Xdim,Ydim,FB,MD,SO,SU,SL,SR){ 
difference()
{
    echo (Xdim,Ydim,FB,MD,SO,SU,SR,SL);
    FZx = round ((Xdim-FB)/(2*FB)-2);
    echo (FZx);
    Ax = (Xdim-(2*FZx*FB+FB))/2;
    echo (Ax);
    
    echo (Xdim,Ydim,FB,MD,SO,SU,SR,SL);
    FZy = round ((Ydim-FB)/(2*FB)-2);
    echo (FZy);
    Ay = (Ydim-(2*FZy*FB+FB))/2;
    echo (Ay);
    
    //Grundfläche
    polygon(points=[[0,Ydim],[Xdim,Ydim],[Xdim,0],[0,0]]);
    
    //von der Grundfläche werden Finger/Nuten entfernt
    
    //Entfernungen oben und unten
    for (x = [Ax:FB*2:Xdim-Ax])
      {
      
      //Nuten oben und unten   
      if (SO==1)
         polygon(points=[[x+0,Ydim],[x+FB,Ydim],[x+FB,Ydim-MD],[x+0,Ydim-MD]]);
     
      if (SU==1)
         polygon(points=[[x+0,MD],[x+FB,MD],[x+FB,0],[x+0,0]]);
      
      if (SO==2)
         polygon(points=[[x+0,Ydim],[x+FB,Ydim],[x+FB,Ydim-0.2*MD],[x+FB-PN,Ydim-0.4*MD],[x+FB-PN,Ydim-0.6*MD],[x+FB,Ydim-0.8*MD],[x+FB,Ydim-MD],[x+0,Ydim-MD],[x+0,Ydim-MD+0.2*MD],[x+0+PN,Ydim-MD+0.4*MD],[x+0+PN,Ydim-MD+0.6*MD],[x+0,Ydim-MD+0.8*MD], ]);
      
      if (SU==2)
         polygon(points=[[x+0,MD],[x+FB,MD],[x+FB,MD-0.2*MD],[x+FB-PN,MD-0.4*MD],[x+FB-PN,MD-0.6*MD],[x+FB,MD-0.8*MD],[x+FB,0],[x+0,0],[x,0+0.2*MD],[x+PN,0+0.4*MD],[x+PN,0+0.6*MD],[x,0+0.8*MD]]);
      
      
      //Finger oben und unten     
      if (SO==3)
         {
         polygon(points=[[0,Ydim],[Ax,Ydim],[Ax,Ydim-MD],[0,Ydim-MD]]);
         polygon(points=[[Xdim-Ax,Ydim],[Xdim,Ydim],[Xdim,Ydim-MD],[Xdim-Ax,Ydim-MD]]);
         polygon(points=[[x-FB,Ydim],[x,Ydim],[x,Ydim-MD],[x-FB,Ydim-MD]]);
         }   
      
      if (SU==3)
         {
         polygon(points=[[0,MD],[Ax,MD],[Ax,0],[0,0]]);
         polygon(points=[[Xdim-Ax,MD],[Xdim,MD],[Xdim,0],[Xdim-Ax,0]]);
         polygon(points=[[x-FB,MD],[x,MD],[x,0],[x-FB,0]]);
         }
 
      if (SO==4)
         {
         polygon(points=[[0,Ydim],[Ax,Ydim],[Ax,Ydim-0.2*MD],[Ax-PN,Ydim-0.4*MD],[Ax-PN,Ydim-0.6*MD],[Ax,Ydim-0.8*MD],[Ax,Ydim-MD],[0,Ydim-MD]]);
         polygon(points=[[Xdim-Ax,Ydim],[Xdim,Ydim],[Xdim,Ydim-MD],[Xdim-Ax,Ydim-MD],[Xdim-Ax,Ydim-MD+0.2*MD],[Xdim-Ax+PN,Ydim-MD+0.4*MD],[Xdim-Ax+PN,Ydim-MD+0.6*MD],[Xdim-Ax,Ydim-MD+0.8*MD]]);
         polygon(points=[[x+FB,Ydim],[x+FB,Ydim-0.2*MD],[x+FB+PN,Ydim-0.4*MD],[x+FB+PN,Ydim-0.6*MD],[x+FB,Ydim-0.8*MD],[x+FB,Ydim-1.0*MD],[x+2*FB,Ydim-1.0*MD],[x+2*FB,Ydim-0.8*MD],[x+2*FB-PN,Ydim-0.6*MD],[x+2*FB-PN,Ydim-0.4*MD],[x+2*FB,Ydim-0.2*MD],[x+2*FB,Ydim]]);
         }
        
      if (SU==4)
         {
         polygon(points=[[0,MD],[Ax,MD],[Ax,MD-0.2*MD],[Ax-PN,MD-0.4*MD],[Ax-PN,MD-0.6*MD],[Ax,MD-0.8*MD],[Ax,0],[0,0]]);
         polygon(points=[[Xdim-Ax,MD],[Xdim,MD],[Xdim,0],[Xdim-Ax,0],[Xdim-Ax,0.2*MD],[Xdim-Ax+PN,0.4*MD],[Xdim-Ax+PN,0.6*MD],[Xdim-Ax,0.8*MD],[Xdim-Ax,MD]]);
         polygon(points=[[x+FB,MD],[x+FB,MD-0.2*MD],[x+FB+PN,MD-0.4*MD],[x+FB+PN,MD-0.6*MD],[x+FB,MD-0.8*MD],[x+FB,MD-1.0*MD],[x+2*FB,MD-1.0*MD],[x+2*FB,MD-0.8*MD],[x+2*FB-PN,MD-0.6*MD],[x+2*FB-PN,MD-0.4*MD],[x+2*FB,MD-0.2*MD],[x+2*FB,MD]]);
         }
      }
    
    
    //Entfernungen links und rechts
    for (y = [Ay:FB*2:Ydim-Ay])  
      {
      
      //Nuten links und rechts 
      if (SL==1)
         polygon(points=[[0,y+FB],[MD,y+FB],[MD,y],[0,y]]);
      
      if (SR==1)
         polygon(points=[[Xdim-MD,y+FB],[Xdim,y+FB],[Xdim,y],[Xdim-MD,y]]);
      
      if (SL==2)
         polygon(points=[[0,y+FB],[0.2*MD,y+FB],[0.4*MD,y+FB-PN],[0.6*MD,y+FB-PN],[0.8*MD,y+FB],[MD,y+FB],[MD,y],[0.2*MD,y],[0.4*MD,y+PN],[0.6*MD,y+PN],[0.8*MD,y],[0,y]]);
      
      if (SR==2)
         polygon(points=[[Xdim-MD,y+FB],[Xdim-MD+0.2*MD,y+FB],[Xdim-MD+0.4*MD,y+FB-PN],[Xdim-MD+0.6*MD,y+FB-PN],[Xdim-MD+0.8*MD,y+FB],[Xdim,y+FB],[Xdim,y],[Xdim-MD+0.2*MD,y],[Xdim-MD+0.4*MD,y+PN],[Xdim-MD+0.6*MD,y+PN],[Xdim-MD+0.8*MD,y],[Xdim-MD,y]]);
           
      
      //Finger links und rechts
      if (SL==3)
         {
         polygon(points=[[0,Ydim],[MD,Ydim],[MD,Ydim-Ay],[0,Ydim-Ay]]);
         polygon(points=[[0,Ay],[MD,Ay],[MD,0],[0,0]]);
         polygon(points=[[0,y+2*FB],[MD,y+2*FB],[MD,y+FB],[0,y+FB]]);
         }
         
      if (SR==3)
         {
         polygon(points=[[Xdim-MD,Ydim],[Xdim,Ydim],[Xdim,Ydim-Ay],[Xdim-MD,Ydim-Ay]]);
         polygon(points=[[Xdim-MD,Ay],[Xdim,Ay],[Xdim,0],[Xdim-MD,0]]);
         polygon(points=[[Xdim-MD,y+2*FB],[Xdim,y+2*FB],[Xdim,y+FB],[Xdim-MD,y+FB]]);
         }
         
      if (SL==4)
         {
         polygon(points=[[0,Ydim],[MD,Ydim],[MD,Ydim-Ay],[0.8*MD,Ydim-Ay],[0.6*MD,Ydim-Ay+PN],[0.4*MD,Ydim-Ay+PN],[0.2*MD,Ydim-Ay],[0,Ydim-Ay]]);
         polygon(points=[[0,Ay],[0.2*MD,Ay],[0.4*MD,Ay-PN],[0.6*MD,Ay-PN],[0.8*MD,Ay],[MD,Ay],[MD,0],[0,0]]);
         polygon(points=[[0,y+2*FB],[0.2*MD,y+2*FB],[0.4*MD,y+2*FB-PN],[0.6*MD,y+2*FB-PN],[0.8*MD,y+2*FB],[1.0*MD,y+2*FB],[1.0*MD,y+FB],[0.8*MD,y+FB],[0.6*MD,y+FB+PN],[0.4*MD,y+FB+PN],[0.2*MD,y+FB],[0,y+FB]]);
         }
        
      if (SR==4)
         {
         polygon(points=[[Xdim-MD,Ydim],[Xdim,Ydim],[Xdim,Ydim-Ay],[Xdim-0.2*MD,Ydim-Ay],[Xdim-0.4*MD,Ydim-Ay+PN],[Xdim-0.6*MD,Ydim-Ay+PN],[Xdim-0.8*MD,Ydim-Ay],[Xdim-MD,Ydim-Ay]]);
         polygon(points=[[Xdim-MD,Ay],[Xdim-MD+0.2*MD,Ay],[Xdim-MD+0.4*MD,Ay-PN],[Xdim-MD+0.6*MD,Ay-PN],[Xdim-MD+0.8*MD,Ay],[Xdim,Ay],[Xdim,0],[Xdim-MD,0]]);
         polygon(points=[[Xdim-MD,y+2*FB],[Xdim-MD+0.2*MD,y+2*FB],[Xdim-MD+0.4*MD,y+2*FB-PN],[Xdim-MD+0.6*MD,y+2*FB-PN],[Xdim-MD+0.8*MD,y+2*FB],[Xdim-MD+1.0*MD,y+2*FB],[Xdim-MD+1.0*MD,y+FB],[Xdim-MD+0.8*MD,y+FB],[Xdim-MD+0.6*MD,y+FB+PN],[Xdim-MD+0.4*MD,y+FB+PN],[Xdim-MD+0.2*MD,y+FB],[Xdim-MD,y+FB]]);     
         }
      }  
}
}

module BauteilDeckel (Xdim,Ydim,FB,MD,SO,SU,SL,SR){ 
difference()
{
    echo (Xdim,Ydim,FB,MD,SO,SU,SR,SL);
    FZx = round ((Xdim-FB)/(2*FB)-2);
    echo (FZx);
    Ax = (Xdim-(2*FZx*FB+FB))/2;
    echo (Ax);
    
    echo (Xdim,Ydim,FB,MD,SO,SU,SR,SL);
    FZy = round ((Ydim-FB)/(2*FB)-2);
    echo (FZy);
    Ay = (Ydim-(2*FZy*FB+FB))/2;
    echo (Ay);
    
    //Grundfläche
    polygon(points=[[0,Ydim],[Xdim,Ydim],[Xdim,0],[0,0]]);
    
    //von der Grundfläche werden Finger/Nuten entfernt
    
    //Entfernungen oben und unten
    for (x = [Ax:FB*2:Xdim-Ax])
      {
      
      //Nuten oben und unten   
      if (SO==1)
         polygon(points=[[x+0,Ydim],[x+FB,Ydim],[x+FB,Ydim-MD],[x+0,Ydim-MD]]);
     
      if (SU==1)
         polygon(points=[[x+0,MD],[x+FB,MD],[x+FB,0],[x+0,0]]);
      
      if (SO==2)
         polygon(points=[[x+0,Ydim],[x+FB,Ydim],[x+FB,Ydim-0.2*MD],[x+FB-PN,Ydim-0.4*MD],[x+FB-PN,Ydim-0.6*MD],[x+FB,Ydim-0.8*MD],[x+FB,Ydim-MD],[x+0,Ydim-MD],[x+0,Ydim-MD+0.2*MD],[x+0+PN,Ydim-MD+0.4*MD],[x+0+PN,Ydim-MD+0.6*MD],[x+0,Ydim-MD+0.8*MD], ]);
      
      if (SU==2)
         polygon(points=[[x+0,MD],[x+FB,MD],[x+FB,MD-0.2*MD],[x+FB-PN,MD-0.4*MD],[x+FB-PN,MD-0.6*MD],[x+FB,MD-0.8*MD],[x+FB,0],[x+0,0],[x,0+0.2*MD],[x+PN,0+0.4*MD],[x+PN,0+0.6*MD],[x,0+0.8*MD]]);
      
      
      //Finger oben und unten     
      if (SO==3)
         {
         polygon(points=[[0,Ydim],[Ax,Ydim],[Ax,Ydim-MD],[0,Ydim-MD]]);
         polygon(points=[[Xdim-Ax,Ydim],[Xdim,Ydim],[Xdim,Ydim-MD],[Xdim-Ax,Ydim-MD]]);
         polygon(points=[[x-FB,Ydim],[x,Ydim],[x,Ydim-MD],[x-FB,Ydim-MD]]);
         }   
      
      if (SU==3)
         {
         polygon(points=[[0,MD],[Ax,MD],[Ax,0],[0,0]]);
         polygon(points=[[Xdim-Ax,MD],[Xdim,MD],[Xdim,0],[Xdim-Ax,0]]);
         polygon(points=[[x-FB,MD],[x,MD],[x,0],[x-FB,0]]);
         }
 
      if (SO==4)
         {
         polygon(points=[[0,Ydim],[Ax,Ydim],[Ax,Ydim-0.2*MD],[Ax-PN,Ydim-0.4*MD],[Ax-PN,Ydim-0.6*MD],[Ax,Ydim-0.8*MD],[Ax,Ydim-MD],[0,Ydim-MD]]);
         polygon(points=[[Xdim-Ax,Ydim],[Xdim,Ydim],[Xdim,Ydim-MD],[Xdim-Ax,Ydim-MD],[Xdim-Ax,Ydim-MD+0.2*MD],[Xdim-Ax+PN,Ydim-MD+0.4*MD],[Xdim-Ax+PN,Ydim-MD+0.6*MD],[Xdim-Ax,Ydim-MD+0.8*MD]]);
         polygon(points=[[x+FB,Ydim],[x+FB,Ydim-0.2*MD],[x+FB+PN,Ydim-0.4*MD],[x+FB+PN,Ydim-0.6*MD],[x+FB,Ydim-0.8*MD],[x+FB,Ydim-1.0*MD],[x+2*FB,Ydim-1.0*MD],[x+2*FB,Ydim-0.8*MD],[x+2*FB-PN,Ydim-0.6*MD],[x+2*FB-PN,Ydim-0.4*MD],[x+2*FB,Ydim-0.2*MD],[x+2*FB,Ydim]]);
         }
        
      if (SU==4)
         {
         polygon(points=[[0,MD],[Ax,MD],[Ax,MD-0.2*MD],[Ax-PN,MD-0.4*MD],[Ax-PN,MD-0.6*MD],[Ax,MD-0.8*MD],[Ax,0],[0,0]]);
         polygon(points=[[Xdim-Ax,MD],[Xdim,MD],[Xdim,0],[Xdim-Ax,0],[Xdim-Ax,0.2*MD],[Xdim-Ax+PN,0.4*MD],[Xdim-Ax+PN,0.6*MD],[Xdim-Ax,0.8*MD],[Xdim-Ax,MD]]);
         polygon(points=[[x+FB,MD],[x+FB,MD-0.2*MD],[x+FB+PN,MD-0.4*MD],[x+FB+PN,MD-0.6*MD],[x+FB,MD-0.8*MD],[x+FB,MD-1.0*MD],[x+2*FB,MD-1.0*MD],[x+2*FB,MD-0.8*MD],[x+2*FB-PN,MD-0.6*MD],[x+2*FB-PN,MD-0.4*MD],[x+2*FB,MD-0.2*MD],[x+2*FB,MD]]);
         }
      }
    
    
    //Entfernungen links und rechts
    for (y = [Ay:FB*2:Ydim-Ay])  
      {
      
      //Nuten links und rechts 
      if (SL==1)
         polygon(points=[[0,y+FB],[MD,y+FB],[MD,y],[0,y]]);
      
      if (SR==1)
         polygon(points=[[Xdim-MD-VorneKuerzen,y+FB],[Xdim,y+FB],[Xdim,y],[Xdim-MD-VorneKuerzen,y]]);
      
      if (SL==2)
         polygon(points=[[0,y+FB],[0.2*MD,y+FB],[0.4*MD,y+FB-PN],[0.6*MD,y+FB-PN],[0.8*MD,y+FB],[MD,y+FB],[MD,y],[0.2*MD,y],[0.4*MD,y+PN],[0.6*MD,y+PN],[0.8*MD,y],[0,y]]);
      
      if (SR==2)
         polygon(points=[[Xdim-MD,y+FB],[Xdim-MD+0.2*MD,y+FB],[Xdim-MD+0.4*MD,y+FB-PN],[Xdim-MD+0.6*MD,y+FB-PN],[Xdim-MD+0.8*MD,y+FB],[Xdim,y+FB],[Xdim,y],[Xdim-MD+0.2*MD,y],[Xdim-MD+0.4*MD,y+PN],[Xdim-MD+0.6*MD,y+PN],[Xdim-MD+0.8*MD,y],[Xdim-MD,y]]);
           
      
      //Finger links und rechts
      if (SL==3)
         {
         polygon(points=[[0,Ydim],[MD,Ydim],[MD,Ydim-Ay],[0,Ydim-Ay]]);
         polygon(points=[[0,Ay],[MD,Ay],[MD,0],[0,0]]);
         polygon(points=[[0,y+2*FB],[MD,y+2*FB],[MD,y+FB],[0,y+FB]]);
         }
         
      if (SR==3)
         {
         polygon(points=[[Xdim-MD-VorneKuerzen,Ydim],[Xdim,Ydim],[Xdim,Ydim-Ay],[Xdim-MD-VorneKuerzen,Ydim-Ay]]);
         polygon(points=[[Xdim-MD-VorneKuerzen,Ay],[Xdim,Ay],[Xdim,0],[Xdim-MD-VorneKuerzen,0]]);
         polygon(points=[[Xdim-MD-VorneKuerzen,y+2*FB],[Xdim,y+2*FB],[Xdim,y+FB],[Xdim-MD-VorneKuerzen,y+FB]]);
         }
         
      if (SL==4)
         {
         polygon(points=[[0,Ydim],[MD,Ydim],[MD,Ydim-Ay],[0.8*MD,Ydim-Ay],[0.6*MD,Ydim-Ay+PN],[0.4*MD,Ydim-Ay+PN],[0.2*MD,Ydim-Ay],[0,Ydim-Ay]]);
         polygon(points=[[0,Ay],[0.2*MD,Ay],[0.4*MD,Ay-PN],[0.6*MD,Ay-PN],[0.8*MD,Ay],[MD,Ay],[MD,0],[0,0]]);
         polygon(points=[[0,y+2*FB],[0.2*MD,y+2*FB],[0.4*MD,y+2*FB-PN],[0.6*MD,y+2*FB-PN],[0.8*MD,y+2*FB],[1.0*MD,y+2*FB],[1.0*MD,y+FB],[0.8*MD,y+FB],[0.6*MD,y+FB+PN],[0.4*MD,y+FB+PN],[0.2*MD,y+FB],[0,y+FB]]);
         }
        
      if (SR==4)
         {
         polygon(points=[[Xdim-MD,Ydim],[Xdim,Ydim],[Xdim,Ydim-Ay],[Xdim-0.2*MD,Ydim-Ay],[Xdim-0.4*MD,Ydim-Ay+PN],[Xdim-0.6*MD,Ydim-Ay+PN],[Xdim-0.8*MD,Ydim-Ay],[Xdim-MD,Ydim-Ay]]);
         polygon(points=[[Xdim-MD,Ay],[Xdim-MD+0.2*MD,Ay],[Xdim-MD+0.4*MD,Ay-PN],[Xdim-MD+0.6*MD,Ay-PN],[Xdim-MD+0.8*MD,Ay],[Xdim,Ay],[Xdim,0],[Xdim-MD,0]]);
         polygon(points=[[Xdim-MD,y+2*FB],[Xdim-MD+0.2*MD,y+2*FB],[Xdim-MD+0.4*MD,y+2*FB-PN],[Xdim-MD+0.6*MD,y+2*FB-PN],[Xdim-MD+0.8*MD,y+2*FB],[Xdim-MD+1.0*MD,y+2*FB],[Xdim-MD+1.0*MD,y+FB],[Xdim-MD+0.8*MD,y+FB],[Xdim-MD+0.6*MD,y+FB+PN],[Xdim-MD+0.4*MD,y+FB+PN],[Xdim-MD+0.2*MD,y+FB],[Xdim-MD,y+FB]]);     
         }
      }  
}
}


module BauteilVorne (Xdim,Ydim,FB,MD,SO,SU,SL,SR){ 
difference()
{
    echo (Xdim,Ydim,FB,MD,SO,SU,SR,SL);
    FZx = round ((Xdim-FB)/(2*FB)-2);
    echo (FZx);
    Ax = (Xdim-(2*FZx*FB+FB))/2;
    echo (Ax);
    
    echo (Xdim,Ydim,FB,MD,SO,SU,SR,SL);
    FZy = round ((Ydim-FB)/(2*FB)-2);
    echo (FZy);
    Ay = (Ydim-(2*FZy*FB+FB))/2;
    echo (Ay);
    
    //Grundfläche
    polygon(points=[[0,Ydim],[Xdim,Ydim],[Xdim,0],[0,0]]);
    
    //von der Grundfläche werden Finger/Nuten entfernt
    
    //Entfernungen oben und unten
    for (x = [Ax:FB*2:Xdim-Ax])
      {
      
      //Nuten oben und unten   
      if (SO==1)
         polygon(points=[[x+0,Ydim],[x+FB,Ydim],[x+FB,Ydim-MD],[x+0,Ydim-MD]]);
     
      if (SU==1)
         polygon(points=[[x+0,MD],[x+FB,MD],[x+FB,0],[x+0,0]]);
      
      if (SO==2)
         polygon(points=[[x+0,Ydim],[x+FB,Ydim],[x+FB,Ydim-0.2*MD],[x+FB-PN,Ydim-0.4*MD],[x+FB-PN,Ydim-0.6*MD],[x+FB,Ydim-0.8*MD],[x+FB,Ydim-MD],[x+0,Ydim-MD],[x+0,Ydim-MD+0.2*MD],[x+0+PN,Ydim-MD+0.4*MD],[x+0+PN,Ydim-MD+0.6*MD],[x+0,Ydim-MD+0.8*MD], ]);
      
      if (SU==2)
         polygon(points=[[x+0,MD],[x+FB,MD],[x+FB,MD-0.2*MD],[x+FB-PN,MD-0.4*MD],[x+FB-PN,MD-0.6*MD],[x+FB,MD-0.8*MD],[x+FB,0],[x+0,0],[x,0+0.2*MD],[x+PN,0+0.4*MD],[x+PN,0+0.6*MD],[x,0+0.8*MD]]);
      
      
      //Finger oben und unten     
      if (SO==3)
         {
         polygon(points=[[0,Ydim],[Ax,Ydim],[Ax,Ydim-MD],[0,Ydim-MD]]);
         polygon(points=[[Xdim-Ax,Ydim],[Xdim,Ydim],[Xdim,Ydim-MD],[Xdim-Ax,Ydim-MD]]);
         polygon(points=[[x-FB,Ydim],[x,Ydim],[x,Ydim-MD],[x-FB,Ydim-MD]]);
         }   
      
      if (SU==3)
         {
         polygon(points=[[0,MD],[Ax,MD],[Ax,0],[0,0]]);
         polygon(points=[[Xdim-Ax,MD],[Xdim,MD],[Xdim,0],[Xdim-Ax,0]]);
         polygon(points=[[x-FB,MD],[x,MD],[x,0],[x-FB,0]]);
         }
 
      if (SO==4)
         {
         polygon(points=[[0,Ydim],[Ax,Ydim],[Ax,Ydim-0.2*MD],[Ax-PN,Ydim-0.4*MD],[Ax-PN,Ydim-0.6*MD],[Ax,Ydim-0.8*MD],[Ax,Ydim-MD],[0,Ydim-MD]]);
         polygon(points=[[Xdim-Ax,Ydim],[Xdim,Ydim],[Xdim,Ydim-MD],[Xdim-Ax,Ydim-MD],[Xdim-Ax,Ydim-MD+0.2*MD],[Xdim-Ax+PN,Ydim-MD+0.4*MD],[Xdim-Ax+PN,Ydim-MD+0.6*MD],[Xdim-Ax,Ydim-MD+0.8*MD]]);
         polygon(points=[[x+FB,Ydim],[x+FB,Ydim-0.2*MD],[x+FB+PN,Ydim-0.4*MD],[x+FB+PN,Ydim-0.6*MD],[x+FB,Ydim-0.8*MD],[x+FB,Ydim-1.0*MD],[x+2*FB,Ydim-1.0*MD],[x+2*FB,Ydim-0.8*MD],[x+2*FB-PN,Ydim-0.6*MD],[x+2*FB-PN,Ydim-0.4*MD],[x+2*FB,Ydim-0.2*MD],[x+2*FB,Ydim]]);
         }
        
      if (SU==4)
         {
         polygon(points=[[0,MD],[Ax,MD],[Ax,MD-0.2*MD],[Ax-PN,MD-0.4*MD],[Ax-PN,MD-0.6*MD],[Ax,MD-0.8*MD],[Ax,0],[0,0]]);
         polygon(points=[[Xdim-Ax,MD],[Xdim,MD],[Xdim,0],[Xdim-Ax,0],[Xdim-Ax,0.2*MD],[Xdim-Ax+PN,0.4*MD],[Xdim-Ax+PN,0.6*MD],[Xdim-Ax,0.8*MD],[Xdim-Ax,MD]]);
         polygon(points=[[x+FB,MD],[x+FB,MD-0.2*MD],[x+FB+PN,MD-0.4*MD],[x+FB+PN,MD-0.6*MD],[x+FB,MD-0.8*MD],[x+FB,MD-1.0*MD],[x+2*FB,MD-1.0*MD],[x+2*FB,MD-0.8*MD],[x+2*FB-PN,MD-0.6*MD],[x+2*FB-PN,MD-0.4*MD],[x+2*FB,MD-0.2*MD],[x+2*FB,MD]]);
         }
      }
    
    
    //Entfernungen links und rechts
    for (y = [Ay:FB*2:Ydim-Ay])  
      {
      
      //Nuten links und rechts 
      if (SL==1)
         polygon(points=[[0,y+FB],[MD,y+FB],[MD,y],[0,y]]);
      
      if (SR==1)
         polygon(points=[[Xdim-MD,y+FB],[Xdim,y+FB],[Xdim,y],[Xdim-MD,y]]);
      
      if (SL==2)
         polygon(points=[[0,y+FB],[0.2*MD,y+FB],[0.4*MD,y+FB-PN],[0.6*MD,y+FB-PN],[0.8*MD,y+FB],[MD,y+FB],[MD,y],[0.2*MD,y],[0.4*MD,y+PN],[0.6*MD,y+PN],[0.8*MD,y],[0,y]]);
      
      if (SR==2)
         polygon(points=[[Xdim-MD,y+FB],[Xdim-MD+0.2*MD,y+FB],[Xdim-MD+0.4*MD,y+FB-PN],[Xdim-MD+0.6*MD,y+FB-PN],[Xdim-MD+0.8*MD,y+FB],[Xdim,y+FB],[Xdim,y],[Xdim-MD+0.2*MD,y],[Xdim-MD+0.4*MD,y+PN],[Xdim-MD+0.6*MD,y+PN],[Xdim-MD+0.8*MD,y],[Xdim-MD,y]]);
           
      
      //Finger links und rechts
      if (SL==3)
         {
         polygon(points=[[0,Ydim],[MD+VorneKuerzen,Ydim],[MD+VorneKuerzen,Ydim-Ay],[0,Ydim-Ay]]);
         polygon(points=[[0,Ay],[MD+VorneKuerzen,Ay],[MD+VorneKuerzen,0],[0,0]]);
         polygon(points=[[0,y+2*FB],[MD+VorneKuerzen,y+2*FB],[MD+VorneKuerzen,y+FB],[0,y+FB]]);
         }
         
      if (SR==3)
         {
         polygon(points=[[Xdim-MD,Ydim],[Xdim,Ydim],[Xdim,Ydim-Ay],[Xdim-MD,Ydim-Ay]]);
         polygon(points=[[Xdim-MD,Ay],[Xdim,Ay],[Xdim,0],[Xdim-MD,0]]);
         polygon(points=[[Xdim-MD,y+2*FB],[Xdim,y+2*FB],[Xdim,y+FB],[Xdim-MD,y+FB]]);
         }
         
      if (SL==4)
         {
         polygon(points=[[0,Ydim],[MD,Ydim],[MD,Ydim-Ay],[0.8*MD,Ydim-Ay],[0.6*MD,Ydim-Ay+PN],[0.4*MD,Ydim-Ay+PN],[0.2*MD,Ydim-Ay],[0,Ydim-Ay]]);
         polygon(points=[[0,Ay],[0.2*MD,Ay],[0.4*MD,Ay-PN],[0.6*MD,Ay-PN],[0.8*MD,Ay],[MD,Ay],[MD,0],[0,0]]);
         polygon(points=[[0,y+2*FB],[0.2*MD,y+2*FB],[0.4*MD,y+2*FB-PN],[0.6*MD,y+2*FB-PN],[0.8*MD,y+2*FB],[1.0*MD,y+2*FB],[1.0*MD,y+FB],[0.8*MD,y+FB],[0.6*MD,y+FB+PN],[0.4*MD,y+FB+PN],[0.2*MD,y+FB],[0,y+FB]]);
         }
        
      if (SR==4)
         {
         polygon(points=[[Xdim-MD,Ydim],[Xdim,Ydim],[Xdim,Ydim-Ay],[Xdim-0.2*MD,Ydim-Ay],[Xdim-0.4*MD,Ydim-Ay+PN],[Xdim-0.6*MD,Ydim-Ay+PN],[Xdim-0.8*MD,Ydim-Ay],[Xdim-MD,Ydim-Ay]]);
         polygon(points=[[Xdim-MD,Ay],[Xdim-MD+0.2*MD,Ay],[Xdim-MD+0.4*MD,Ay-PN],[Xdim-MD+0.6*MD,Ay-PN],[Xdim-MD+0.8*MD,Ay],[Xdim,Ay],[Xdim,0],[Xdim-MD,0]]);
         polygon(points=[[Xdim-MD,y+2*FB],[Xdim-MD+0.2*MD,y+2*FB],[Xdim-MD+0.4*MD,y+2*FB-PN],[Xdim-MD+0.6*MD,y+2*FB-PN],[Xdim-MD+0.8*MD,y+2*FB],[Xdim-MD+1.0*MD,y+2*FB],[Xdim-MD+1.0*MD,y+FB],[Xdim-MD+0.8*MD,y+FB],[Xdim-MD+0.6*MD,y+FB+PN],[Xdim-MD+0.4*MD,y+FB+PN],[Xdim-MD+0.2*MD,y+FB],[Xdim-MD,y+FB]]);     
         }
      }  
}
}
