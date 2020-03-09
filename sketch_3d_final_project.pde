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
int maxCount;
int minCount;

int[] getColorForArea(Eviction e) {
  int[] colors;
  switch (e.area) {
    case "Tenderloin":
      colors = new int[] {168,14,47};
      break;
    case "West of Twin Peaks":
      colors = new int[] {189,200,122};
      break;
    case "Mission Bay":
      colors = new int[] {158,14,112};
      break;
    case "Outer Richmond":
      colors = new int[] {43,79,34};
      break;
    case "Pacific Heights":
      colors = new int[] {85,172,12};
      break;
    case "Noe Valley":
      colors = new int[] {93,190,178};
      break;
    case "Nob Hill":
      colors = new int[] {36,56,210};
      break;
    case "Visitacion Valley":
      colors = new int[] {168,27,109};
      break;
    case "Glen Park":
      colors = new int[] {235,103,129};
      break;
    case "castro/Upper Market":
      colors = new int[] {137,94,105};
      break;
    case "Presidio":
      colors = new int[] {168,54,31};
      break;
    case "Seacliff":
      colors = new int[] {134,118,79};
      break;
    case "Bayview":
      colors = new int[] {1,212,182};
      break;
    case "Hunters Point":
      colors = new int[] {218,146,35};
      break;
    case "Excelsior":
      colors = new int[] {42,71,47};
      break;
    case "Chinatown":
      colors = new int[] {57,101,182};
      break;
    case "Lincoln Park":
      colors = new int[] {183,232,227};
      break;
    case "Mission":
      colors = new int[] {3,101,158};
      break;
    case "Bernal Heights":
      colors = new int[] {67,96,123};
      break;
    case "Twin Peaks":
      colors = new int[] {163,104,158};
      break;
    case "Presidio Heights":
      colors = new int[] {175,150,239};
      break;
    case "Oceanview/Merced/Ingleside":
      colors = new int[] {184,199,149};
      break;
    case "Lakeshore":
      colors = new int[] {90,125,31};
      break;
    case "Financial District/South Beach":
      colors = new int[] {128,225,183};
      break;
    case "Western Addition":
      colors = new int[] {248,154,90};
      break;
    case "Japantown":  
      colors = new int[] {131,85,71};
      break;
    case "Potrero Hill":
      colors = new int[] {200,92,5};
      break;
    case "Treasure Island":
      colors = new int[] {40,70,124};
      break;
    case "Golden Gate Park":
      colors = new int[] {162,9,146};
      break;
    case "Haight Ashbury":
      colors = new int[] {107,83,19};
      break;
    case "McLaren Park":
      colors = new int[] {223,231,240};
      break;
    case "Inner Sunset":
      colors = new int[] {0,73,23};
      break;
    case "Marina":
      colors = new int[] {174,23,98};
      break;
    case "South of Market":
      colors = new int[] {138,173,94};
      break;
    case "Lone Mountain/USF":
      colors = new int[] {210,94,141};
      break;
    case "Sunset/Parkside":
      colors = new int[] {71,129,136};
      break;
    case "North Beach":
      colors = new int[] {52,44,129};
      break;
    case "Russian Hill":
      colors = new int[] {48,35,76};
      break;
    case "Inner Richmond":
      colors = new int[] {201,143,137};
      break;
    case "Outer Mission":
      colors = new int[] {221,225,133};
      break;
    case "Portola":
      colors = new int[] {18,154,132};
      break;
    case "Hayes Valley":
      colors = new int[] {222,79,27};
      break;
    default:
      colors = new int[] {0,0,0};
  }
  
  return colors;
}

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
  translate(width/2, height/2);
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
  strokeWeight(.1);
  //noFill();
  int[] colors = getColorForArea(e.get(0));
  color c = color(colors[0],colors[1],colors[2],e.size());
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