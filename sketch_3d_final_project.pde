import peasy.*;
import javafx.util.Pair;
import java.util.*;
PeasyCam cam;
Table evic_table;
Table gen_table;
int evic_row_ct;
int gen_row_ct;
double max_lon, max_lat, min_lon, min_lat;
String url = "https://geo.fcc.gov/api/census/area?";
HashMap<String, String> geo_fips;
HashMap<String, ArrayList<Eviction>> evic_map = new HashMap<String, ArrayList<Eviction>>();

void setup() {
  size(1200, 600, P3D);
  cam = new PeasyCam(this, 10);
  cam.setDistance(3000);
  smooth();
  evic_table = loadTable("Evictions_fips.csv", "header");
  gen_table = loadTable("udp_2017results.csv", "header");

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

  for (int i = 0; i < evic_row_ct; i++) {
    if ((evic_table.getString(i, 29).length() > 0)) {
      Pair<Double, Double> loc = parseLoc(evic_table.getString(i, 29));
      String area = evic_table.getString(i, 28);
      String addr = evic_table.getString(i, 2);
      // parsing date
      String[] date = split(evic_table.getString(i, 6), '-');
      int month = Integer.parseInt(date[0]);
      int day = Integer.parseInt(date[1]);
      int year = Integer.parseInt(date[2]);
      int[] parsedDate = {month, day, year};
      
      int date_num = (year - 1996)*365 +  (month *  30) + day;
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

      Eviction e = new Eviction(loc.getKey(), loc.getValue(), parsedDate, area, addr, geo_fips.get(" "), " ", date_num);
      ArrayList<Eviction> prev = evic_map.get(area);
      if (prev == null) {
        prev = new ArrayList<Eviction>();
      }
      prev.add(e);
      evic_map.put(area, prev);
    }
  }
}

void draw() {
  background(0);
  noStroke();
  fill(200, 20);
  drawData();
  
  Iterator itr = evic_map.entrySet().iterator();
  while (itr.hasNext()) {
    ArrayList<Eviction> evic = (ArrayList<Eviction>)((Map.Entry)itr.next()).getValue();
    drawEdges(evic);
  }
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
  beginShape();
  for (Eviction evic: e) {
    float lon = map((float)evic.lon, (float)min_lon, (float)max_lon, -3000.0, 3000.0);
    float lat =  map((float)evic.lat, (float)min_lat, (float)max_lat, -3000.0, 3000.0); 
    pushMatrix();
    translate(lon, lat, evic.date_num);
    vertex(0,0,0);
    popMatrix();
  }
  endShape();
}

Pair<Double, Double> parseLoc(String in) {
  String str = in.substring(7, in.length()-1);
  String[] s = str.split(" ");
  return new Pair<Double, Double>(Double.parseDouble(s[0]), Double.parseDouble(s[1]));
}