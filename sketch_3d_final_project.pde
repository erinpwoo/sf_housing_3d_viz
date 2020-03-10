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
  drawData();
  translate(width/2, height/2);
  Iterator itr = evic_map.entrySet().iterator();
  while (itr.hasNext()) {
    ArrayList<Eviction> evic = (ArrayList<Eviction>)((Map.Entry)itr.next()).getValue();
    drawEdges(evic);
  }
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
    if (i % 10 == 0) {
      float lon = map((float)e.get(i).lon, (float)min_lon, (float)max_lon, -3000.0, 3000.0);
      float lat =  map((float)e.get(i).lat, (float)min_lat, (float)max_lat, -3000.0, 3000.0); 
      vertex(lon,lat, e.get(i).date_num);
    }
  }
  endShape();
}

Pair<Double, Double> parseLoc(String in) {
  String str = in.substring(7, in.length()-1);
  String[] s = str.split(" ");
  return new Pair<Double, Double>(Double.parseDouble(s[0]), Double.parseDouble(s[1]));
}

int chooseAlpha(Eviction e) {
  switch (e.gen_status) {
    case "LI - Not Losing Low Income Households":
      return 30;
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

void popup(Eviction e) {
   cam.beginHUD();
   noStroke();
   fill(255,255,255);
   textSize(12.5);
   rect(50,50, 300,150, 2);
   fill(0,0,0);
   text("Date: " + e.date[0] + "/" + e.date[1] + "/" + e.date[2] + "\nAddress: " + e.addr + "\nArea: " + e.area + "\nDisplacement/Gentrification Typology: " + e.gen_status, 60, 60, 280, 140);
   stroke(255,255,255);
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