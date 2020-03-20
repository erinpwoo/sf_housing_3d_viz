/*  Final 3D Project - SF Evictions by Neighborhood - by Erin Woo
    MAT 259A - Winter 2020
    
    Data Sources:
    Displacement and Gentrification Data (2017): https://www.urbandisplacement.org/map/sf
    Eviction Data: https://data.sfgov.org/Housing-and-Buildings/Eviction-Notices/5cei-gny5
    FCC Census Block/Area FIPS API: https://anypoint.mulesoft.com/exchange/portals/fccdomain/55a35f65-7efa-42af-98af-41ae37d824b2/area-and-census-block/
    
    Description:
    This data visualization shows eviction data in San Francisco from the years 1997 to present. Each point represents a single eviction.
    The x and y coordinates of each point correspond to the points longitude and latitude mapping values, while it's position in the z-axis corresponds to the date of the eviction.
    Each color corresponds to a different neighborhood in San Francisco. A group of evictions in the same neighborhood occuring in the same year are connected by a single polygon shape.
    Some points may not be connected by a polygon, as the edges are only drawn between every 10 points (to speed up the graphics, since there are ~40,000 data points).
    The transparency of the polygon corresponds to the gentrification status of the area as of 2017. The more advanced the gentrification, the higher the polygon's opacity. More information on this typology can be found at www.urbandisplacement.org.
    
    To navigate through the sketch:
    Scroll down to zoom in and scroll up to zoom out.
    Click and drag in the direction you'd like to rotate the sketch.
    Hovering over a data point reveals more information about the eviction, such as the address, date, and gentrification typology of the area as of 2017.
*/

import peasy.*;
import javafx.util.Pair;
import java.util.*;
PeasyCam cam;
Table evic_table;
Table gen_table;
int evic_row_ct;
int gen_row_ct;
double max_lon, max_lat, min_lon, min_lat;
HashMap<String, String> geo_fips;
HashMap<String, ArrayList<Eviction>> evic_map = new HashMap<String, ArrayList<Eviction>>();
int maxCount;
int minCount;

void setup() {
  size(1200, 600, P3D);
  setupCamera();
  smooth();
  evic_table = loadTable("Evictions_fips.csv", "header");
  gen_table = loadTable("udp_2017.csv", "header");

  evic_row_ct = evic_table.getRowCount();
  gen_row_ct = gen_table.getRowCount();
  geo_fips = new HashMap<String, String>();

  for (int i = 0; i < gen_row_ct; i++) {
    geo_fips.put(gen_table.getString(i, 0), gen_table.getString(i, 1));
  }

  max_lon = -Double.MAX_VALUE;
  max_lat = -Double.MAX_VALUE;
  min_lon = Double.MAX_VALUE;
  min_lat = Double.MAX_VALUE;
  
  maxCount = Integer.MIN_VALUE;
  minCount = Integer.MAX_VALUE;

  for (int i = 0; i < evic_row_ct; i++) {
    if ((evic_table.getString(i, 29).length() > 0)) {
      Pair<Double, Double> loc = parseLoc(evic_table.getString(i, 29));
      String area = evic_table.getString(i, 28);
      String addr = evic_table.getString(i, 2);
      String fips = evic_table.getString(i, 44);
      
      // parsing date
      String[] date = split(evic_table.getString(i, 6), '-');
      int month = Integer.parseInt(date[0]);
      int day = Integer.parseInt(date[1]);
      int year = Integer.parseInt(date[2]);
      int[] parsedDate = {month, day, year};
      
      int date_num = ((year - 1996)*365 +  (month *  30) + day)*5;
      if (loc.getKey() > max_lon) {
        max_lon = loc.getKey();
      }
      if (loc.getKey() < min_lon) {
        min_lon = loc.getKey();
      }
      if (loc.getValue() > max_lat) {
        max_lat = loc.getValue();
      }
      if (loc.getValue() < min_lat) {
        min_lat = loc.getValue();
      }
      if (fips != null) {
        Eviction e = new Eviction(loc.getKey(), loc.getValue(), parsedDate, area, addr, geo_fips.get(fips), fips, date_num);
        ArrayList<Eviction> prev = evic_map.get(area);
        if (prev == null) {
          prev = new ArrayList<Eviction>();
          //print(area + "(" + fips + ")" + ": " + geo_fips.get(fips)+"\t");
        }
        prev.add(e);
        evic_map.put(area, prev); 
      }
    }
  }
  
  Iterator itr = evic_map.entrySet().iterator();
  while (itr.hasNext()) {
    ArrayList<Eviction> evic = (ArrayList<Eviction>)((Map.Entry)itr.next()).getValue();
    if (evic.size() > maxCount) {
      maxCount = evic.size(); 
    }
    if (evic.size() < minCount) {
      minCount = evic.size(); 
    }
  }
}

void draw() {
  background(0);
  noStroke();
  fill(200, 20);
  translate(width/2, height/2);
  Iterator itr = evic_map.entrySet().iterator();
  while (itr.hasNext()) {
    ArrayList<Eviction> evic = (ArrayList<Eviction>)((Map.Entry)itr.next()).getValue();
    drawEdges(evic);
  }
  drawLabels();
  drawData();
  updateCam();
}

void drawData() {
  Iterator itr = evic_map.entrySet().iterator();
  while (itr.hasNext()) {
    ArrayList<Eviction> evic = (ArrayList<Eviction>)((Map.Entry)itr.next()).getValue();
    for (Eviction e : evic) {
      drawPoint(e);
    }
  }
}

void drawEdges(ArrayList<Eviction> e) {
  strokeWeight(.1);
  int[] colors = getColorForArea(e.get(0));
  color c = color(colors[0],colors[1],colors[2], chooseAlpha(e.get(0)));
  fill(c);
  stroke(c);
  beginShape();
  for (int i = 0; i < e.size(); i++) {
     float lon = map((float)e.get(i).lon, (float)min_lon, (float)max_lon, -3000.0, 3000.0);
     float lat =  map((float)e.get(i).lat, (float)min_lat, (float)max_lat, -3000.0, 3000.0); 
      
     // drawing new polygon when year changes
     if (i > 0) {
       if (e.get(i).date[2] != e.get(i-1).date[2]) {
         endShape(CLOSE);
         beginShape();
       }
     }
     
     if (i % 10 == 0) curveVertex(lon, lat, e.get(i).date_num);
   }
  endShape(CLOSE);
}

Pair<Double, Double> parseLoc(String in) {
  String str = in.substring(7, in.length()-1);
  String[] s = str.split(" ");
  return new Pair<Double, Double>(Double.parseDouble(s[0]), Double.parseDouble(s[1]));
}

int chooseAlpha(Eviction e) {
  if (e.gen_status == null) return 10;
  switch (e.gen_status) {
    case "LI - Not Losing Low Income Households":
      return 30 ;
    case "LI - At Risk of Gentrification and/or Displacement":
      return 60;
    case "LI - Ongoing Gentrification and/or Displacement":
      return 90;
    case "MHI - Advanced Gentrification":
      return 120;
    case "MHI - Not Losing Low Income Households":
      return 150;
    case "MHI - At Risk of Exclusion":
      return 180;
    case "MHI - Ongoing Exclusion":
      return 210;
    case "MHI - Advanced Exclusion":
      return 240;
    default:
      return 10;
  }
}

void drawLabels() {
  for (int i = 1997; i < 2021; i++) {
    int date_num = ((i - 1996)*365)*5;
    pushMatrix();
    textSize(300);
    fill(255);
    text(str(i), -3000, -3000, date_num);
    noFill();
    popMatrix();
  }
}

void popup(Eviction e) {
   cam.beginHUD();
   noStroke();
   fill(0);
   rect(50,50, 350,200, 2);
   textSize(16);
   fill(255,255,255);
   text("Date: " + e.date[0] + "/" + e.date[1] + "/" + e.date[2] + "\nAddress: " + e.addr + "\nArea: " + e.area + "\nDisplacement/Gentrification Typology: " + e.gen_status, 60, 60, 300, 200);
   stroke(255, 255, 255);
   cam.endHUD();
}

void setupCamera () {
  float fov      = PI/3;  // field of view
  float nearClip = 1;
  float farClip  = 100000;
  float aspect   = float(width)/float(height);  
  perspective(fov, aspect, nearClip, farClip);  
  cam = new PeasyCam(this, 1300, -2000, 35000, 0);
}

void updateCam () {
  float fov      = PI/3;  // field of view
  float nearClip = 1;
  float farClip  = 50000;
  float aspect   = float(width)/float(height);  
  perspective(fov, aspect, nearClip, farClip);
}