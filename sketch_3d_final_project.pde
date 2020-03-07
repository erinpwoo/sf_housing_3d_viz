import peasy.*;
import javafx.util.Pair;
import java.util.*;
PeasyCam cam;
Table evic_table;
Table gen_table;
int evic_row_ct;
int gen_row_ct;
String url = "https://geo.fcc.gov/api/census/area?";
HashMap<String, String> geo_fips;
HashMap<String, Eviction> evictions = new HashMap<String, Eviction>();

void setup() {
  size(1200, 600, P3D);
  cam = new PeasyCam(this, width/2,height/2,0, 0);
  cam.setCenterDragHandler(null); 
  cam.setRotations(0,0,0);
  smooth();
  
  evic_table = loadTable("Eviction_Notices.csv", "header");
  gen_table = loadTable("udp_2017results.csv", "header");
  
  evic_row_ct = evic_table.getRowCount();
  gen_row_ct = gen_table.getRowCount();
  
  geo_fips = new HashMap<String, String>();
  
  for (int i = 0; i < gen_row_ct; i++) {
    geo_fips.put(gen_table.getString(i, 0), gen_table.getString(i, 1));
  }
  
  for (int i = 0; i < evic_row_ct; i++) {
    if ((evic_table.getString(i, 28).length() > 1)) {
      Pair<Double, Double> loc = parseLoc(evic_table.getString(i, 28));
      String area = evic_table.getString(i, 27);
      String addr = evic_table.getString(i, 1);
      // parsing date
      String[] date = split(evic_table.getString(i, 5), '/');
      int month = Integer.parseInt(date[0]);
      int day = Integer.parseInt(date[1]);
      int year = Integer.parseInt(date[2]);
      int[] parsedDate = {month, day, year};
      JSONObject res = loadJSONObject(url + "lon=" + loc.getKey() + "&lat=" + loc.getValue());
      String fips = String.valueOf(res.getJSONArray("results").getJSONObject(0).getString("block_fips").substring(1,11));
      int date_num = (year - 1996)*365 +  (month *  30) + day;
      Eviction e = new Eviction(loc.getKey(), loc.getValue(), parsedDate, area, addr, geo_fips.get(fips), fips, date_num);
      evictions.put(area, e);
      //println(loc.getKey() + " " + loc.getValue() + " " + area + " " + addr + " " + parsedDate[0]+parsedDate[1]+parsedDate[2] + " " +  geo_fips.get(fips));
    }
  }
}

void draw() {
  background(0,0,0);
  drawData();
}

void drawData() {
  Iterator itr = evictions.entrySet().iterator();
  
  while (itr.hasNext()) {
    drawPoint((Eviction)(((Map.Entry)itr.next()).getValue()));
  }
}  

Pair<Double, Double> parseLoc(String in) {
  String str = in.substring(7, in.length()-1);
  String[] s = str.split(" ");
  return new Pair<Double, Double>(Double.parseDouble(s[0]), Double.parseDouble(s[1]));
}